$scope, dataExportService, itemService, uiGridConstants <-! angular.module "dsc" .controller "ItemsController"

### SETUP

$scope.itemTypes = []
for itemType in [\none \items \weapons \armors]
	$scope.itemTypes.push itemType

(require './controller/gridOptions') $scope, uiGridConstants


### EVENT HANDLERS

$scope.selectedItemTypeChanged = !->
	if $scope.selectedItemType == \none
		$scope.gridOptions.data = []
		$scope.gridOptions.columnDefs = []
		return

	$scope.gridOptions.columnDefs = $scope.columnConfigs[$scope.selectedItemType]
	$scope.gridOptions.data = itemService.loadItems $scope.selectedItemType

$scope.exportAsJson = !->
	dataExportService.exportJson ($scope.gridOptions.data |> map -> delete it.$$hashKey; return it)

$scope.exportAsCsv = !->
	outputData = $scope.gridOptions.data |> map ->
		item = {} <<< it
		delete item.$$hashKey;
		return item
	dataExportService.exportCsv outputData


### INIT

$scope.selectedItemType = \none

#$scope.selectedItemTypeChanged!

