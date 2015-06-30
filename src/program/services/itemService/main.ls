angular.module "dsc.services"
	.service "itemService", -> self = {
		# Items in separate arrays, grouped by type
		items : {}

		# All items in a single array
		allItems : []

		# Upgrade paths
		upgrades : {}

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


		..loadUpgrades = (force) !->
			unless force or self.upgrades |> Obj.empty
				return

			upgrades = require './content/upgrades.json'
			for upgrade in upgrades
				self.upgrades[upgrade.id] = upgrade


		..getUpgradeFor = (weapon, iteration) ->
			self.loadUpgrades!
			#console.log self.upgrades
			self.upgrades[weapon.upgradeId + iteration]


		..getUpgradedWeapon = (weapon, iteration) !->
			self.loadUpgrades!

			upgrade = self.getUpgradeFor weapon, iteration

			if not upgrade? then return null

			upWeapon = new self.models.Weapon <<< weapon
				..id++
				..upgradeId = upgrade.id
				..name += " +#{iteration }"

			for mapping in [
				[\dmgP \dmgModP]
				[\dmgM \dmgModM]
				[\dmgF \dmgModF]
				[\dmgL \dmgModL]
				[\dmgS \dmgModS]

				[\defT \defModT]
				[\defB \defModB]
				[\defC \defModC]
				[\defS \defModS]
			]
				upWeapon[mapping.0] = upWeapon[mapping.0] * upgrade[mapping.1] |> Math.floor

			for mapping in [
				[\scP \scModP]
				[\scD \scModD]
				[\scI \scModI]
				[\scF \scModF]
			]
				upWeapon[mapping.0] = upWeapon[mapping.0] * upgrade[mapping.1]

			upWeapon
				..defP *= +upgrade.\defModP
				..defM *= +upgrade.\defModM
				..defF *= +upgrade.\defModF
				..defL *= +upgrade.\defModL

			return upWeapon


		..canUpgradeWithMaterials = (weapon, materials, iteration) !->
			upgrade = self.getUpgradeFor weapon, iteration
			if weapon.name.substring(0, 7) == \Halberd
				console.log weapon, materials, iteration, upgrade
			if not upgrade?
				console.log "Failed to get next upgrade for weapon ", weapon
				return false
			if upgrade.matId < 0 or upgrade.matCost < 0
				return true

			for material in materials
				if material.id == upgrade.matId and material.amount >= upgrade.matCost
					return true

			return false


		..payForUpgradeFor = (weapon, materials, iteration) !->
			upgrade = self.getUpgradeFor weapon, iteration
			if not upgrade? or upgrade.matId < 0 or upgrade.matCost < 0
				return

			(materials |> find (.id == upgrade.matId)).amount -= upgrade.matCost