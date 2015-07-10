angular?.module "dsc" .service "weaponFinderSvc" (itemSvc, statSvc, $q) -> new WeaponFinderService ...

class WeaponFinderService
	(@_itemSvc, @_statSvc, @$q) ->
		@params = {
			statBonus : 0
			searchType : \offence
		}


	findBestWeapons : ~>
		allWeapons = []

		# Find weapons that match parameters
		@findFittingWeapons!

		# Find all the upgrades
		.then (weapons) ~>
			allWeapons ++= weapons
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
			
			str = @params.statBonus + @_statSvc.statValueOf \strength
			dex = @params.statBonus + @_statSvc.statValueOf \dexterity
			int = @params.statBonus + @_statSvc.statValueOf \intelligence
			fai = @params.statBonus + @_statSvc.statValueOf \faith
			
			weapons = weapons
				|> filter -> str >= it.reqStr and dex >= it.reqDex and int >= it.reqInt and fai >= it.reqFai

			return weapons


	calculateScoreFor : (weapon) ~>
		result = {} <<< weapon

		scS = @_statSvc.statScalingFactorOf \strength
		scD = @_statSvc.statScalingFactorOf \dexterity
		scI = @_statSvc.statScalingFactorOf \intelligence
		scF = @_statSvc.statScalingFactorOf \faith

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