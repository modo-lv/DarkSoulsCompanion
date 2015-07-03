$scope, uiGridConstants, itemService, storageService, inventoryService <-! angular.module "dsc" .controller "InventoryController"

### SETUP

$scope.selectedItem = null
$scope.inventory = []
$scope.armorSets = []

$scope.itemTypes = [ \weapon \armor \item ]

$scope.gridOptions = (require './controller/gridOptions') uiGridConstants


### LOAD DATA

($scope.allItems = itemService.loadItemIndex!).$promise.then !->
	#console.log 'Loading inventory...'
	$scope.gridOptions.data = $scope.inventory = inventoryService.loadUserInventory!

$scope.armorSets = itemService.loadArmorSetIndex!

# Event handlers
$scope.addNewItem = (selection) !->
	$scope.addItem selection.originalObject

$scope.addItem = (item) !->
	inventoryService.addToInventory item

$scope.removeItem = inventoryService.removeFromInventory

$scope.addArmorSet = (selection) !->
	armorSet = selection.originalObject

	itemService.loadItemData \armors .$promise .then (armors) !->
		for id in armorSet.armors
			$scope.addItem (armors |> find (.id == id))
