angular.module "dsc-items"
	.controller "ItemsController", ($scope, dataExportService, itemService, uiGridConstants) !->
		itemService.loadItems!

		for itemType in [\items \materials \armors \keys \rings]
			$scope.[]itemTypes.push itemType

		(require './program/gridOptions.ls') $scope, uiGridConstants

		$scope.selectedItemTypeChanged = !->
			$scope.gridOptions.data = itemService.items[$scope.selectedItemType]
			$scope.gridOptions.columnDefs = $scope.columnConfigs[$scope.selectedItemType]

		$scope.exportAsJson = !->
			dataExportService.exportJson ($scope.gridOptions.data |> map -> delete it.$$hashKey; return it)

		$scope.selectedItemType = \items
		$scope.selectedItemTypeChanged!

