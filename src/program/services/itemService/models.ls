module?.exports = {

	\Item : class Item
		->
			@itemType = ''
			@name = ''

		fullName :~ -> @name



	\Equipment : class Equipment extends Item
		->
			@weight = 0.0

			# How far the equipment has been upgraded (+1, +2, etc.)
			@level = 0


		fullName :~ -> @name + if @level > 0 then " #{@levelText }" else ""


		levelText :~ -> if @level > 0 then "+#{@level }" else ""



	\Armor : class Armor extends Equipment
		->
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