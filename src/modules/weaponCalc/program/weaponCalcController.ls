$scope, itemService, inventoryService, uiGridConstants <-! angular.module "dsc-weapon-calc" .controller "weaponCalcController"

$scope.results = []


# Grid
$scope.gridOptions = (require './gridOptions') uiGridConstants
	..data = $scope.results


$scope.calculate = !->
	results = []

	for entry in inventoryService.items |> filter ( .item.itemType == \weapon )
		weapon = entry.item
		score = weapon.dmgP * (1 + (weapon.scS + weapon.scD))

		result = {}
			..weapon = weapon
			..score = score

		results.push result

	$scope.gridOptions.data = results