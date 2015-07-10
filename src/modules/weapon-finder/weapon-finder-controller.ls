$scope, weaponFinderSvc, uiGridConstants <-! angular .module "dsc" .controller "weaponFinderController"

### SETUP

$scope.results = []

$scope.gridOptions = (require './config/weapon-finder-grid-options') uiGridConstants


### INIT



### EVENTS

$scope.findWeapons = !->
	weaponFinderSvc.findBestWeapons!
	.then (results) !->
		$scope.results = results |> map (result) -> {
			score : result.score
			weapon : result
		}

		$scope.gridOptions.data = $scope.results