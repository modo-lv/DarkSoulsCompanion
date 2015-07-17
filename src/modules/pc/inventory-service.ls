angular? .module "dsc" .service "inventorySvc" (storageSvc, itemIndexSvc, notificationSvc, $q) ->
	new InventorySvc ...

class InventorySvc

	(@_storageSvc, @_itemIndexSvc, @_notificationSvc, @$q) ->
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


	load : (returnPromise = true) !~>
		if not @_inventory.$promise?
			@clear!
			promises = []
			for data in (@_storageSvc.load 'inventory') ? []
				promise = ((data) ~>
					item = new @_models.InventoryItem data
					@_itemIndexSvc.findEntryByUid(data.uid)
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


	createInventoryItemFrom : (item, amount = 1) ~>
		new @_models.InventoryItem
			..useDataFrom item
			..amount = amount


	addAll : (items) ~>
		invEntries = items |> map ~> if not it.amount? then { item : it, amount : 1 } else it

		promises = []

		for entry in invEntries
			promises.push @add entry.item, entry.amount, false
		@$q.all promises .then !~>
			itemList = invEntries
				|> map ~> "#{if it.amount > 1 then it.amount + " of " else ""}<strong>#{it.item.name}</strong>"
				|> join ', '

			@_notificationSvc.addInfo "Added #{itemList} to the inventory."


	hasItemWithName : (name) ~>
		@load! .then ~> it |> any (.name == name)


	addAllByName : (namesAndAmounts) ~>
		promises = []
		for entry in namesAndAmounts
			let entry = entry
				promises.push @addByName entry.name, entry.amount, false

		@$q.all promises .then (items) !~>
			itemList = items
				|> filter ~> it?
				|> map ~> "<strong>#{it.name}</strong>"
				|> join ', '

			if itemList.length > 0
				@_notificationSvc.addInfo "Added #{itemList} to the inventory."


	addByName : (itemName, amount = 1, notify = true) ~>
		@_itemIndexSvc.findEntryByName itemName
		.then (item) ~>
			if not item? then
				@_notificationSvc.addError "Could not find item named '<strong>#{itemName}</strong>', cannot add to inventory."
				return null
			@add item, amount, notify


	add : (item, amount = 1, notify = true) ~>
		@findItemByUid item.uid
		.then (invItem) !~>
			if invItem?
				invItem.amount += amount
			else
				invItem = @createInventoryItemFrom item, amount
					.. |> @_inventory.push

			if notify
				@_notificationSvc.addInfo "Added #{if amount > 1 then amount + " of " else ""}<strong>#{invItem.name}</strong> to the inventory."

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