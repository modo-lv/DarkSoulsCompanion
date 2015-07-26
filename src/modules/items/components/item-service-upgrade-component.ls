class ItemServiceUpgradeComponent
	(@_itemSvc, @_externalDataSvc, @_itemIndexSvc, @$q) ->
		# Holds the upgrade data for weapons and armor
		@_upgrades = {}

		# Holds the material set info for upgrades
		@_materialSets = []


	clearUpgrades : !~>
		for type in [\weapon \armor]
			@_upgrades.[][type].length = 0
			delete @_upgrades.[type].$promise
		return this

	clearMaterialSets : !~>
		@_materialSets.length = 0
		delete @_materialSets.$promise
		return this


	getBaseIdFrom : (id) !~>
		return id - @getUpgradeLevelFrom id


	getUpgradeLevelFrom : (id) !~>
		return id % 100


	getBaseItemIdOf : (item) ~>
		@getBaseIdFrom item.id


	findBaseItem : (item) ~>
		@_itemSvc.findItem item.itemType, ~> (it.id == @getBaseIdFrom item.id)
		.then (baseItem) ~>
			if not baseItem?
				console.log baseItem
				throw new Error "Failed to find the base item for the above item."

			return baseItem


	/**
	 * Get the upgrade model for a given weapon at a given upgrade level
	 * @returns Promise, resolved with the upgrade (or null if nothing found)
	 */
	findUpgradeFor : (item, level) ~>
		@loadAllUpgrades item.itemType .then (upgrades) ~>
			if item.matSetId < 0
				return null
			#console.log "upgrades |> find ~> (it.id == #{@getBaseIdFrom(item.upgradeId)} + #{level})"
			upgrades |> find ~> (it.id == @getBaseIdFrom(item.upgradeId) + level)


	/**
	 * Find the materials required to upgrade a given item using a given upgrade model.
	 * @returns Promise that is resolved with the material data.
	 */
	findUpgradeMaterialsFor : (item, upgrade) !~>
		if not (item? and upgrade?)
			throw new Error "Can't find upgrade materials, either item or upgrade is unset."

		if item.matSetId < 0 then
			@$q.defer!
				..resolve null
				return ..promise

		return @loadAllMaterialSets!.then ~>
			@_materialSets |> find ~> (it.id == @getBaseIdFrom(item.matSetId) + upgrade.matSetId)




	/**
	 * Asynchronously loads all information on material sets required for upgrades
	 * @returns Promise that will be resolved with the material set data.
	 */
	loadAllMaterialSets : !~>
		if not @_materialSets.$promise?
			@_materialSets = @_externalDataSvc.loadJson "/modules/items/content/material-sets.json", false

		return @_materialSets.$promise


	/**
	 * Load information on all upgrades for a given item type
	 * @returns Promise resolved with the upgrade data
	 */
	loadAllUpgrades : (itemType) ~>
		itemType |> @ensureItCanBeUpgraded

		if not @_upgrades.[][itemType].$promise?
			@_upgrades.[itemType] = @_externalDataSvc.loadJson "/modules/items/content/#{itemType}-upgrades.json", false

		return @_upgrades.[itemType].$promise


	ensureItCanBeUpgraded : (item) !~>
		if not item?
			throw new Error "Item / item type not provided."
		if typeof item == \string
			item = { itemType : item }
		if not (item |> @canBeUpgraded)
			throw new Error "Only weapons and armors can be upgraded, this is a [#{item.itemType}]."


	upgradeLevelOf : (item) ~>
		item.id % 100


	isUpgraded : (item) ~>
		(@upgradeLevelOf item) > 0


	canBeUpgraded : (item) ~>
		item.itemType == \weapon or item.itemType == \armor


	canBeUpgradedFurther : (item) ~>
		if (not @canBeUpgraded item) or item.weaponType == \Magic or item.matSetId < 0 or item.upgradeId < 0
			return false

		return @findUpgradeFor item, (@upgradeLevelOf item) + 1
			.then (upgrade) ~>
				if @_debugLog and not upgrade?
					console.log "Failed to find an upgrade for item (id: #{item.id}) at level #{@upgradeLevelOf item}"
				upgrade?


	apply : (upgrade) ~>
		if not upgrade?
			throw new Error "No upgrade data provided."
		to : (item) !~>
			item |> @ensureItCanBeUpgraded

			item
				..id += (upgrade.\id % 100)
				..upgradeId = upgrade.\id
				..matSetId += upgrade.\matSetId

			if item.def? then for value, index in item.def
				item.def[index] *= (upgrade.defMod[index] ? 1)

			switch item.\itemType
			| \weapon =>
				if item.atk? then for value, index in item.atk
					item.atk[index] *= upgrade.atkMod[index] ? 1

				if item.bonus? then for value, index in item.bonus
					item.bonus[index] *= upgrade.bonusMod[index] ? 1

			| \armor =>
				if item.defPhy? then for value, index in item.defPhy
					item.defPhy[index] *= (upgrade.defPhyMod[index] ? 1)

			return item



module?.exports = ItemServiceUpgradeComponent