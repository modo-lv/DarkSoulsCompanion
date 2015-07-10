$scope, uiGridConstants, statSvc, itemSvc, itemIndexSvc, storageSvc, inventorySvc, dataExportSvc <-! angular.module "dsc" .controller "pcController"

$scope.model = statSvc.loadUserData!

$scope.saveStats = !-> statSvc.saveUserData $scope.model

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

$scope.allItems = itemIndexSvc.loadAllEntries false

$scope.armorSets = itemIndexSvc.loadAllArmorSetEntries false

$scope.gridOptions.data = inventorySvc.load false


# Event handlers
$scope.export = !->


$scope.canUpgrade = (item) !->
	return item |> itemSvc.upgradeComp.canBeUpgraded
	
$scope.upgrade = (invEntry) ->
	itemSvc.findAnyItemByUid(invEntry.uid)
	.then (item) ->
		itemSvc.getUpgraded item
	.then (upItem) !->
		if not upItem? then return
		$scope.remove invEntry
		$scope.add upItem

$scope.addNewItem = (selection) !->
	$scope.add selection.originalObject

$scope.add = inventorySvc.add

$scope.remove = inventorySvc.remove

$scope.addArmorSet = (selection) !->
	armorSet = selection.originalObject

	itemIndexSvc.findByArmorSet armorSet
	.then (armors) !-> armors |> each $scope.add
