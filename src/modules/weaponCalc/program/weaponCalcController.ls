$scope, itemService, inventoryService, pcService, uiGridConstants <-! angular.module "dsc-weapon-calc" .controller "weaponCalcController"

$scope.results = []


# Grid
$scope.gridOptions = (require './gridOptions') uiGridConstants
	..data = $scope.results



$scope.calculate = !->
	results = []

	scS = getStatScalingFactor \strength
	scD = getStatScalingFactor \dexterity
	scI = getStatScalingFactor \intelligence
	scF = getStatScalingFactor \faith

	str = pcService.statValueOf \strength
	dex = pcService.statValueOf \dexterity
	int = pcService.statValueOf \intelligence
	fai = pcService.statValueOf \faith

	for entry in inventoryService.items |> filter ( .item.itemType == \weapon )
		weapon = entry.item

		if weapon.reqS > str || weapon.reqD > dex || weapon.reqI > int || weapon.reqF > fai
			continue

		dmgP = weapon.dmgP * (1 + ((weapon.scS * scS) + (weapon.scD * scD)))
		dmgM = weapon.dmgM * (1 + ((weapon.scI * scI) + (weapon.scF * scF)))

		score = dmgP

		result = {}
			..weapon = weapon
			..score = score

		results.push result

	$scope.gridOptions.data = results



getStatScalingFactor = (name) !->
	statValue = pcService.statValueOf name

	thresholds = switch name
		when \strength then fallthrough
		when \dexterity then [[10, 0.5] [10, 3.5] [20, 2.25]]
		when \intelligence then fallthrough
		when \faith then [[10, 0.5] [20, 2.25] [20, 1.5]]
		default ...


	result = 0
	for threshold in thresholds
		if statValue >= threshold.0
			result += threshold.0 * threshold.1
		else
			result += statValue * threshold.1
		statValue -= threshold.0
		if statValue < 1
			break

	result /= 100

	#console.log "#{name} scaling factor: #{result }"
	return result