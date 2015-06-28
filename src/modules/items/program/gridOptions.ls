module?.exports = ($scope, uiGridConstants) !->
	$scope.gridOptions = {}
	
	percentFieldMinWidth = 50

	$scope.columnConfigs = {
		\weapons : [
			{
				field : 'weaponCategory',
				displayName : 'Type',
				minWidth : 100
				sort : {
					direction : uiGridConstants.ASC
					priority : 0
				}
			},
			{
				field : 'name'
				minWidth : 225
				sort : {
					direction : uiGridConstants.ASC
					priority : 1
				}
			}
			{
				field : \reqStr
				displayName : \RS
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
				field : \reqFaith
				displayName : \RF
			}
			{
				field : \dmgPhys
				displayName : \AP
			}
			{
				field : \dmgMagic
				displayName : \AM
			}
			{
				field : \dmgFire
				displayName : \AF
			}
			{
				field : \dmgLight
				displayName : \AL
			}
			{
				field : \dmgStam
				displayName : \AS
			}
			{
				field : \scaleStr
				displayName : \SS
				minWidth : percentFieldMinWidth
				cellFilter : 'percentage'
			}
			{
				field : \scaleDex
				displayName : \SD
				minWidth : percentFieldMinWidth
				cellFilter : 'percentage'
			}
			{
				field : \scaleInt
				displayName : \SI
				minWidth : percentFieldMinWidth
				cellFilter : 'percentage'
			}
			{
				field : \scaleFaith
				displayName : \SF
				minWidth : percentFieldMinWidth
				cellFilter : 'percentage'
			}
			{
				field : \defPhys
				displayName : \DP
			}
			{
				field : \defMagic
				displayName : \DM
			}
			{
				field : \defFire
				displayName : \DF
			}
			{
				field : \defLight
				displayName : \DL
			}
			{
				field : \defPoison
				displayName : \DP
			}
			{
				field : \defBleed
				displayName : \DB
			}
			{
				field : \defCurse
				displayName : \DC
			}
			{
				field : \stability
				displayName : \St
			}
			{
				field : \divineMod
				minWidth : percentFieldMinWidth
				displayName : \Div
				cellFilter : 'percentage'
			}
			{
				field : \occultMod
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