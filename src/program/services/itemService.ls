angular.module "dsc.services"
	.service "itemService", -> self = {
		# Items in separate arrays, grouped by type
		items : {}

		# All items in a single array
		allItems : []

		itemTypes : [\items \materials \armors \keys \rings]


		loadItems : (force = false) !->
			return unless force or self.[]allItems.length < 1

			# Instantiate for browserify so that we can then use dynamic require() calls
			require "./itemService/content/armors.json"
			require "./itemService/content/items.json"
			require "./itemService/content/keys.json"
			require "./itemService/content/materials.json"
			require "./itemService/content/rings.json"
		
			for itemType in self.itemTypes
				for itemData in require "./itemService/content/#{itemType }.json"
					self.createItem itemData
						.. |> self.items.[][itemType].push
						.. |> self.[]allItems.push


		createItem : (itemData) ->
			(switch itemData.itemType
			| 'armor' => new Armor!
			| otherwise => new Item!
			) <<< itemData


		itemExists : (itemName) ->
			self.allItems |> any (.name == itemName)
	}


class Item
	->
		@itemType = ''
		@name = ''

	fullName :~ -> @name



class Equipment extends Item
	->
		@weight = 0.0

		# How far the equipment has been upgraded (+1, +2, etc.)
		@level = 0


	fullName :~ -> @name + if @level > 0 then " #{@levelText }" else ""


	levelText :~ -> if @level > 0 then "+#{@level }" else ""



class Armor extends Equipment
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
