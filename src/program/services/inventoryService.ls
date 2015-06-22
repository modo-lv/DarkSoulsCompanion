angular.module "dsc.services"
	.service "inventoryService", (itemService, storageService) -> self = {}
		..items = []


		..models = {
			\InventoryItem : class InventoryItem
				(@item, @amount = 1) ->
		}


		..addToInventory = (itemName) !->
			if not itemService.itemExists itemName
				throw new Error "There is no item with the name '#{itemName }' in the database."
			existing = self.items |> find (.name == itemName)
			if existing
				existing.amount++
			else
				self.items.push new InventoryItem itemName

			self.saveInventory!


		..removeFromInventory = (itemName, amount = 1) !->
			item = self.items |> find (.name == itemName)
			if not item? then return

			item.amount -= if amount == true then item.amount else amount

			if item.amount < 1
				self.items.splice self.items.indexOf(item), 1

			self.saveInventory!


		..loadInventory = (force) !->
			return unless force or self.items.length < 1
			self.items = (storageService.load 'inventory') ? []


		..saveInventory = !->
			storageService.save "inventory", self.items