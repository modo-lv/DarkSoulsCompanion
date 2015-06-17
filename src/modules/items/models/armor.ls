module?.exports = class Armor extends (require './equipment.ls')
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
