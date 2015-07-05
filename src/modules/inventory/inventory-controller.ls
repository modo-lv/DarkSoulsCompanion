$scope, uiGridConstants, itemSvc, itemIndexSvc, storageSvc, inventorySvc <-! angular.module "dsc" .controller "InventoryController"

### SETUP

# Item that the user has selected in the auto-complete field
$scope.selectedItem = null

# Array containing every armor set from the index, for auto-complete
$scope.armorSets = []

# Array containing every item in the index, for auto-complete
$scope.allItems = []

$scope.itemTypes = [ \weapon \armor \item ]

$scope.gridOptions = (require './config/inventory-grid-opts') uiGridConstants


### LOAD DATA

$scope.allItems = itemIndexSvc.getAllEntries!

$scope.armorSets = itemIndexSvc.getAllArmorSetEntries!

$scope.gridOptions.data = inventorySvc.inventory


# Event handlers
$scope.addNewItem = (selection) !->
	$scope.addItem selection.originalObject

$scope.addItem = (item) !->
	inventorySvc.addToInventory item

$scope.removeItem = inventorySvc.removeFromInventory

$scope.addArmorSet = (selection) !->
	armorSet = selection.originalObject

	itemSvc.loadItemData \armors .$promise .then (armors) !->
		for id in armorSet.armors
			$scope.addItem (armors |> find (.id == id))
