angular?.module "dsc" .controller "mainController" ($scope, $location) ->
	new MainController $scope, $location

class MainController
	(@$scope, @$location) ->
		$scope.$watch (~> @$location.path!), !~> $scope.thisLocation = it

		$scope.menu = [
			{ path : "/guide" name : "Guide" }
			{ path : "/inventory" name : "Inventory" }
			{ path : "/a-calc" name : "Armor calculator" }
			{ path : "/w-calc" name : "Weapon calculator" }
			{ path : "/stats" name : "Stats" }
			{ path : "/items" name : "Item data" }
		]

module?.exports = MainController