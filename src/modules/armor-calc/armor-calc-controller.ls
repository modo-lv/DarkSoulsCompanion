$q, $scope, itemSvc, armorCalcSvc, pcService, uiGridConstants <-! angular.module "dsc" .controller "ArmorCalcController"

$scope.results = []

$scope.maxLoad = 0
$scope.reservedWeight = 50
$scope.availableLoad = 0


### INIT

$scope.maxLoad = 40 + pcService.statValueOf \endurance
$scope.typeNames = {
	0 : \head
	1 : \chest
	2 : \hands
	3 : \legs
}

$scope.partNames = [\head \chest \hands \legs]


# Grid
$scope.gridOptions = (require './controller/gridOptions') uiGridConstants
	..data = $scope.results

$scope.calculate = (type = 'offence') !->
	armorCalcSvc.freeWeight = $scope.availableLoad = $scope.maxLoad - $scope.reservedWeight
	armorCalcSvc.findBestCombinations!.then (results) !->
		$scope.results = []
		for result in results
			$scope.results.push {
				score : result.score
				weight : result.weight
				armors : (result.armors |> map (.name)) |> join ', '
			}
		$scope.gridOptions.data = $scope.results