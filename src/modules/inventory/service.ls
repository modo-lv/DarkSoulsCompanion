$q, itemService, storageService <-! angular.module "dsc" .service "inventoryService"

svc = {}

svc.items = []

svc.models = {
	\InventoryItem : class InventoryItem
		(@amount = 1) ->
			@id = 0
			@name = ''
			@itemType = ''
}


svc.getById = (uid) -> svc.[]items |> find (.uid == uid)


svc.getByItem = (item) -> svc.getById item.uid


svc.addToInventory = (item, amount = 1) !->
	existing = svc.getByItem item
	if existing
		existing.amount += amount
	else
		new svc.models.InventoryItem amount
			..id = item.id
			.. |> svc.[]items.push

	svc.saveInventory!


svc.removeFromInventory = (item, amount = 1) !->
	entry = svc.getByItem item

	entry.amount -= if amount == true then entry.amount else amount

	if entry.amount < 1
		svc.[]items.splice (svc.[]items.indexOf entry), 1

	svc.saveInventory!


svc.clearInventory = !->
	svc.[]items.length = 0


svc.loadUserInventory = (force) !->
	return svc.items unless force or svc.[]items |> empty

	index = itemService.loadItemIndex!

	defer = $q.defer!
	svc.items = []
		..$promise = defer.promise

	index.$promise.then !->
		inventoryData = (storageService.load 'inventory') ? []

		svc.clearInventory!

		for entry in inventoryData
			new svc.models.InventoryItem entry.amount
				.. <<< itemService.getFromIndexById entry.id
				.. |> svc.items.push

		defer.resolve!

	return svc.items


svc.saveInventory = !->
	inventoryData = []
	for entry in svc.[]items
		inventoryData.push {
			id : entry.id
			amount : entry.amount
		}

	storageService.save "inventory", inventoryData


return svc