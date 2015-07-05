class ItemUpgradeModel
	(rawUpgrade) ->
		# Shared defense values
		@defModPhy = 0.0
		@defModMag = 0.0
		@defModFir = 0.0
		@defModLit = 0.0
		@defModTox = 0.0
		@defModBlo = 0.0
		@defModCur = 0.0

		# Material set id. Added to the item's material set id
		# to get the actual id of the materials needed for upgrade
		@matSetId = 0

		@useDataFrom rawUpgrade

	useDataFrom : (rawUpgrade) !~>
		if not rawUpgrade? then return
		@ <<< rawUpgrade


class WeaponUpgradeModel extends ItemUpgradeModel
	(rawUpgrade) ->
		super rawUpgrade

		# Attack modifiers
		@atkModPhy = 0.0
		@atkModMag = 0.0
		@atkModFir = 0.0
		@atkModLit = 0.0

		# Stat bonus modifiers
		@bonusModStr = 0.0
		@bonusModDex = 0.0
		@bonusModInt = 0.0
		@bonusModFai = 0.0



class ArmorUpgradeModel extends ItemUpgradeModel
	(rawUpgrade) ->
		super rawUpgrade

		@defModStrike = 0.0
		@defModThrust = 0.0
		@defModSlash = 0.0


module?.exports = {
	\Weapon : WeaponUpgradeModel
	\Armor : ArmorUpgradeModel
}