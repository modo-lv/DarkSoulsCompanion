module?.exports = {

	\Item : class Item
		->
			@id = 0
			@itemType = 'item'
			@name = ''
			@sell = 0

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
			@itemType = 'weapon'
			@wepCat = ''
			@canB = false
			@canP = false
			@isMag = false
			@isPyr = false
			@isMir = false
			@isGhost = false
			@iconId = 0
			@isDmgReg = false
			@isDmgStr = false
			@isDmgSl = false
			@isDmgThr = false
			@isAug = false

			@reqS = 0
			@reqD = 0
			@reqI = 0
			@reqF = 0

			@dmgP = 0
			@dmgM = 0
			@dmgF = 0
			@dmgL = 0
			@dmgS = 0

			@scS = 0
			@scD = 0
			@scI = 0
			@scF = 0

			@defP = 0
			@defM = 0
			@defF = 0
			@defL = 0
			@defT = 0
			@defB = 0
			@defC = 0
			@defS = 0

			@divMod = 0
			@occMod = 0

			@upCost = 0
			@upMatId = 0
			@upMatCost = 0

			# Ascention path
			@path = ''

			# Range for bows & crossbows
			@range = 0

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