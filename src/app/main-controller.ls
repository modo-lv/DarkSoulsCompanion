angular?.module "dsc" .controller "mainController" ($scope, $location) ->
	new MainController $scope, $location

class MainController
	(@$scope, @$location) ->
		$scope.$watch (~> @$location.path!), !~> $scope.thisLocation = it

		$scope.menu = [
			{ path : "/guide" name : "Game info & checklist" }
			{ path : "/pc" name : "Stats & inventory" }
			{ path : "/armor-calc" name : "Armor finder" }
			{ path : "/weapon-finder" name : "Weapon finder" }
			{ path : "/items" name : "Item data" }
		]

module?.exports = MainController