class InventoryItemModel
	(item) ->
		@amount = 1
		@name = ''
		@itemType = null
		@id = ''
		@uid = ''

		@useDataFrom item


	useDataFrom : (item) !~>
		if not item? then return

		for field in [\amount \uid \name \itemType \id]
			if item.[field]?
				@.[field] = item.[field]

		return this


module?.exports =
	\InventoryItem : InventoryItemModel