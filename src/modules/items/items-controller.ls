$scope, dataExportSvc, itemSvc, uiGridConstants <-! angular.module "dsc" .controller "ItemsController"

### SETUP

$scope.itemTypes = []
for itemType in [\none \items \weapons \armors]
	$scope.itemTypes.push itemType

(require './config/items-grid-options') $scope, uiGridConstants


### EVENT HANDLERS

$scope.selectedItemTypeChanged = !->
	if $scope.selectedItemType == \none
		$scope.gridOptions.data = []
		$scope.gridOptions.columnDefs = []
		return

	itemSvc.loadItemData $scope.selectedItemType .$promise.then (itemData) !->
		if $scope.selectedItemType == \weapons
			for weapon in itemData
				itemSvc.applyUpgradeTo weapon, 0
		$scope.gridOptions.data = itemData

	$scope.gridOptions.columnDefs = $scope.columnConfigs[$scope.selectedItemType]

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

