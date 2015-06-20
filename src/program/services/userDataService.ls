angular.module "dsc.services"
	.service "userDataService", (storageService, itemService) -> {
		loadInventory : !->
			invData = storageService.load 'UserData.Inventory' ? []
			inventory = []
			for name in invData
				inventory.push itemService.findItem
	}