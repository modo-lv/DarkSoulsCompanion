$scope, uiGridConstants, itemService, storageService, inventoryService <-! angular.module "dsc" .controller "InventoryController"

### SETUP

$scope.selectedItem = null
$scope.inventory = []

$scope.gridOptions = require './controller/gridOptions'


### LOAD DATA

($scope.allItems = itemService.loadItemIndex!).$promise.then !->
	#console.log 'Loading inventory...'
	$scope.gridOptions.data = $scope.inventory = inventoryService.loadUserInventory!

# Event handlers
$scope.addItem = (item = $scope.selectedItem.originalObject) !->
	inventoryService.addToInventory item

$scope.removeItem = inventoryService.removeFromInventory

