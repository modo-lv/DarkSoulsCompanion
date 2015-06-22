angular.module "dsc.services"
	.service "inventoryService", (itemService, storageService) -> self = {}
		..items = []


		..models = {
			\InventoryItem : class InventoryItem
				(itemName, @amount = 1) ->
					@item = itemService.getItemByFullName itemName
		}


		..getInventoryItemByFullName = (itemName) ->
			self.items |> find (.item.fullName == itemName) ?
				throw new Error "Inventory does not contain [#{itemName }]."


		..addToInventory = (itemName, amount = 1) !->
			existing = self.getInventoryItemByFullName itemName
			if existing
				existing.amount += amount
			else
				self.items.push new self.models.InventoryItem itemName, amount

			self.saveInventory!


		..removeFromInventory = (itemName, amount = 1) !->
			item = self.getInventoryItemByFullName itemName

			item.amount -= if amount == true then item.amount else amount

			if item.amount < 1
				self.items.splice self.items.indexOf(item), 1

			self.saveInventory!


		..clearInventory = !->
			self.items.length = 0


		..loadInventory = (force) !->
			return unless force or self.items.length < 1

			inventoryData = (storageService.load 'inventory') ? []

			..clearInventory

			for item in inventoryData
				self.addToInventory item.name, item.amount


		..saveInventory = !->
			inventoryData = []
			for inventoryItem in self.items
				inventoryData.push {
					name : inventoryItem.item.fullName
					amount : inventoryItem.amount
				}

			storageService.save "inventory", inventoryData