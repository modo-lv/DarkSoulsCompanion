module?.exports = {

	\Item : class ItemModel
		->
			# ID of the item. Can overlap between weapon types, e.g. weapons and armor.
			@id = 0

			# Broad category of the item. Possible values: item, ring, weapon, armor.
			@itemType = null

			# More specific subtype. Armors and weapons will have their own properties,
			# but for the rest this differentiates between spells, usables, upgrade materials, keys etc.
			@itemSubtype = null

			# Item name.
			@name = ''

			# How many souls will be gained by feeding the item to Frampt.
			@sellValue = 0

			# ID of the item graphic. Currently unused in DSC.
			@iconId = 0


			@sortId = 0


		/**
		 * A unique ID that doesn't overlap between item types.
		 */
		uid :~ -> @itemType + @id


		useDataFrom : (itemData) ~>
			@ <<< itemData


	\Equipment : class EquipmentModel extends ItemModel
		->
			super!

			# Weight when equipped
			@weight = 0.0

			# Durability
			@durability = 0

			# Defense values common to weapons and armor.
			@defPhy = 0
			@defMag = 0
			@defFir = 0
			@defLit = 0
			@defTox = 0
			@defBlo = 0
			@defCur = 0

			# Material set ID (for finding required upgrade materials)
			@matSetId = 0

			# How many souls it costs to upgrade this equipment
			@upgradeCost = 0

			# ID of the upgrade *currently applied* to the equipment.
			@upgradeId = -1


	\Weapon : class WeaponModel extends EquipmentModel
		->
			super!

			@itemType = \weapon

			# Broad category for this weapon, e.g. bow, sword, shield, etc.
			@weaponType = ''

			# Specific weapon type, e.g. Short Sword, Curved Sword, Medium Shield, etc.
			@weaponSubtype = ''

			# Ascention path - Crystal, Raw etc.
			@path = ''

			@canBlock = false
			@canParry = false
			@casts = null

			# Can this weapon attack and damage ghosts even when the player isn't cursed?
			@damagesGhosts = false

			# Can this weapon be enchanted with magic?
			@isAugmentable = false

			# Damage types
			@dmgReg = false
			@dmgStrike = false
			@dmsSlash = false
			@dmgThrust = false

			# Wielding requirements
			@reqStr = 0
			@reqDex = 0
			@reqInt = 0
			@reqFai = 0

			# Parameter bonuses (scaling values)
			@bonusStr = 0
			@bonusDex = 0
			@bonusInt = 0
			@bonusFai = 0

			# Attack values
			@atkPhy = 0
			@atkMag = 0
			@atkFir = 0
			@atkLit = 0

			# Attack stamina cost
			@atkSta = 0
			# Stability (percentage of stamina kept when defending against attack)
			@defSta = 0

			# Divine attack modifier
			@divine = 0

			# Occult attack modifier
			@occult = 0

			# Range for bows & crossbows
			@range = 0

			# Bleed effect
			@atkBlo = 0
			@dmgBlo = 0

			# Poison effect
			@atkTox = 0
			@dmgTox = 0

			# HP recovery-on-hit effect
			@atkHeal = 0

			@atkCosts = []
			
		dpsPhy :~ -> @_dpsFor @atkPhy
		dpsMag :~ -> @_dpsFor @atkMag
		dpsFir :~ -> @_dpsFor @atkFir
		dpsLit :~ -> @_dpsFor @atkLit


	\Armor : class ArmorModel extends EquipmentModel
		->
			super!

			@itemType = \armor

			# head, chest, legs or hands
			@armorType = ''

			# What set the armor belongs to
			@armorSet = ''

			# Specific attack type defenses
			@defSlash = 0
			@defStrike = 0
			@defThrust = 0

			# Poise
			@defPoise = 0

			# Stamina recovery speed modifier
			@staRegenMod = 0


		# Numeric armor type, for use in sorting
		sortType :~ ->
			switch @armorType
			| \head => 1
			| \chest => 2
			| \hands => 3
			| \legs => 4

}