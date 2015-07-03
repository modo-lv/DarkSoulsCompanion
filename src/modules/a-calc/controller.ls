$q, $scope, itemService, inventoryService, pcService, uiGridConstants <-! angular.module "dsc" .controller "ArmorCalcController"

$scope.results = []

$scope.maxLoad = 0
$scope.reservedWeight = 0
$scope.availableLoad = 0


### INIT

$scope.maxLoad = 40 + pcService.statValueOf \endurance



# Grid
$scope.gridOptions = (require './controller/gridOptions') uiGridConstants
	..data = $scope.results


_calcScoreFor = (armorPart) !->
	score = [armorPart.defN, armorPart.defSt, armorPart.defSl, armorPart.defTh ] |> average

	return score

_addAvailableUpgradesTo = (armors, inventory) !->
	def = $q.defer!

	promise = $q (resolve, reject) !-> resolve!
	fullArmorList = []
	for armor in armors
		materials = inventory |> map -> {} <<< it
		for iteration from 0 to 10
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
	$scope.gridOptions.data = []

	inventory = inventoryService.loadUserInventory!
	inventory.$promise
	.then -> itemService.loadItemData \armors .$promise
	.then (armors) !->
		availableArmors = inventory
			|> filter ( .itemType == \armor )
			|> map (inv) -> armors |> find ( .id == inv.id )
			|> reject ( .weight > $scope.freeWeight )

		return _addAvailableUpgradesTo availableArmors, inventory
	.then (availableArmors) !->
		for part in [\head \chest \hands \legs]
			new itemService.models.Armor
				..name = "(nothing)"
				..armorType = part
				.. |> availableArmors.push
				
		# Generate all possible combinations
		results = []
		for head in availableArmors |> filter ( .armorType == \head )
			for chest in availableArmors |> filter ( .armorType == \chest )
				for hands in availableArmors |> filter ( .armorType == \hands )
					for legs in availableArmors |> filter ( .armorType == \legs )
						wSum = [head, chest, hands, legs] |> Obj.map (.weight) |> Obj.values |> sum
						if wSum <= $scope.freeWeight

							result = {
								\head : {
									\name : head.name
									\score : _calcScoreFor head
								}
								\chest : {
									\name : chest.name
									\score : _calcScoreFor chest
								}
								\hands : {
									\name : hands.name
									\score : _calcScoreFor hands
								}
								\legs : {
									\name : legs.name
									\score : _calcScoreFor legs
								}
							}
								..score = result |> Obj.map (.score) |> Obj.values |> sum
								..weight = wSum
								.. |> results.push

		$scope.gridOptions.data = results