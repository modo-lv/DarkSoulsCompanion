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


svc.getById = (id) -> svc.[]items |> find (.id == id)


svc.getByItem = (item) -> svc.getById item.id


svc.addToInventory = (item, amount = 1) !->
	existing = svc.getByItem item
	if existing
		existing.amount += amount
	else
		svc.[]items.push new svc.models.InventoryItem item.id, item.name, amount

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