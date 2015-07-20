$q, $scope, storageSvc, itemSvc, armorFinderSvc, statSvc, uiGridConstants <-! angular.module "dsc" .controller "armorFinderController"

# SETUP

$scope.results = []

maxLoad : 0
availableLoad : 0

$scope.params = (storageSvc.load \armor-finder-params) ? {
	reservedWeight : 15

	selectedWeightLimit : 0.50

	includeUpgrades : true
	
	modifiers : [ 2 0 0 0 0 0 0 1 ]

	resultLimit : 10
}

$scope.weightLimits = [ 0.25 0.50 0.75 1.00 ]

$scope.modifiers = [
	{ key : \phy title : "Physical" }
	{ key : \mag title : "Magic" }
	{ key : \fir title : "Fire" }
	{ key : \lit title : "Lightning" }
	{ key : \blo title : "Bleed" }
	{ key : \tox title : "Poison" }
	{ key : \cur title : "Curse" }
	{ key : \poise title : "Poise" }
]

### INIT

$scope.maxLoad = 40 + statSvc.statValueOf \end
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
	armorFinderSvc.freeWeight = $scope.availableLoad

	armorFinderSvc.params = {}
		..freeWeight = $scope.availableLoad
		..includeUpgrades = $scope.params.includeUpgrades
		..resultLimit = $scope.params.resultLimit

	for mod, index in $scope.modifiers
		armorFinderSvc.params.{}modifiers.[mod.key] = $scope.params.modifiers.[index]

	armorFinderSvc.findBestCombinations!.then (results) !->
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

$scope.$watch "params", (!->
	max = $scope.maxLoad
	if $scope.params.havelRing
		max *= 1.5
	$scope.availableLoad = (max * $scope.params.selectedWeightLimit) - $scope.params.reservedWeight
	storageSvc.save "armor-finder-params", $scope.params
), true