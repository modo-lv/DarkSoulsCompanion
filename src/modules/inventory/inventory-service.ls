angular? .module "dsc" .service "inventorySvc" (storageSvc, itemIndexSvc) ->
	new InventorySvc storageSvc, itemIndexSvc

class InventorySvc

	(@storageSvc, @itemIndexSvc) ->
		@_inventory = []
		@_models = require './models/inventory-models'


	inventory :~ -> @load false


	save : !~>
		data = []
		for item in @inventory
			data.push {
				\uid : item.uid
				\amount : item.amount
			}
		@storageSvc.save 'inventory', data


	load : (force = true) !~>
		if force or @_inventory |> empty
			@clear!
			@storageSvc.load 'inventory'
			|> each (item) !~> @_inventory.push(new @_models.InventoryItem item)

			for invItem in @_inventory
				((ii) !~> ii.$promise =
					@itemIndexSvc.findEntry (.uid == ii.uid)
					.then (item) -> ii.useDataFrom item
				)(invItem)

		return @_inventory


	findItemByUid : (uid) ~>
		@inventory |> find (.uid == uid)


	find : (item) ~>
		@findItemByUid item.uid


	add : (item, amount = item.amount ? 1) !~>
		existing = @find item
		if existing
			existing.amount += amount
		else
			new @_models.InventoryItem
				..useDataFrom item
				..amount = amount
				.. |> @inventory.push

		@save!


	remove : (item, amount = 1) !~>
		entry = @find item
		if not entry?
			console.log item
			throw new Error "Failed to remove the above item because couldn't find it in the inventory."

		entry.amount = if amount == true then 0 else entry.amount -= amount

		if entry.amount < 1
			@inventory.splice (@inventory.indexOf entry), 1

		@save!


	clear : !~>
		@_inventory.length = 0



module?.exports = InventorySvc