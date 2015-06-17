angular.module "dsc-items"
	.controller "ItemsController", ($scope) !->
		$scope.itemData = {
			"armors" : []
		}

		for armor in require './content/armors.json'
			armor = new (require './models/armor.ls') <<< armor
			delete armor.EquipmentType
			$scope.itemData[\armors].push armor


		$scope.gridOptions = {
			data : $scope.itemData[\armors]
			columnDefs : [
				{ field : 'armorSet', displayName : 'Set', width : 150 }
				{ field : 'armorType', displayName : 'Type' }
				{ field : 'name', width : 250 }
				{ field : 'level', displayName : '+' }

				{ field : 'physical' }
				{ field : 'strike' }
				{ field : 'slash' }
				{ field : 'thrust' }
				{ field : 'magic' }
				{ field : 'fire' }
				{ field : 'lightning' }

				{ field : 'poison' }
				{ field : 'bleed' }
				{ field : 'curse' }

				{ field : 'poise' }
				{ field : 'weight' }
			]
		}

