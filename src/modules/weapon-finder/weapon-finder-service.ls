angular?.module "dsc" .service "weaponFinderSvc" (itemSvc, inventorySvc, statSvc, $q) ->
	new WeaponFinderService ...

class WeaponFinderService
	(@_itemSvc, @_inventorySvc, @_statSvc, @$q) ->
		@params = {
			useDps : false
			dpsCalcMove : 0
			includeUpgrades : true
			modifiers : {
				atk : [1 1 1 1 0 0 0 0]
				def : [1 1 1 1 0 0 0 0]
			}
			stats : [99 99 99 99 99]
		}

		for a in @_itemSvc.@@WeaponStats.length
			@params.stats[a] = 99


	findBestWeapons : ~>
		allWeapons = []

		# Find weapons that match parameters
		@findFittingWeapons!

		# Find all the upgrades
		.then (weapons) ~>
			allWeapons ++= weapons

			if not @params.includeUpgrades then return []

			@$q.all (weapons
				|> map ~> @_inventorySvc.findAllAvailableUpgradesFor it
			)

		# Apply parameters and calculate scores
		.then (upWeapons) ~>
			allWeapons ++= upWeapons |> (reject -> it |> empty) |> flatten

			allWeapons |> map @calculateScoreFor


	findFittingWeapons : ~>
		@_inventorySvc.findItemsByType \weapon
		.then (list) ~>
			promises = []
			for item in list
				promises.push @$q.all [
					@$q.when item
					@_itemSvc.upgradeComp.findBaseItem item
				]
			return @$q.all promises
		.then (results) ~>
			promises = []
			for result in results
				item = result.0
				baseItem = result.1
				promises.push(
					@$q.all [
						@$q.when item
						@_itemSvc.getUpgraded baseItem, @_itemSvc.upgradeComp.upgradeLevelOf item
					]
					.then (results) ->
						results.1 ? results.0
				)
			@$q.all promises
		.then (list) ~>
			@findFittingWeaponsIn list


	findFittingWeaponsIn : (weaponList) ~>
		# Discard any that don't meet requirements
		fitWeapons = []
		statValues = {}

		for weapon in weaponList
			fit = true
			for name, index in @_itemSvc.@@WeaponStats
				#console.log "#{key} : #{weapon[reqKeys.[a]]} > #{@params.stats[key]}"
				if not @params.stats[index]? then continue
				if weapon.req[index] > @params.stats[index]
					fit = false
					break
			if fit then fitWeapons.push weapon

		return @$q.when fitWeapons


	calculateScoreFor : (weapon) ~>
		result = {} <<< weapon

		scaling = @_statSvc.allScalingFactorsOf @params.stats

		result
			..score = 0
			..atk = ..atk.slice!
			..def = ..def.slice!
			..dps = [\- \- \- \-]

			# Adjust ATK values according to scaling

			..atk.0 *= (1 + ((weapon.bonus.0 * scaling.0) + (weapon.bonus.1 * scaling.1)))
			..atk.1 *= (1 + ((weapon.bonus.2 * scaling.2) + (weapon.bonus.3 * scaling.3)))

		if result.path == \Chaos || (result.path == null and result.name.indexOf('Chaos') == 0)
			#console.log "Chaos weapon with scaled ATK #{result.atk.0}", scaling
			result.atk.0 *= (1 + (scaling.4 * 0.21))
			#console.log "has ATK #{result.atk.0} with Humanity scaled in"


		# Calculate DPS if required
		if (@params.useDps) then result
			..atkCost = result.atkCosts[@params.dpsCalcMove]
			..dps = [0 to 3] |> map ->
				if result.atk[it] < 1
					then 0
					else Math.floor(result.atk[it] / (..atkCost ? result.atk[it]))

			# Magic weapons only have heavy attack so nullify light ones
			..dps[0] = ..dps[2] = 0 if result.weaponType == \Magic


		# Apply modifiers to ATK
		for stat, index in @_itemSvc.@@AllAttackTypes
			# Divide ATK values by 5 to make their values comparable with defense.
			# So that a weapon with 500 ATK would get the same score as a shield with 100 defense
			score = result.atk[index] / 5 * @params.modifiers.atk[index]
			if @params.useDps
				score *= result.dps[if index > 3 then 0 else index]
			result.score += score

		# Apply modifiers to DEF
		for stat, index in @_itemSvc.@@AllDefenseTypes
			result.score += result.def[index] * @params.modifiers.def[index]

		return result



module? .exports = WeaponFinderService