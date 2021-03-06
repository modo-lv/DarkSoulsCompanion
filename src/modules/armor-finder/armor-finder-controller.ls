$q, $scope, storageSvc, itemSvc, armorFinderSvc, statSvc, uiGridConstants <-! angular.module "dsc" .controller "armorFinderController"

# SETUP

$scope.results = []

maxLoad : 0
availableLoad : 0

$scope.params = (storageSvc.load \armor-finder-params) ? {
	reservedWeight : 15

	selectedWeightLimit : 0.50

	includeUpgrades : true
	
	modifiers : {
		def : [1 1 1 1 1 1 1 1]
	}

	resultLimit : 10

	havelRing : false

	favorRing : false
}

$scope.baseMaxLoad = 0.0
$scope.havelRingBonus = 0.0
$scope.favorRingBonus = 0.0

$scope.weightLimits = [ 0.25 0.50 0.75 1.00 ]

$scope.modifierNames = [
	"Physical"
	"Magic"
	"Fire"
	"Lightning"
	"Bleed"
	"Poison"
	"Curse"
	"Poise"
]

### INIT


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

	armorFinderSvc.params.{}modifiers.[]def.length = 0
	for name, index in $scope.modifierNames
		armorFinderSvc.params.{}modifiers.def.push $scope.params.modifiers.def[index]

	#console.log armorFinderSvc.params.{}modifiers

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
	$scope.baseMaxLoad = max = 40 + statSvc.statValueOf \end
	$scope.havelRingBonus = max * 0.5

	$scope.favorRingBonus = if $scope.params.havelRing
		then (max + $scope.havelRingBonus) * 0.2
		else max * 0.2

	if $scope.params.havelRing
		max *= 1.5
	if $scope.params.favorRing
		max *= 1.2
	$scope.maxLoad = max

	$scope.availableLoad = (max * $scope.params.selectedWeightLimit) - $scope.params.reservedWeight
	storageSvc.save "armor-finder-params", $scope.params
), true