$q, $scope, itemService, inventoryService, pcService, uiGridConstants <-! angular.module "dsc" .controller "ArmorCalcController"

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

_calcScoresFor = (set) !->
	result = {
		score : 0
		weight : 0
		def : 0
	}
	for item, key in set
		def = (item.defN + item.defSt + item.defSl + item.defTh) / 4

		score = def

		result[$scope.typeNames[key]] = {
			score : score
			item : item
			name : item.name
		}

		result.def += def
		result.score += score
		result.weight += item.weight

	return result


_addAvailableUpgradesTo = (armors, inventory) !->
	def = $q.defer!

	promise = $q (resolve, reject) !-> resolve!
	fullArmorList = []
	for armor in armors

		if armor.id < 0 or armor.upgradeId < 0 then
			fullArmorList.push armor
			continue

		materials = inventory |> map -> {} <<< it
		for iteration from 1 to 10
			((armor, materials, iteration) !->
				promise := promise
				.then !->
					#console.log "Then1"
					return itemService.canUpgradeWithMaterials armor, materials, iteration
				.then (canUpgrade) !->
					#console.log "Then2", canUpgrade
					if canUpgrade
						return $q.all [
							itemService.getUpgradedVersionOf armor, iteration
							itemService.payForUpgradeFor armor, materials, iteration
						]
					else
						materials.length = 0
						return null
				.then (result) !->
					upArmor = result?.0
					#console.log "then4", armor
					if upArmor?
						fullArmorList.push upArmor
			) armor, materials, iteration

	promise.then -> def.resolve fullArmorList

	return def.promise


$scope.calculate = (type = 'offence') !->
	$scope.freeWeight = $scope.maxLoad - $scope.reservedWeight
	results = []

	inventory = inventoryService.loadUserInventory!
	inventory.$promise
	.then -> itemService.loadItemData \armors .$promise
	.then (armors) !->
		availableArmors = inventory
			|> filter ( .itemType == \armor )
			|> map (inv) -> armors |> find ( .id == inv.id )
			|> reject ( .weight > $scope.freeWeight )


		# First pass — find the best of the upgradeables
		staticArmors = availableArmors |> filter (.upgradeId < 0)
		dynamicArmors = availableArmors |> reject (.upgradeId < 0)

		for part, key in $scope.partNames
			new itemService.models.Armor
				..name = "(nothing)"
				..id = -(key + 1)
				..armorType = part
				.. |> dynamicArmors.push

		for head in dynamicArmors |> filter ( .armorType == \head )
			for chest in dynamicArmors |> filter ( .armorType == \chest )
				for hands in dynamicArmors |> filter ( .armorType == \hands )
					for legs in dynamicArmors |> filter ( .armorType == \legs )
						set = [head, chest, hands, legs]
						wSum = set |> map (.weight) |> sum
						#console.log wSum, $scope.freeWeight
						if wSum <= $scope.freeWeight
							results.push _calcScoresFor set

		bestResults = results |> sortBy (.score) |> reverse |> take 5

		bestArmors = {}
		for result in bestResults
			for part in $scope.partNames
				item = result[part].item
				bestArmors[item.id] = item

		fitArmors = staticArmors ++ (bestArmors |> values)

		return _addAvailableUpgradesTo (fitArmors |> Obj.values), inventory

	.then (availableArmors) !->
		# Generate all possible combinations
		results = []

		#console.log availableArmors
		for head in availableArmors |> filter ( .armorType == \head )
			for chest in availableArmors |> filter ( .armorType == \chest )
				for hands in availableArmors |> filter ( .armorType == \hands )
					for legs in availableArmors |> filter ( .armorType == \legs )
						set = [head, chest, hands, legs]
						wSum = set |> Obj.map (.weight) |> Obj.values |> sum
						if wSum <= $scope.freeWeight
							results.push _calcScoresFor set

		$scope.results = results
		$scope.gridOptions.data = $scope.results