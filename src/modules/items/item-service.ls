angular? .module "dsc" .service "itemSvc" (externalDataSvc, itemIndexSvc, inventorySvc, $q) -> new ItemService ...

class ItemService

	(@_externalDataSvc, @_itemIndexSvc, @_inventorySvc, @$q) ->
		@.upgradeComp = new (require './components/item-service-upgrade-component')

		@.upgradeComp.@@.apply @.{}upgradeComp, [this] ++ (& |> map -> it)

		# Item data storage containing
		@_storage = {}

		@_models = require './models/item-models'


	clear : !~>
		@_storage = {}
		return this


	/**
	 * Return the first item matching a given filter
	 * @param itemType String type of item to find.
	 * @param filterFn Function Filter function
	 * @return Promise that resolves with the found item, or null if nothing found.
	 */
	findItem : (itemType, filterFn) ~>
		if typeof itemType != \string
			throw new Error "Item type is invalid or not provided"
		@loadAllItems itemType .then (items) ~>
			item = items |> find filterFn
			return item


	/**
	 * Finds any item, regardless of type, but can only
	 * check fields that are in the index.
	 */
	findAnyItem : (filterFn) ~>
		@_itemIndexSvc.findEntry filterFn
		.then (item) !~>
			if @upgradeComp.isUpgraded item
				baseId = @upgradeComp.getBaseIdFrom item.id
				upLevel = @upgradeComp.getUpgradeLevelFrom item.id
				#console.log "Base ID: #{baseId}, upLevel: #{upLevel}"
				return ((item, baseId, upLevel) ~>
					@findItem item.itemType, (.id == baseId)
					.then (baseItem) ~> @getUpgraded baseItem, upLevel
					) item,baseId,upLevel
			else
				return @findItem item.itemType, (.id == item.id)


	/**
	 * Filter inventory entries by a given filter and then return the real item data
	 * for them.
	 */
	findRealItems : (byFilter) ~>
		@_inventorySvc.load true, false
		.then (inventory) !~>
			inventory = inventory |> filter byFilter

			promises = []
			for itemEntry in inventory
				let itemEntry = itemEntry
					promises.push @.findItem itemEntry.itemType, (.id == itemEntry.id)

			return @$q.all promises

	findRealItemsByType : (type) ~>
		@findRealItems (.itemType == type)

	/**
	 * Create a model from given item data
	 */
	createItemModelFrom : (data) ~>
		(switch data.itemType
		| \weapon => new @_models.Weapon
		| \armor => new @_models.Armor
		| \item => new @_models.Item
		| otherwise => throw new Error "Cannot create item model from data with .itemType == #{data.itemType}."
		).useDataFrom(data)


	/**
	 * Load item data of a given item type.
	 * @returns Promise or populated array, depending on returnPromise setting.
	 */
	loadAllItems : (itemType, returnPromise = true) !~>
		if not @_storage.[][itemType].$promise?
			@_storage.[itemType].$promise =
				test = @_externalDataSvc.loadJson "/modules/items/content/#{itemType}s.json"
				.then (itemData) !~>
					itemData |> each !~> @_storage.[][itemType].push @createItemModelFrom it
					return @_storage.[itemType]

		return if returnPromise then @_storage.[itemType].$promise else @_storage.[itemType]



	getUpgraded : (item, level = true) ~>
		if level == true
			level = item.upgradeId + 1
		@upgradeComp.findUpgradeFor item, level
		.then (upgrade) !~>
			if not upgrade?
				#console.warn "Failed to find upgrade at level #{level} for item", item
				return null

			return (item |> @upgradeComp.findBaseItem)
			.then (baseItem) ~>
				@createItemModelFrom baseItem
			.then (newItem) ~>
				@upgradeComp .apply upgrade .to newItem
			.then (newItem) ~>
				@_itemIndexSvc.findEntry (.uid == newItem.uid)
				.then (entry) ~>
					newItem.name = entry.name
					return newItem
			.then (newItem) ~>
				if newItem.itemType == \armor
					newItem.armorSet = (@_itemIndexSvc.findArmorSetFor newItem).name
				return newItem



module?.exports = ItemService