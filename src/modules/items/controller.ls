angular.module "dsc-items"
	.controller "ItemsController", ($scope, dataExportService, itemService, uiGridConstants) !->
		itemService.loadItems!

		for itemType in [\items \materials \armors \keys \rings]
			$scope.[]itemTypes.push itemType

		(require './program/gridOptions') $scope, uiGridConstants

		$scope.selectedItemTypeChanged = !->
			$scope.gridOptions.data = itemService.items[$scope.selectedItemType]
			$scope.gridOptions.columnDefs = $scope.columnConfigs[$scope.selectedItemType]

		$scope.exportAsJson = !->
			dataExportService.exportJson ($scope.gridOptions.data |> map -> delete it.$$hashKey; return it)

		$scope.exportAsCsv = !->
			outputData = $scope.gridOptions.data |> map ->
				item = {} <<< it
				delete item.$$hashKey;
				return item
			dataExportService.exportCsv outputData

		$scope.selectedItemType = \items
		$scope.selectedItemTypeChanged!

