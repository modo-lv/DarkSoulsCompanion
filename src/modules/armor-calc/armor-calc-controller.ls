$q, $scope, itemSvc, armorCalcSvc, pcSvc, uiGridConstants <-! angular.module "dsc" .controller "ArmorCalcController"

# SETUP

$scope.results = []

$scope.maxLoad = 0
$scope.reservedWeight = 15
$scope.availableLoad = 0

$scope.weightLimits = [ 0.25 0.50 0.75 1.00 ]
$scope.selectedWeightLimit = 0.50

$scope.modifiers = [
	{ key : \phy value : 2 title : "Physical defense" }
	{ key : \mag value : 0 title : "Magic defense" }
	{ key : \fir value : 0 title : "Fire defense" }
	{ key : \lit value : 0 title : "Lightning defense" }
	{ key : \blo value : 0 title : "Bleed resistance" }
	{ key : \tox value : 0 title : "Poisen resistance" }
	{ key : \cur value : 0 title : "Cures resistance" }
	{ key : \poise value : 1 title : "Poise" }
]

### INIT

$scope.maxLoad = 40 + pcSvc.statValueOf \endurance
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
	armorCalcSvc.freeWeight = $scope.availableLoad

	armorCalcSvc.params = {}
		..freeWeight = $scope.availableLoad
		..noUpgrades = $scope.noUpgrades

	for mod in $scope.modifiers
		armorCalcSvc.params.{}modifiers.[mod.key] = mod.value

	armorCalcSvc.findBestCombinations!.then (results) !->
		$scope.results = []
		for result in results
			$scope.results.push {
				score : result.score
				weight : result.weight
				armors : (result.armors |> map (.name)) |> join ', '
				detailScores : result.detailScores
			}
		$scope.gridOptions.data = $scope.results


### EVENTS

$scope.$watchGroup ["selectedWeightLimit", "reservedWeight", "maxLoad"], (nVal, oVal) !->
	$scope.availableLoad = ($scope.maxLoad * $scope.selectedWeightLimit) - $scope.reservedWeight