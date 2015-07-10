$scope, dataExportSvc, itemSvc, uiGridConstants <-! angular.module "dsc" .controller "ItemsController"

### SETUP

$scope.itemTypes = []
for itemType in [\none \item \weapon \armor]
	$scope.itemTypes.push itemType

(require './config/items-grid-options') $scope, uiGridConstants


### EVENT HANDLERS

$scope.selectedItemTypeChanged = !->
	if $scope.selectedItemType == \none
		$scope.gridOptions.data = []
		$scope.gridOptions.columnDefs = []
		return

	$scope.gridOptions.columnDefs = $scope.columnConfigs[$scope.selectedItemType]

	itemSvc.loadAllItems $scope.selectedItemType .then (itemData) !->
		if $scope.selectedItemType == \weapon
			for weapon in itemData
				#console.log weapon.atkPhy, weapon.atkStaCost, weapon.dpsPhy
				let weapon = weapon
					itemSvc.getUpgraded weapon, 0
					.then (up) !->
						weapon <<< up
		$scope.gridOptions.data = itemData


$scope.exportAsJson = !->
	dataExportSvc.exportJson ($scope.gridOptions.data |> map -> delete it.$$hashKey; return it)

$scope.exportAsCsv = !->
	outputData = $scope.gridOptions.data |> map ->
		item = {} <<< it
		delete item.$$hashKey;
		return item
	dataExportSvc.exportCsv outputData


### INIT

$scope.selectedItemType = \none

#$scope.selectedItemTypeChanged!

