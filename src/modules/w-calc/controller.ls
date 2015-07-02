$q, $scope, itemService, inventoryService, pcService, uiGridConstants <-! angular.module "dsc" .controller "WeaponCalcController"

$scope.results = []


# Grid
$scope.gridOptions = (require './controller/gridOptions') uiGridConstants
	..data = $scope.results


_addResult = (type, weapon) !->
	scS = pcService.statScalingFactorOf \strength
	scD = pcService.statScalingFactorOf \dexterity
	scI = pcService.statScalingFactorOf \intelligence
	scF = pcService.statScalingFactorOf \faith

	str = pcService.statValueOf \strength
	dex = pcService.statValueOf \dexterity
	int = pcService.statValueOf \intelligence
	fai = pcService.statValueOf \faith

	if weapon.reqS > str || weapon.reqD > dex || weapon.reqI > int || weapon.reqF > fai
		#console.log "#{weapon.name} needs higher stats"
		return

	dmgN = weapon.dmgN * (1 + ((weapon.scS * scS) + (weapon.scD * scD)))
	dmgM = weapon.dmgM * (1 + ((weapon.scI * scI) + (weapon.scF * scF)))

	defN = weapon.defN + ((weapon.defM + weapon.defF + weapon.defL) * 0.2) + weapon.defS

	score = if type == 'defence' then defN else dmgN

	result = {}
		..weapon = weapon
		..score = score

	$scope.gridOptions.data.push result


$scope.calculate = (type = 'offence') !->
	$scope.gridOptions.data = []

	items = itemService.loadItemData \items
	weapons = itemService.loadItemData \weapons
	inventory = inventoryService.loadUserInventory!

	$q.all [weapons.$promise, items.$promise] .then ->
		availableWeapons = (inventory |> map (item) -> weapons |> find (.id == item.id)) |> reject -> not it?

		# Find available upgrades
		data = {}

		for weapon in availableWeapons
			materials = inventory |> map -> {} <<< it
			promise = $q (resolve, reject) !-> resolve!
			for iteration from 0 to 15
				((weapon, materials, iteration) !->
					promise := promise
					.then !->
						#console.log "Then1"
						return itemService.canUpgradeWithMaterials weapon, materials, iteration
					.then (canUpgrade) !->
						#console.log "Then2", canUpgrade
						if canUpgrade
							return $q.all [
								itemService.getUpgradedVersionOf weapon, iteration
								itemService.payForUpgradeFor weapon, materials, iteration
							]
						else
							materials.length = 0
							return null
					.then (result) !->
						upWeapon = result?.0
						#console.log "then4", weapon
						if upWeapon?
							_addResult type, upWeapon

				) weapon, materials, iteration