angular?.module "dsc" .service "weaponFinderSvc" (itemSvc, inventorySvc, statSvc, $q) ->
	new WeaponFinderService ...

class WeaponFinderService
	(@_itemSvc, @_inventorySvc, @_statSvc, @$q) ->
		@params = {
			useDps : false
			dpsCalcMove : 0
			includeUpgrades : true
			modifiers : {}
			reqLimits : {}
		}

		@statArray = @_itemSvc.@@AttackTypes ++ @_itemSvc.@@DefenceTypes

		(@_itemSvc.@@WeaponStats) |> each !~>
			@params.reqLimits[it] = 20
		@statArray |> each !~>
			@params.modifiers[it] = 0
		@params.modifiers[\atkPhy] = 1


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
		.then (list) ~> @findFittingWeaponsIn list


	findFittingWeaponsIn : (weaponList) ~>
		# Discard any that don't meet requirements
		fitWeapons = []
		statKeys = [\str \dex \int \fai]
		reqKeys = [\reqStr \reqDex \reqInt \reqFai]
		statValues = {}

		for weapon in weaponList
			fit = true
			for key, a in statKeys
				#console.log "#{key} : #{weapon[reqKeys.[a]]} > #{@params.reqLimits[key]}"
				if not @params.reqLimits[key]? then continue
				if weapon[reqKeys.[a]] > @params.reqLimits[key]
					fit = false
					break
			if fit then fitWeapons.push weapon

		return @$q.when fitWeapons


	calculateScoreFor : (weapon) ~>
		result = {} <<< weapon

		scS = @_statSvc.scalingFactorOf \str, @params.reqLimits.[\str]
		scD = @_statSvc.scalingFactorOf \dex, @params.reqLimits.[\dex]
		scI = @_statSvc.scalingFactorOf \int, @params.reqLimits.[\int]
		scF = @_statSvc.scalingFactorOf \fai, @params.reqLimits.[\fai]

		result
			..atkPhy *= (1 + ((weapon.bonusStr * scS) + (weapon.bonusDex * scD)))
			..atkMag *= (1 + ((weapon.bonusInt * scI) + (weapon.bonusFai * scF)))

			..atkCost = result.atkCosts[@params.dpsCalcMove]
			..dps = @_itemSvc.@@AttackTypes |> map ~> if result.[it] < 1 then 0 else Math.floor(result.[it] / (..atkCost ? result.[it]))

			..dps[0] = ..dps[1] = 0 if result.weaponType == \Magic

		# Score
			..score = 0

		for statName, index in @statArray
			#console.log "result.score += (#{result[statName]} * #{@params.modifiers[statName]})"
			
			if @params.useDps and @_itemSvc.@@DpsTypes.[index]?
				stat = result.dps[index]
			else
				stat = result[statName]

			result.score += (stat * @params.modifiers[statName])

		return result



module? .exports = WeaponFinderService