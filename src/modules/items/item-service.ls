angular? .module "dsc" .service "itemSvc" (externalDataSvc, itemIndexSvc, itemUpgradeSvc) ->
	new ItemService externalDataSvc, itemIndexSvc, itemUpgradeSvc


class ItemService

	(@_externalDataSvc, @_itemIndexSvc, @_itemUpgradeSvc) ->
		# Item data storage containing
		@_storage = {}

		@_models = require './models/item-models'


	clear : !~>
		@_storage = {}


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


	findBaseItem : (item) ~>
		@findItem item.itemType, ~> (it.id == @_itemUpgradeSvc.getBaseIdFrom item.id)


	/**
	 * Finds any item, regardless of type, but can only
	 * check fields that are in the index.
	 */
	findAnyItem : (filterFn) ~>
		@_itemIndexSvc.findEntry filterFn
		.then (item) !~>
			if @_itemUpgradeSvc.isUpgraded item
				baseId = @_itemUpgradeSvc.getBaseIdFrom item.id
				upLevel = @_itemUpgradeSvc.getUpgradeLevelFrom item.id
				#console.log "Base ID: #{baseId}, upLevel: #{upLevel}"
				return ((item, baseId, upLevel) ~>
					@findItem item.itemType, (.id == baseId)
					.then (baseItem) ~> @getUpgraded baseItem, upLevel
					) item,baseId,upLevel
			else
				return @findItem item.itemType, (.id == item.id)


	/**
	 * Create a model from given item data
	 */
	createItemModel : (data) ~>
		(switch data.itemType
		| \weapon => new @_models.Weapon
		| \armor => new @_models.Armor
		| \item => new @_models.Item
		| otherwise => throw new Error "[#{data.itemType}] is not a recognized item type."
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
					itemData |> each !~> @_storage.[][itemType].push @createItemModel it
					return @_storage.[itemType]

		return if returnPromise then @_storage.[itemType].$promise else @_storage.[itemType]



	getUpgraded : (item, level = true) ~>
		if level == true
			level = item.upgradeId + 1
		@_itemUpgradeSvc.findUpgradeFor item, level
		.then (upgrade) !~>
			if not upgrade?
				#console.warn "Failed to find upgrade at level #{level} for item", item
				return null

			return (item |> @findBaseItem)
			.then (baseItem) ~>
				@createItemModel baseItem
			.then (newItem) ~>
				@_itemUpgradeSvc .apply upgrade .to newItem
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