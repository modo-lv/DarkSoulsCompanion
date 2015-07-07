angular.module "dsc"
	.constant "$ItemIds", {
		\LargeEmber : 800
		\TitaniteShard : 1000
	}

$resource, $ItemIds, $q <-! angular .module "dsc" .service "itemSvc"

svc = {
	# Items in separate arrays, grouped by type
	items : {}

	itemTypes : [\items \weapons \armors]

	itemIndex : []

	armorSetIndex : []

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

svc.loadArmorSetIndex = (force = false) !->
	if force or svc.armorSetIndex |> empty
		svc.armorSetIndex = $resource '/modules/items/content/armor-set-index.json' .query!
	return svc.armorSetIndex


svc.getFromIndexById = (id) -> svc.itemIndex |> find (.id == id)

svc.getFromIndexByUid = (uid) -> svc.itemIndex |> find (.uid == uid)


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

		if itemType == \material-sets
			svc.items[itemType] = result
		else
			for itemData in result
				svc.createItemFrom itemData
					.. |> svc.items[itemType].push

		def.resolve svc.items[itemType]

	return svc.items[itemType]


svc.createItemFrom = (itemData) ->
	(switch itemData.itemType
	| 'armor' => new svc.models.Armor
	| 'weapon' => new svc.models.Weapon
	| 'upgrade' => new svc.models.Upgrade
	| otherwise => new svc.models.Item
	) <<< itemData


svc.getUpgradeFor = (item, iteration) !->
	def = $q.defer!

	if item.upgradeId < 0
		def.resolve!
		return def.promise

	data = (if item.itemType == \armor then \armor-upgrades else \upgrades )

	svc.loadItemData data .$promise.then (upgradeData) !->
		upgrade = (upgradeData |> find (.id == item.upgradeId + iteration))
		def.resolve upgrade

	return def.promise


svc.getUpgradedVersionOf = (item, iteration) !->
	def = $q.defer!

	(svc.getUpgradeFor item, iteration).then (upgrade) !->
		if not upgrade? then return def.resolve null

			
		if item.itemType == \armor
			upArmor = new svc.models.Armor! <<< item
				..id += iteration
				..upgradeId = upgrade.id
				..name += " +#{iteration }" if iteration > 0
			
			for mapping in [
				[\defN \defModN]
				[\defSl \defModSl]
				[\defSt \defModSt]
				[\defTh \defModTh]
				[\defM \defModM]
				[\defF \defModF]
				[\defL \defModL]

				[\defT \defModT]
				[\defB \defModB]
				[\defC \defModC]
			]
				upArmor[mapping.0] = upArmor[mapping.0] * upgrade[mapping.1] |> Math.floor

			def.resolve upArmor
		else
			
			#console.log "Weapon is", weapon, ", upgrade is ", upgrade
	
			upWeapon = new svc.models.Weapon! <<< item
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


svc.getMaterialsForUpgrade = (item, upgrade) !->
	def = $q.defer!

	svc.loadItemData \material-sets .$promise.then (materialSets) !->
		matSet = materialSets |> find (.id == item.matSetId + upgrade.matSetId)

		def.resolve {} <<< matSet <<< upgrade

	return def.promise


svc.canUpgradeWithMaterials = (item, materials, iteration) ->
	var upgrade

	svc.getUpgradeFor item, iteration
	.then !->
		if not it? then return null
		upgrade := it
		return svc.getMaterialsForUpgrade item, upgrade
	.then (upgrade) !->
		#if item.name.substring(0, 7) == \Halberd
		#	console.log item, materials, iteration, upgrade
		if not upgrade?
			#console.log "Failed to get next upgrade for item ", item, "and iteration ", iteration
			return false

		#console.log "Upgrade needs ", upgrade.matId, "x", upgrade.matCost, "you have", (materials |> find (.id == upgrade.matId))

		# +6 items need Large Ember
		#console.log iteration, materials, $ItemIds
		if item.itemType == \weapon and iteration > 5 and not (materials |> any (.id == $ItemIds.\LargeEmber ))
			return false

		if upgrade.matId < 0 or upgrade.matCost < 0 #or upgrade.matId == $ItemIds.\TitaniteShard
			return true


		return materials |> any -> it.id == upgrade.matId and it.amount >= upgrade.matCost


svc.payForUpgradeFor = (item, materials, iteration) ->
	svc.getUpgradeFor item, iteration .then (upgrade) !->
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