angular.module "dsc-items"
	.controller "ItemsController", ($scope, dataExportService, uiGridConstants) !->
		for itemType in [\items \materials \armors \keys \rings]
			$scope.{}itemData[itemType] = []
			$scope.[]itemTypes.push itemType

		$scope.selectedItemTypeChanged = !->
			$scope.gridOptions.data = $scope.itemData[$scope.selectedItemType]
			$scope.gridOptions.columnDefs = $scope.columnConfigs[$scope.selectedItemType]

		(require './program/loadItems.ls') $scope

		$scope.exportAsJson = !->

			dataExportService.exportJson ($scope.gridOptions.data |> map -> delete it.$$hashKey; return it)

		(require './program/gridOptions.ls') $scope, uiGridConstants

		$scope.selectedItemType = \items
		$scope.selectedItemTypeChanged!

