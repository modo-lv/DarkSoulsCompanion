module?.exports = ($scope, uiGridConstants) !->
	$scope.gridOptions = {}
	
	percentFieldMinWidth = 45

	$scope.columnConfigs = {
		\weapons : [
			{
				field : 'weaponCategory',
				displayName : 'Type',
				minWidth : 70
				sort : {
					direction : uiGridConstants.ASC
					priority : 0
				},
			},
			{
				field : 'name'
				minWidth : 210
				sort : {
					direction : uiGridConstants.ASC
					priority : 1
				}
			}
			{
				field : \reqS
				displayName : \RS
				type : \number
			}
			{
				field : \reqD
				displayName : \RD
			}
			{
				field : \reqI
				displayName : \RI
			}
			{
				field : \reqF
				displayName : \RF
			}
			{
				field : \dmgN
				displayName : \AP
			}
			{
				field : \dmgM
				displayName : \AM
			}
			{
				field : \dmgF
				displayName : \AF
			}
			{
				field : \dmgL
				displayName : \AL
			}
			{
				field : \dmgS
				displayName : \AS
			}
			{
				field : \scS
				displayName : \SS
				minWidth : percentFieldMinWidth
				cellFilter : 'percentage'
			}
			{
				field : \scD
				displayName : \SD
				minWidth : percentFieldMinWidth
				cellFilter : 'percentage'
			}
			{
				field : \scI
				displayName : \SI
				minWidth : percentFieldMinWidth
				cellFilter : 'percentage'
			}
			{
				field : \scF
				displayName : \SF
				minWidth : percentFieldMinWidth
				cellFilter : 'percentage'
			}
			{
				field : \defN
				displayName : \DP
			}
			{
				field : \defM
				displayName : \DM
			}
			{
				field : \defF
				displayName : \DF
			}
			{
				field : \defL
				displayName : \DL
			}
			{
				field : \defT
				displayName : \DT
			}
			{
				field : \defB
				displayName : \DB
			}
			{
				field : \defC
				displayName : \DC
			}
			{
				field : \defS
				displayName : \St
			}
			{
				field : \divMod
				minWidth : percentFieldMinWidth
				displayName : \Div
				cellFilter : 'percentage'
			}
			{
				field : \occMod
				minWidth : percentFieldMinWidth
				displayName : \Occ
				cellFilter : 'percentage'
			}
		]
		\armors : [
			{
				name : 'armorSet'
				displayName : 'Set'
				minWidth : 150
				sort : {
					direction : uiGridConstants.ASC
					priority : 0
				}
			}
			{
				name : 'armorType', displayName : 'Type'
				sort : {
					direction : uiGridConstants.ASC
					priority : 1
				}
				sortingAlgorithm : (a, b) !->
					values = {
						\head : 1
						\chest : 2
						\hands : 3
						\legs : 4
					}
					return if values[a] > values[b] then 1 else if values[a] < values[b] then -1 else 0

			}
			{ field : 'name', minWidth : 250 }

			{ name : \defN , type : \number , displayName : \DN }
			{ name : \defSl , type : \number , displayName : \DSl }
			{ name : \defSt , type : \number , displayName : \DSt }
			{ name : \defTh , type : \number , displayName : \DTh }
			{ name : \defM , type : \number , displayName : \DM }
			{ name : \defF , type : \number , displayName : \DF }
			{ name : \defL , type : \number , displayName : \DL }
			{ name : \defP , type : \number , displayName : \DP }

			{ name : \defT , type : \number , displayName : \RP }
			{ name : \defB , type : \number , displayName : \RB }
			{ name : \defC , type : \number , displayName : \RC }

			{ name : \stRec , type : \number , displayName : \Sr }

			{ name : \weight , type : \number , displayName : \Wt }
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