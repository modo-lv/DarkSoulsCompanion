module?.exports = ($scope, uiGridConstants) !->
	$scope.gridOptions = {
		columnDefs : [
			{
				field : 'fullName'
				displayName : 'Item'
			}
		]
		data : $scope.items
	}
