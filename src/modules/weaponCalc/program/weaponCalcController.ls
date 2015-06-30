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

	availableWeapons = inventoryService.items |> filter (.item.itemType == 'weapon') |> map (.item)

	getAvailableMaterials = ->
		inventoryService.items
			|> filter (.item.itemType == 'item')
			|> map -> {id : it.item.id, amount : it.amount}

	# Find available upgrades
	upgraded = []
	for weapon in availableWeapons
		availableMaterials = getAvailableMaterials!
		iteration = 0
		nextUp = weapon
		do
			if ++iteration > 15
				break
			canUpgrade = itemService.canUpgradeWithMaterials weapon, availableMaterials, iteration
			#console.log "Can upgrade #{weapon.name }: #{canUpgrade }"
			if canUpgrade
				temp = itemService.getUpgradedWeapon weapon, iteration
			if canUpgrade and canUpgrade = nextUp?
				#console.log "Addding upgraded weapon", temp
				itemService.payForUpgradeFor weapon, availableMaterials, iteration
				nextUp = temp
				upgraded.push nextUp
		while canUpgrade
		#break

	availableWeapons ++= upgraded

	for weapon in availableWeapons
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