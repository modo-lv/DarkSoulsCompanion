angular? .module "dsc" .service "itemIndexSvc" (externalDataSvc) ->
	new ItemIndexService externalDataSvc


class ItemIndexService
	(@externalDataSvc) ->
		@_index = []
		@_armorSetIndex = []


	clear : ~>
		@_index.length = 0
		delete @_index.$promise
		@_armorSetIndex.length = 0
		delete @_armorSetIndex.$promise
		return this


	/**
	 * Finds the first item matching a given filter.
	 * @param byFilter Function filter function that takes item as
	 * a parameter and returns true/false if it matches/doesn't.
	 * @returns Promise that resolves with the found value.
	 */
	findEntry : (byFilter) !~>
		if typeof byFilter != \function
			throw new Error "[byFilter] is not a function."
		return @loadAllEntries!.then ~> it |> find byFilter


	findEntries : (byFilter) !~>
		if typeof byFilter != \function
			throw new Error "[byFilter] is not a function."
		return @loadAllEntries!.then ~> it |> filter byFilter


	findArmorSetFor : (item) !~>
		return @loadAllArmorSetEntries!.then ~> it |> find (.uid == item.uid)


	findByArmorSet : (setName) !~>
		if typeof setName == \object
			setName = setName.name
		if typeof setName != \string
			throw new Error "Armor set name must be a string, or an object with string property [name]."
			
		return @loadAllArmorSetEntries!.then (sets) !~>
			armorIds = (sets |> find (.name == setName))?.armors
			return @findEntries (entry) -> armorIds |> any (== entry.id)


	loadAllArmorSetEntries : (returnPromise = true) !~>
		if not @_armorSetIndex.$promise?
			@_armorSetIndex = @externalDataSvc.loadJson '/modules/items/content/armor-set-index.json', false
		return if returnPromise then @_armorSetIndex.$promise else @_armorSetIndex


	loadAllEntries : (returnPromise = true) !~>
		if not @_index.$promise?
			@_index = @externalDataSvc.loadJson '/modules/items/content/index.json', false

		return if returnPromise then @_index.$promise else @_index


module?.exports = ItemIndexService