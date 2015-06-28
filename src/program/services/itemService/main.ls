angular.module "dsc.services"
	.constant "ITEM_TYPE", {
		\ITEM : \item
		\KEY : \key
		\ARMOR : \armor
		\RING : \ring
	}
	.service "itemService", -> self = {
		# Items in separate arrays, grouped by type
		items : {}

		# All items in a single array
		allItems : []

		itemTypes : [\items \materials \armors \keys \rings]
	}

		..models = require './models'

		..loadItems = (force = false) !->
			return unless force or self.[]allItems.length < 1

			!-> require "./content/*.json", mode : 'expand'

			for itemType in self.itemTypes
				for itemData in require "./content/#{itemType }.json"
					self.createItem itemData
						.. |> self.items.[][itemType].push
						.. |> self.[]allItems.push


		..createItem = (itemData) ->
			(switch itemData.itemType
			| 'armor' => new self.models.Armor!
			| otherwise => new self.models.Item!
			) <<< itemData


		..getItemByFullName = (itemName) ->
			self.allItems |> find (.fullName == itemName) ?
				throw new Error "There is no item with the name '#{itemName }' in the database."
