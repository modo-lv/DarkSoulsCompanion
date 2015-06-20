angular.module "dsc-inventory"
	.controller "InventoryController", ($scope, storageService, uiGridConstants) !->
		$scope.items = storageService.load 'inventory' ? []


		(require './program/gridOptions.ls') $scope, uiGridConstants