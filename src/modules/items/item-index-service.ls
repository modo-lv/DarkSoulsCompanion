angular? .module "dsc" .service "itemIndexSvc" (externalDataSvc) ->
	new ItemIndexService externalDataSvc


class ItemIndexService
	(@externalDataSvc) ->
		@_index = []
		@_armorSetIndex = []


	/**
	 * Finds the first item matching a given filter.
	 * @param byFilter Function filter function that takes item as
	 * a parameter and returns true/false if it matches/doesn't.
	 * @returns Promise that resolves with the found value.
	 */
	findEntry : (byFilter) ~>
		if typeof byFilter != \function
			throw new Error "[byFilter] is not a function."
		@getAllEntries!.then ~> it |> find byFilter


	getAllArmorSetEntries : (returnPromise = true) !~>
		if not @_armorSetIndex.$promise?
			@_armorSetIndex = @externalDataSvc.loadJson '/modules/items/content/armor-set-index.json', false
		return if returnPromise then @_armorSetIndex.$promise else @_armorSetIndex


	getAllEntries : (returnPromise = true) !~>
		if not @_index.$promise?
			@_index = @externalDataSvc.loadJson '/modules/items/content/index.json', false

		return if returnPromise then @_index.$promise else @_index


module?.exports = ItemIndexService