$scope, uiGridConstants, itemService, storageService, inventoryService <-! angular.module "dsc" .controller "InventoryController"

### SETUP

$scope.selectedItem = null
$scope.inventory = []

$scope.itemTypes = [ \weapon \armor \item ]

$scope.gridOptions = (require './controller/gridOptions') uiGridConstants


### LOAD DATA

($scope.allItems = itemService.loadItemIndex!).$promise.then !->
	#console.log 'Loading inventory...'
	$scope.gridOptions.data = $scope.inventory = inventoryService.loadUserInventory!

# Event handlers
$scope.addNewItem = (selection) !->
	$scope.addItem selection.originalObject

$scope.addItem = (item) !->
	inventoryService.addToInventory item

$scope.removeItem = inventoryService.removeFromInventory

