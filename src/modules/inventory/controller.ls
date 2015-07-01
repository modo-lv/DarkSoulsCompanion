$scope, uiGridConstants, itemService, storageService, inventoryService <-! angular.module "dsc" .controller "InventoryController"

# Initialize
itemService.loadItems!
inventoryService.loadInventory!

# Models
$scope.allItems = itemService.loadIdNameIndex!
$scope.selectedItem = null
$scope.inventory = inventoryService.items

# Grid
$scope.gridOptions = (require './controller/gridOptions')
	..data = $scope.inventory

# Event handlers
$scope.addItem = (item = $scope.selectedItem.originalObject) !->
	inventoryService.addToInventory item

$scope.removeItem = inventoryService.removeFromInventory

