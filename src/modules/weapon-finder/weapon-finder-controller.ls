$scope, storageSvc, weaponFinderSvc, uiGridConstants <-! angular .module "dsc" .controller "weaponFinderController"

### SETUP

$scope.results = []

$scope.params = {
	statBonus : 0
} <<< (storageSvc.load 'weapon-finder-params')

$scope.gridOptions = (require './config/weapon-finder-grid-options') uiGridConstants


### INIT



### EVENTS

$scope.findWeapons = !->
	weaponFinderSvc.params <<< $scope.params

	weaponFinderSvc.findBestWeapons!
	.then (results) !->
		$scope.results = results |> map (result) -> {
			weapon : result
		} <<< result

		$scope.gridOptions.data = $scope.results


$scope.$watch "params", (!->
	storageSvc.save "weapon-finder-params", $scope.params
), true