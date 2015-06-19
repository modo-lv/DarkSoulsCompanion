module?.exports = ($scope, uiGridConstants) !->
	$scope.columnConfigs = {
		\armors : [
			{
				field : 'armorSet'
				displayName : 'Set'
				minWidth : 150
				sort : {
					direction : uiGridConstants.ASC
					priority : 0
				}
			}
			{
				field : 'armorType', displayName : 'Type'
				sort : {
					direction : uiGridConstants.ASC
					priority : 1
				}
			}
			{ field : 'name', minWidth : 250 }
			{
				field : 'level', displayName : '+', type : 'number'
				sort : {
					direction : uiGridConstants.ASC
					priority : 2
				}
			}

			{ field : 'physical', type : 'number' }
			{ field : 'strike', type : 'number' }
			{ field : 'slash', type : 'number' }
			{ field : 'thrust', type : 'number' }
			{ field : 'magic', type : 'number' }
			{ field : 'fire', type : 'number' }
			{ field : 'lightning', type : 'number' }

			{ field : 'poison', type : 'number' }
			{ field : 'bleed', type : 'number' }
			{ field : 'curse', type : 'number' }

			{ field : 'poise', type : 'number' }
			{ field : 'weight', type : 'number' }
		]
	}

	for itemType in [\items \keys \materials \rings]
		$scope.columnConfigs[itemType] = [
			{
				field : 'name'
				sort : {
					direction : uiGridConstants.ASC
					priority : 0
				}
			}
		]

	$scope.gridOptions = {
		columnDefs : $scope.columnConfigs[\armors]
	}
