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
		$scope.gridOptions = (require './program/gridOptions')
			..data = $scope.inventory

		# Event handlers
		$scope.addItem = (item = $scope.selectedItem.originalObject) !->
			inventoryService.addToInventory item

		$scope.removeItem = inventoryService.removeFromInventory
		$scope.removeAllOf = (itemName) !-> inventoryService.removeFromInventory itemName, true

