angular? .module "dsc" .service "inventorySvc" (storageSvc, itemIndexSvc, $q) ->
	new InventorySvc storageSvc, itemIndexSvc, $q

class InventorySvc

	(@storageSvc, @itemIndexSvc, @$q) ->
		@_inventory = []
		@_models = require './models/inventory-models'


	save : !~>
		data = []
		for item in @_inventory
			data.push {
				\uid : item.uid
				\amount : item.amount
			}
		@storageSvc.save 'inventory', data


	load : (returnPromise = true) !~>
		if not @_inventory.$promise?
			@clear!
			promises = []
			for data in @storageSvc.load 'inventory'
				promise = ((data) ~>
					item = new @_models.InventoryItem data
					@itemIndexSvc.findEntry (.uid == data.uid)
					.then (indexEntry) !~>
						item.useDataFrom indexEntry
						@_inventory.push item
						return item
				) data

				promises.push promise

			@_inventory.$promise = @$q.all promises .then ~> @_inventory

		return if returnPromise then @_inventory.$promise else @_inventory


	findItemByUid : (uid) ~>
		@load!.then (inventory) ~>
			inventory |> find (.uid == uid)


	find : (item) ~>
		if not item.uid?
			throw new Error "Can't find an item without UID."
		@findItemByUid item.uid


	createInventoryItemFrom : (item, amount = 1) ~>
		new @_models.InventoryItem
			..useDataFrom item
			..amount = amount


	add : (item, amount = 1) ~>
		@find item
		.then (invItem) !~>
			if invItem?
				invItem.amount += amount
			else
				invItem = @createInventoryItemFrom item, amount
					.. |> @_inventory.push

			@save!
			return invItem


	remove : (item, amount = 1) ~>
		@find item
		.then (entry) !~>
			if not entry?
				throw new Error "Failed to remove the above item because couldn't find it in the inventory."

			entry.amount = if amount == true then 0 else entry.amount -= amount

			if entry.amount < 1
				@_inventory.splice (@_inventory.indexOf entry), 1

			@save!
			return entry



	clear : !~>
		@_inventory.length = 0
		delete @_inventory.$promise
		return this



module?.exports = InventorySvc