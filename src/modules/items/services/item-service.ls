angular? .module "dsc" .service "itemSvc" (externalDataService) ->
	new ItemService externalDataService


class ItemService

	(@_externalDataSvc) ->
		# Item data storage containing
		@_storage = {}

		# An item index containing all item IDs, names and types
		@_index = {}

	/**
	 * Return the first item matching a given filter
	 * @param func Function Filter function
	 * @return Promise that resolves with the found item, or null if nothing found.
	 */
	findItem : (itemType, filterFn) ~>
		@getItems itemType .then (items) ~>
			items |> find filterFn


	/**
	 * Load item data of a given item type.
	 * @returns Promise or asynchronously populated array, depending on returnPromise setting.
	 */
	getItems : (itemType, returnPromise = true) !~>
		if not @_storage.[][itemType].$promise?
			@_storage.[itemType] = @_externalDataSvc.loadJson "/modules/items/content/#{itemType}s.json", false
		return if returnPromise then @_storage.[itemType].$promise else @_storage.[itemType]


module?.exports = ItemService