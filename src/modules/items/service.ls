angular.module "dsc"
	.constant "$ItemIds", {
		\LargeEmber : 800
		\TitaniteShard : 1000
	}

$resource, $ItemIds, $q <-! angular .module "dsc" .service "itemService"

svc = {
	# Items in separate arrays, grouped by type
	items : {}

	# All items in a single array
	allItems : []

	# Upgrade paths
	upgrades : {}

	itemTypes : [\items \weapons \armors]
}

	..models = require './models'


svc.loadIdNameIndex = ->
	return $resource '/modules/items/content/idNameIndex.json' .query!


svc
	..getById = (id) !->
		svc.loadItems!
		return svc.allItems |> find (.id == id)


	..loadItems = (itemType = \items, force = false) !->
		unless force or svc.[]allItems |> empty
			return

		result = $resource "/modules/items/content/#{itemType}.json" .query!

		items = []
		defer = $q.defer!
		items.$promise = defer.promise

		result.$promise.then !->
			for itemData in result
				svc.createItemFrom itemData
					.. |> items.push

			defer.resolve!

		return items


	..createItemFrom = (itemData) ->
		(switch itemData.itemType
		| 'armor' => new svc.models.Armor
		| 'weapon' => new svc.models.Weapon
		| otherwise => new svc.models.Item
		) <<< itemData


	..getItemByFullName = (itemName) ->
		svc.allItems |> find (.fullName == itemName) ?
			throw new Error "There is no item with the name '#{itemName }' in the database."


	..loadUpgrades = (force) !->
		unless force or svc.upgrades |> Obj.empty
			return

		upgrades = require './content/upgrades.json'
		for upgrade in upgrades
			svc.upgrades[upgrade.id] = upgrade


	..getUpgradeFor = (weapon, iteration) ->
		svc.loadUpgrades!
		svc.upgrades[weapon.upgradeId + iteration]


	..getUpgradedWeapon = (weapon, iteration) !->
		svc.loadUpgrades!

		upgrade = svc.getUpgradeFor weapon, iteration

		if not upgrade? then return null

		upWeapon = new svc.models.Weapon <<< weapon
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
		upgrade = svc.getUpgradeFor weapon, iteration
		#if weapon.name.substring(0, 7) == \Halberd
		#	console.log weapon, materials, iteration, upgrade
		if not upgrade?
			console.log "Failed to get next upgrade for weapon ", weapon
			return false

		# +6 weapons need Large Ember
		#console.log iteration, materials, $ItemIds

		if iteration > 5 and not (materials |> any (.id == $ItemIds.\LargeEmber ))
			return false

		if upgrade.matId < 0 or upgrade.matCost < 0 or upgrade.matId == $ItemIds.\TitaniteShard
			return true

		for material in materials
			if material.id == upgrade.matId and material.amount >= upgrade.matCost
				return true

		return false


	..payForUpgradeFor = (weapon, materials, iteration) !->
		upgrade = svc.getUpgradeFor weapon, iteration
		if not upgrade? or upgrade.matId < 0 or upgrade.matCost < 0
			return

		(materials |> find (.id == upgrade.matId))?.amount -= upgrade.matCost

return svc