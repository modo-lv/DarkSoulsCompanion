$q, $scope, itemSvc, inventorySvc, pcSvc, uiGridConstants <-! angular.module "dsc" .controller "WeaponCalcController"

$scope.results = []

$scope.statBonus = 0
$scope.ignoreCrystal = true


# Grid
$scope.gridOptions = (require './controller/gridOptions') uiGridConstants
	..data = $scope.results


_addResult = (type, weapon) !->
	scS = pcSvc.statScalingFactorOf \strength
	scD = pcSvc.statScalingFactorOf \dexterity
	scI = pcSvc.statScalingFactorOf \intelligence
	scF = pcSvc.statScalingFactorOf \faith

	str = $scope.statBonus + pcSvc.statValueOf \strength
	dex = $scope.statBonus + pcSvc.statValueOf \dexterity
	int = $scope.statBonus + pcSvc.statValueOf \intelligence
	fai = $scope.statBonus + pcSvc.statValueOf \faith

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

	items = itemSvc.loadItemData \items
	weapons = itemSvc.loadItemData \weapons
	inventory = inventorySvc.loadUserInventory!

	$q.all [weapons.$promise, items.$promise] .then ->
		availableWeapons = (inventory |> map (item) -> weapons |> find (.id == item.id)) |> reject ->
			#console.log it?.path
			not it? or ($scope.ignoreCrystal and (it.name |> take 4) == \Crys)

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
						return itemSvc.canUpgradeWithMaterials weapon, materials, iteration
					.then (canUpgrade) !->
						#console.log "Then2", canUpgrade
						if canUpgrade
							return $q.all [
								itemSvc.getUpgradedVersionOf weapon, iteration
								itemSvc.payForUpgradeFor weapon, materials, iteration
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