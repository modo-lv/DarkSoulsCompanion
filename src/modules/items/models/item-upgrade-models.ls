class ItemUpgradeModel
	(rawUpgrade) ->
		@useDataFrom rawUpgrade

	useDataFrom : (rawUpgrade) !~>
		if not rawUpgrade? then return

		@id = rawUpgrade.id

		for a in [
			[ \Physical \N ]
			[ \Magic \M ]
			[ \Fire \F ]
			[ \Light \L ]
			[ \Poison \T ]
			[ \Bleed \B ]
			[ \Curse \C ]
		]
			@.["defMod#{a.0}"] = rawUpgrade.["defMod#{a.1}"]

		@matSetId = rawUpgrade.matSetId


class WeaponUpgradeModel extends ItemUpgradeModel
	(rawUpgrade) ->
		@useDataFrom rawUpgrade

	useDataFrom : (rawUpgrade) !~>
		if not rawUpgrade? then return

		super rawUpgrade

		for a in [
			[ \Physical \N ]
			[ \Magic \M ]
			[ \Fire \F ]
			[ \Lightning \L ]
			[ \Stability \S ]
		]
			@.["atkMod#{a.0}"] = rawUpgrade.["dmgMod#{a.1}"]

		for a in [
			[ \Str \S ]
			[ \Dex \D ]
			[ \Int \I ]
			[ \Fai \F ]
		]
			@.["bonusMod#{a.0}"] = rawUpgrade.["scMod#{a.1}"]

		@.[\defModStability] = rawUpgrade.[\scModS]


class ArmorUpgradeModel extends ItemUpgradeModel
	(rawUpgrade) ->
		@useDataFrom rawUpgrade

	useDataFrom : (rawUpgrade) !~>
		if not rawUpgrade? then return

		super rawUpgrade
		for a in [
			[ \Slash \Sl ]
			[ \Strike \St ]
			[ \Thrust \Th ]
		]
			@.["defMod#{a.0}"] = rawUpgrade.["defMod#{a.1}"]



module?.exports = {
	\Weapon : WeaponUpgradeModel
	\Armor : ArmorUpgradeModel
}