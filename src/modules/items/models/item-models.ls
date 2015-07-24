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


		useDataFrom : (itemData) !~>
			@ <<< itemData

			# Re-copy arrays to make sure there are no references left
			for key in [\def \dmgTypes \atk \req \atkCost \dmg \bonus \defPhy]
				if @.[key]? and itemData.[key]? then @.[key] = itemData.[key].slice!

			return this


	\Equipment : class EquipmentModel extends ItemModel
		->
			super!

			# Weight when equipped
			@weight = 0.0

			# Durability
			@durability = 0

			# Defense values common to weapons and armor.
			@def = []

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
			@dmgTypes = []

			# Attack values
			@atk = []

			# Wielding requirements
			@req = []

			# Parameter bonuses (scaling values)
			@bonus = []

			# Range for bows & crossbows
			@range = 0

			@def = []

			@atkCosts = []

		dpsPhy :~ -> @_dpsFor @atk.0
		dpsMag :~ -> @_dpsFor @atk.1
		dpsFir :~ -> @_dpsFor @atk.2
		dpsLit :~ -> @_dpsFor @atk.3


	\Armor : class ArmorModel extends EquipmentModel
		->
			super!

			@itemType = \armor

			# head, chest, legs or hands
			@armorType = ''

			# What set the armor belongs to
			@armorSet = ''

			# Specific attack type defenses
			@defPhy = []

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