class ItemUpgradeModel
	(rawUpgrade) ->
		# Shared defense values
		@defMod = []

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
		@atkMod = []

		# Stat bonus modifiers
		@bonusMod = []



class ArmorUpgradeModel extends ItemUpgradeModel
	(rawUpgrade) ->
		super rawUpgrade

		@defPhyMod = []


module?.exports = {
	\Weapon : WeaponUpgradeModel
	\Armor : ArmorUpgradeModel
}