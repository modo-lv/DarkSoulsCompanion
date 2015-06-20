angular.module "dsc-inventory"
	.controller "InventoryController", (
		$scope,
		uiGridConstants,
		itemService,
		storageService,
		inventoryService
	) !->
		# Initialize
		itemService.loadItems!
		inventoryService.loadInventory!

		# Models
		$scope.allItems = itemService.allItems
		$scope.selectedItem = null
		$scope.inventory = inventoryService.items

		# Grid
		$scope.gridOptions = (require './program/gridOptions.ls')
			..data = $scope.inventory

		# Event handlers
		$scope.addItem = (itemName = $scope.selectedItem.title) !->
			inventoryService.addToInventory itemName

		$scope.removeItem = inventoryService.removeFromInventory
		$scope.removeAllOf = (itemName) !-> inventoryService.removeFromInventory itemName, true

