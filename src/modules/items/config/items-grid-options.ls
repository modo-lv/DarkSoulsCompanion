module?.exports = ($scope, uiGridConstants) !->
	$scope.gridOptions = {
		enableFiltering : true
	}
	
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
				field : \atkPhy
				displayName : \AP
			}
			{
				field : \atkMag
				displayName : \AM
			}
			{
				field : \atkFir
				displayName : \AF
			}
			{
				field : \atkLit
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

			{
				field : \atkStaCost
				displayNamo : \Sta
				cellFilter : "number:2"
				type : \number
			}
			{
				field : \dpsPhy
				displayNamo : \dpsP
				cellFilter : "number:2"
				type : \number
			}
			{
				field : \dpsMag
				displayNamo : \dpsM
				cellFilter : "number:2"
				type : \number
			}
			{
				field : \dpsFir
				displayNamo : \dpsF
				cellFilter : "number:2"
				type : \number
			}
			{
				field : \dpsLit
				displayNamo : \dpsL
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

			{ name : \defPhy , type : \number , displayName : \DN }
			{ name : \defMag , type : \number , displayName : \DM }
			{ name : \defFir , type : \number , displayName : \DF }
			{ name : \defLit , type : \number , displayName : \DL }
			{ name : \defPoise , type : \number , displayName : \DP }

			{ name : \defTox , type : \number , displayName : \RP }
			{ name : \defBlo , type : \number , displayName : \RB }
			{ name : \defCur , type : \number , displayName : \RC }

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