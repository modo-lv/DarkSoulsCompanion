angular.module "dsc.services"
	.service "inventoryService", (itemService, storageService) -> self = {}
		..items = []


		..models = {
			\InventoryItem : class InventoryItem
				(@item, @amount = 1) ->
		}


		..getById = (id) ->	self.items |> find (.item.id == id)


		..getByItem = (item) -> self.items |> find (.item == item)


		..addToInventory = (item, amount = 1) !->
			existing = self.getByItem item
			if existing
				existing.amount += amount
			else
				self.items.push new self.models.InventoryItem item, amount

			self.saveInventory!


		..removeFromInventory = (item, amount = 1) !->
			entry = self.getByItem item

			entry.amount -= if amount == true then entry.amount else amount

			if entry.amount < 1
				self.items.splice (self.items.indexOf entry), 1

			self.saveInventory!


		..clearInventory = !->
			self.items.length = 0


		..loadInventory = (force) !->
			return unless force or self.items |> empty

			inventoryData = (storageService.load 'inventory') ? []

			..clearInventory!

			for entry in inventoryData
				item = itemService.getById entry.id
				self.addToInventory item, entry.amount


		..saveInventory = !->
			inventoryData = []
			for entry in self.items
				inventoryData.push {
					id : entry.item.id
					amount : entry.amount
				}

			storageService.save "inventory", inventoryData