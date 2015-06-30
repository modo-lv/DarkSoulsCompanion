angular.module "dsc.services"
	.service "itemService", -> self = {
		# Items in separate arrays, grouped by type
		items : {}

		# All items in a single array
		allItems : []

		itemTypes : [\items \weapons \armors \rings]
	}

		..models = require './models'


		..getById = (id) !->
			self.loadItems!
			return self.allItems |> find (.id == id)


		..loadItems = (force = false) !->
			return unless force or self.[]allItems.length < 1

			!-> require "./content/*.json", mode : 'expand'

			for itemType in self.itemTypes
				for itemData in require "./content/#{itemType }.json"
					self.createItemFrom itemData
						.. |> self.{}items.[][itemType].push
						.. |> self.[]allItems.push


		..createItemFrom = (itemData) ->
			(switch itemData.itemType
			| 'armor' => new self.models.Armor
			| 'weapon' => new self.models.Weapon
			| otherwise => new self.models.Item
			) <<< itemData


		..getItemByFullName = (itemName) ->
			self.allItems |> find (.fullName == itemName) ?
				throw new Error "There is no item with the name '#{itemName }' in the database."


		..getUpgradedWeapon = (weapon) !->
			upgrades = require './content/upgrades.json'
			upgrade = upgrades[weapon.upgradeId + 1]

			if not upgrade? then return null

			upWeapon = new self.models.Weapon <<< weapon
				..id++
				..upgradeId = upgrade.id
				..


