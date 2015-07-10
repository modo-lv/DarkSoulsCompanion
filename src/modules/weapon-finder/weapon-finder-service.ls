angular?.module "dsc" .service "weaponFinderSvc" (itemSvc, statSvc, $q) -> new WeaponFinderService ...

class WeaponFinderService
	(@_itemSvc, @_statSvc, @$q) ->
		@params = {
			statBonus : 0
		}


	findBestWeapons : ~>
		allWeapons = []

		# Find weapons that match parameters
		@findFittingWeapons!

		# Find all the upgrades
		.then (weapons) ~>
			allWeapons ++= weapons
			@$q.all weapons |> map ~> @_itemSvc.upgradeComp.findAllAvailableUpgradesFor it

		# Apply parameters and calculate scores
		.then (upWeapons) ~>
			allWeapons ++= upWeapons

			allWeapons |> each ~> it.score = @calculateScoreFor it

			return allWeapons


	findFittingWeapons : ~>
		@_itemSvc.findItemsFromInventory \weapon
		.then (weapons) !~>
			# Discard any that don't meet requirements

			return weapons


	calculateScoreFor : (weapon) ~>
		scS = @_statSvc.statScalingFactorOf \strength
		scD = @_statSvc.statScalingFactorOf \dexterity
		scI = @_statSvc.statScalingFactorOf \intelligence
		scF = @_statSvc.statScalingFactorOf \faith

		str = @params.statBonus + @_statSvc.statValueOf \strength
		dex = @params.statBonus + @_statSvc.statValueOf \dexterity
		int = @params.statBonus + @_statSvc.statValueOf \intelligence
		fai = @params.statBonus + @_statSvc.statValueOf \faith

		weapon.atkPhy *= (1 + ((weapon.bonusStr * scS) + (weapon.bonusDex * scD)))
		weapon.atkMag *= (1 + ((weapon.bonusInt * scI) + (weapon.bonusFai * scF)))

		score = weapon.atkPhy



module? .exports = WeaponFinderService