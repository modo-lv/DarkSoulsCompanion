module?.exports = ($scope, uiGridConstants) !->
	$scope.gridOptions = {}
	
	percentFieldMinWidth = 45

	$scope.columnConfigs = {
		\weapon : [
			{
				field : 'weaponType',
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
				field : \reqStr
				displayName : \RS
				type : \number
			}
			{
				field : \reqDex
				displayName : \RD
			}
			{
				field : \reqInt
				displayName : \RI
			}
			{
				field : \reqFai
				displayName : \RF
			}
			{
				field : \dmgPhy
				displayName : \AP
			}
			{
				field : \dmgMag
				displayName : \AM
			}
			{
				field : \dmgFir
				displayName : \AF
			}
			{
				field : \dmgLit
				displayName : \AL
			}
			{
				field : \bonusStr
				displayName : \SS
				minWidth : percentFieldMinWidth
				cellFilter : 'percentage'
			}
			{
				field : \bonusDex
				displayName : \SD
				minWidth : percentFieldMinWidth
				cellFilter : 'percentage'
			}
			{
				field : \bonusInt
				displayName : \SI
				minWidth : percentFieldMinWidth
				cellFilter : 'percentage'
			}
			{
				field : \bonusFai
				displayName : \SF
				minWidth : percentFieldMinWidth
				cellFilter : 'percentage'
			}
			{
				field : \defPhy
				displayName : \DP
			}
			{
				field : \defMag
				displayName : \DM
			}
			{
				field : \defFir
				displayName : \DF
			}
			{
				field : \defLit
				displayName : \DL
			}
			{
				field : \defTox
				displayName : \DT
			}
			{
				field : \defBlo
				displayName : \DB
			}
			{
				field : \defCur
				displayName : \DC
			}
			{
				field : \defSta
				displayName : \St
			}
			{
				field : \divine
				minWidth : percentFieldMinWidth
				displayName : \Div
				cellFilter : 'percentage'
			}
			{
				field : \occult
				minWidth : percentFieldMinWidth
				displayName : \Occ
				cellFilter : 'percentage'
			}
			{
				field : \weight
				displayName : \Wt
				cellFilter : "number:2"
				type : \number
			}
		]
		\armor : [
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

	for itemType in [\item \rings]
		$scope.columnConfigs[itemType] = [
			{
				field : 'name'
				sort : {
					direction : uiGridConstants.ASC
					priority : 0
				}
			}
		]