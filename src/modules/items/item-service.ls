angular? .module "dsc" .service "itemSvc" (externalDataSvc, itemIndexSvc) ->
	new ItemService externalDataSvc, itemIndexSvc


class ItemService

	(@_externalDataSvc, @_itemIndexSvc) ->
		# Item data storage containing
		@_storage = {}

		@_models = require './models/item-models'


	/**
	 * Return the first item matching a given filter
	 * @param itemType String type of item to find.
	 * @param func Function Filter function
	 * @return Promise that resolves with the found item, or null if nothing found.
	 */
	findItem : (itemType, filterFn) ~>
		if typeof itemType != \string
			throw new Error "Item type is invalid or not provided"
		@getAllItems itemType .then (items) ~>
			items |> find filterFn


	/**
	 * Finds any item, regardless of type, but can only
	 * check fields that are in the index.
	 */
	findAnyItem : (filterFn) ~>
		@_itemIndexSvc.findItem filterFn
		.then (item) ~> @findItem item.itemType, (.id == item.id)


	/**
	 * Load item data of a given item type.
	 * @returns Promise or populated array, depending on returnPromise setting.
	 */
	getAllItems : (itemType, returnPromise = true) !~>
		if not @_storage.[][itemType].$promise?
			@_storage.[itemType].$promise =
				@_externalDataSvc.loadJson "/modules/items/content/#{itemType}s.json"
				.then (itemData) !~>
					for data in itemData
						(switch data.itemType
						| \weapon => new @_models.Weapon
						| \armor => new @_models.Armor
						| \item => new @_models.Item
						| otherwise => throw new Error "[#{data.itemType}] is not a recognized item type."
						).useDataFrom(data) |> @_storage.[][itemType].push
					return @_storage.[itemType]

		return if returnPromise then @_storage.[itemType].$promise else @_storage.[itemType]


module?.exports = ItemService