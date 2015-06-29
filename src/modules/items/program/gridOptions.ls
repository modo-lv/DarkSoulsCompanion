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
				field : \dmgP
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
				field : \defP
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