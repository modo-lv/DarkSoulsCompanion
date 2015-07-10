angular? .module "dsc" .service "inventorySvc" (storageSvc, itemIndexSvc, $q) ->
	new InventorySvc ...

class InventorySvc

	(@_storageSvc, @_itemIndexSvc, @$q) ->
		@_inventory = []
		@_models = require './models/inventory-models'


	save : !~>
		data = []
		for item in @_inventory
			data.push {
				\uid : item.uid
				\amount : item.amount
			}
		@_storageSvc.save 'inventory', data


	load : (returnPromise = true, createModels = true) !~>
		if not @_inventory.$promise?
			@clear!
			promises = []
			raw = @_storageSvc.load 'inventory'
			if createModels
				for data in @_storageSvc.load 'inventory'
					promise = ((data) ~>
						item = new @_models.InventoryItem data
						@_itemIndexSvc.findEntry (.uid == data.uid)
						.then (indexEntry) !~>
							item.useDataFrom indexEntry
							@_inventory.push item
							return item
					) data

					promises.push promise

				@_inventory.$promise = @$q.all promises .then ~> @_inventory
			else
				@_inventory = raw
					..$promise = do !~>
						@$q.defer!
							..resolve @_inventory
							return ..promise

		return if returnPromise then @_inventory.$promise else @_inventory


	findItemByUid : (uid) ~>
		@load!.then (inventory) ~>
			inventory |> find (.uid == uid)


	createInventoryItemFrom : (item, amount = 1) ~>
		new @_models.InventoryItem
			..useDataFrom item
			..amount = amount


	add : (item, amount = 1) ~>
		@findItemByUid item.uid
		.then (invItem) !~>
			if invItem?
				invItem.amount += amount
			else
				invItem = @createInventoryItemFrom item, amount
					.. |> @_inventory.push

			@save!
			return invItem


	remove : (item, amount = 1) ~>
		@findItemByUid item.uid
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