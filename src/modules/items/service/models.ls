module?.exports = {

	\Item : class Item
		->
			@id = 0
			@itemType = 'item'
			@name = ''
			@sell = 0

		fullName :~ -> @name

		uid :~ -> @itemType + @id


	\Upgrade : class Upgrade extends Item
		->
			super!
			@itemType = 'upgrade'

		id :~
			-> @_id
			(val) -> @_id = val; console.log "Setting ID on upgrade ", this, "to value", val


	\Equipment : class Equipment extends Item
		->
			super!

			@weight = 0.0

			# How far the equipment has been upgraded (+1, +2, etc.)
			@level = 0

			@durability = 0

			@upgradeId = -1

			# Physical defense
			@defN = 0
			@defM = 0
			@defF = 0
			@defL = 0
			@defT = 0
			@defB = 0
			@defC = 0



		fullName :~ -> @name + if @level > 0 then " #{@levelText }" else ""


		levelText :~ -> if @level > 0 then "+#{@level }" else ""
		
		
	\Weapon : class Weapon extends Equipment
		->
			super!

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

			@dmgN = 0
			@dmgM = 0
			@dmgF = 0
			@dmgL = 0
			@dmgS = 0

			# Poise damage (stagger)
			@dmgP = 0

			@scS = 0
			@scD = 0
			@scI = 0
			@scF = 0


			# Stamina defense
			@defS = 0

			# Poise
			@defP = 0

			@divMod = 0
			@occMod = 0

			@upCost = 0

			# Ascention path
			@path = ''

			# Range for bows & crossbows
			@range = 0

			# Available upgrades
			@upgrades = []
			

	\Armor : class Armor extends Equipment
		->
			super!
			@itemType = ''
			# head, chest, legs or hands
			@armorType = ''

			# What set the armor belongs to
			@armorSet = ''

			@sell = 0

			@iconId = 0

			@defSl = 0
			@defSt = 0
			@defTh = 0

			@stRec = 0

		sortType :~ ->
			switch @armorType
			| \head => 1
			| \chest => 2
			| \hands => 3
			| \legs => 4

}