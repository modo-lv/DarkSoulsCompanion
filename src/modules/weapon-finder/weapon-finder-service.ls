angular?.module "dsc" .service "weaponFinderSvc" (itemSvc, statSvc, $q) -> new WeaponFinderService ...

class WeaponFinderService
	(@_itemSvc, @_statSvc, @$q) ->
		@params = {
			statBonus : 0
			searchType : \offence
			includeUpgrades : true
			modifiers : {}
			reqLimits : {
				\str : 20
				\dex : 20
				\int : 20
				\fai : 20
			}
		}


	findBestWeapons : ~>
		allWeapons = []

		# Find weapons that match parameters
		@findFittingWeapons!

		# Find all the upgrades
		.then (weapons) ~>
			allWeapons ++= weapons

			if not @params.includeUpgrades then return []

			@$q.all (weapons
				|> map ~> @_itemSvc.upgradeComp.findAllAvailableUpgradesFor it
			)

		# Apply parameters and calculate scores
		.then (upWeapons) ~>
			allWeapons ++= upWeapons |> (reject -> it |> empty) |> flatten
			#console.log allWeapons

			allWeapons |> map @calculateScoreFor


	findFittingWeapons : ~>
		@_itemSvc.findItemsFromInventory \weapon
		.then (weapons) !~>
			# Discard any that don't meet requirements
			
			fitWeapons = []
			statKeys = [\str \dex \int \fai]
			reqKeys = [\reqStr \reqDex \reqInt \reqFai]
			statValues = {}

			for weapon in weapons
				fit = true
				for key, a in statKeys
					#console.log "#{key} : #{weapon[reqKeys.[a]]} > #{@params.reqLimits[key]}"
					if not @params.reqLimits[key]? then continue
					if weapon[reqKeys.[a]] > @params.reqLimits[key]
						fit = false
						break
				if fit then fitWeapons.push weapon

			return fitWeapons


	calculateScoreFor : (weapon) ~>
		result = {} <<< weapon

		scS = @_statSvc.statScalingFactorOf \str
		scD = @_statSvc.statScalingFactorOf \dex
		scI = @_statSvc.statScalingFactorOf \int
		scF = @_statSvc.statScalingFactorOf \fai

		result
			..atkPhy *= (1 + ((weapon.bonusStr * scS) + (weapon.bonusDex * scD)))
			..atkMag *= (1 + ((weapon.bonusInt * scI) + (weapon.bonusFai * scF)))

		if @params.searchType == \defence
			result.score = [result.defPhy * 4, result.defMag * 2, result.defFir, result.defLit, result.defSta * 3]
				|> average
		else
			result.score = result.atkPhy

		return result



module? .exports = WeaponFinderService