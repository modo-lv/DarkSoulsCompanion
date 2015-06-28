module?.exports = {

	\Item : class Item
		->
			@itemType = ''
			@name = ''
			@framptValue = 0

		fullName :~ -> @name



	\Equipment : class Equipment extends Item
		->
			@weight = 0.0

			# How far the equipment has been upgraded (+1, +2, etc.)
			@level = 0

			@durability = 0


		fullName :~ -> @name + if @level > 0 then " #{@levelText }" else ""


		levelText :~ -> if @level > 0 then "+#{@level }" else ""

	\Weapon : class Weapon extends Equipment
		->
			@weaponCategory = ''
			@canBlock = false
			@canParry = false
			@castsMagic = false
			@castsPyromancy = false
			@castsMiracles = false
			@canDamageGhosts = false
			@iconId = 0
			@hasRegularDamage = false
			@hasStrikeDamage = false
			@hasSlashDamage = false
			@hasThrustDamage = false
			@isEnchantable = false
			@reqStr = 0
			@reqDex = 0
			@reqInt = 0
			@reqFaith = 0

			@dmgPhys = 0
			@dmgMagic = 0
			@dmgFire = 0
			@dmgLight = 0
			@dmgStam = 0

			@scaleStr = 0
			@scaleDex = 0
			@scaleInt = 0
			@scaleFaith = 0

			@defPhys = 0
			@defMagic = 0
			@defFire = 0
			@defLight = 0

			@defPoison = 0
			@defBleed = 0
			@defCurse = 0

			@stability = 0

			@divineMod = 0
			@occultMod = 0

			@upgradeSouls = 0
			@upgradeMaterialId = 0
			@upgradeMaterialAmount = 0

			# Ascention path
			@path = ''

			# Range for bows & crossbows
			@shotRange = 0

	\Armor : class Armor extends Equipment
		->
			@itemType = 'armor'
			# head, chest, legs or hands
			@armorType = 'head'

			# What set the armor belongs to
			@armorSet = ''

			@physical = 0.0
			@strike = 0.0
			@slash = 0.0
			@thrust = 0.0

			@magic = 0.0
			@fire = 0.0
			@lightning = 0.0

			@bleed = 0.0
			@poison = 0.0
			@curse = 0.0

			@poise = 0

}