angular.module "dsc"
	.constant "$ItemIds", {
		\LargeEmber : 800
		\TitaniteShard : 1000
	}

$resource, $ItemIds, $q <-! angular .module "dsc" .service "itemService"

svc = {
	# Items in separate arrays, grouped by type
	items : {}

	itemTypes : [\items \weapons \armors]

	itemIndex : []

	_promises : {}
}

	..models = require './service/models'


/**
 * Load the item index.
 * @returns An array that will be asynchronously populated when the results are in.
 */
svc.loadItemIndex = (force = false) !->
	if force or svc.itemIndex |> empty
		svc.itemIndex = $resource '/modules/items/content/index.json' .query!

	return svc.itemIndex


svc.getFromIndexById = (id) -> svc.itemIndex |> find (.id == id)


/**
 * Given a 'lite' item from the index, return the full data.
 * Items must be loaded.
 */
svc.getItemByIndex = (indexEntry) -> svc.items[indexEntry.itemType][indexEntry.id]


/**
 * Load item data from JSON file and construct models
 */
svc.loadItemData = (itemType = \items, force = false) !->
	def = $q.defer!

	def.resolve svc.items[itemType] unless force or (svc.{}items.[][itemType] |> empty)

	# If we are already loading
	if svc.{}items.[][itemType].$promise?
		return svc.items[itemType]

	svc.items[itemType].$promise = def.promise

	result = $resource "/modules/items/content/#{itemType}.json" .query !->
		svc.items[itemType].length = 0

		for itemData in result
			svc.createItemFrom itemData
				.. |> svc.items[itemType].push

		def.resolve svc.items[itemType]

	return svc.items[itemType]


svc
	..createItemFrom = (itemData) ->
		(switch itemData.itemType
		| 'armor' => new svc.models.Armor
		| 'weapon' => new svc.models.Weapon
		| otherwise => new svc.models.Item
		) <<< itemData


	..getUpgradeFor = (weapon, iteration) !->
		def = $q.defer!

		svc.loadItemData \upgrades .$promise.then (upgradeData) !->
			def.resolve (upgradeData |> find (.id == weapon.upgradeId + iteration))

		return def.promise


	..getUpgradedVersionOf = (weapon, iteration) !->
		def = $q.defer!

		(svc.getUpgradeFor weapon, iteration).then (upgrade) !->
			if not upgrade? then return def.resolve null

			#console.log "Weapon is", weapon, ", upgrade is ", upgrade

			upWeapon = new svc.models.Weapon! <<< weapon
				..id += iteration
				..upgradeId = upgrade.id
				..name += " +#{iteration }" if iteration > 0

			for mapping in [
				[\dmgN \dmgModN]
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
				..defN *= +upgrade.\defModN
				..defM *= +upgrade.\defModM
				..defF *= +upgrade.\defModF
				..defL *= +upgrade.\defModL

			#console.log "Result is", upWeapon

			def.resolve upWeapon

		return def.promise


svc.canUpgradeWithMaterials = (weapon, materials, iteration) ->
	svc.getUpgradeFor weapon, iteration .then (upgrade) !->
		#if weapon.name.substring(0, 7) == \Halberd
		#	console.log weapon, materials, iteration, upgrade
		if not upgrade?
			#console.log "Failed to get next upgrade for weapon ", weapon, "and iteration ", iteration
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


svc.payForUpgradeFor = (weapon, materials, iteration) ->
	svc.getUpgradeFor weapon, iteration .then (upgrade) !->
		if not upgrade? or upgrade.matId < 0 or upgrade.matCost < 0
			return true

		(materials |> find (.id == upgrade.matId))?.amount -= upgrade.matCost
		return true



/**
 * Modify a weapon with the properties of a given upgrade iteration
 */
svc.applyUpgradeTo = (weapon, iteration) !->
	def = $q.defer!

	(svc.getUpgradedVersionOf weapon, iteration).then (upgraded) !->
		weapon <<< upgraded
		def.resolve!

	return def.promise


return svc