module?.exports = (uiGridConstants) ->
	percentFieldMinWidth = 45

	columnDefs : [
		{
			field : 'score'
			minWidth : 50
			cellFilter : 'number:2'
			sort : {
				direction : uiGridConstants.DESC
				priority : 1
			}
			type : \number
		},
		{
			field : 'weapon.name'
			minWidth : 210
		}
		{
			field : 'weapon.reqS'
			displayName : \RS
			type : \number
		}
		{
			field : 'weapon.reqD'
			displayName : \RD
			type : \number
		}
		{
			field : 'weapon.reqI'
			displayName : \RI
			type : \number
		}
		{
			field : 'weapon.reqF'
			displayName : \RF
			type : \number
		}
		{
			field : 'weapon.dmgN'
			displayName : \AP
			type : \number
		}
		{
			field : 'weapon.dmgM'
			displayName : \AM
			type : \number
		}
		{
			field : 'weapon.dmgF'
			displayName : \AF
			type : \number
		}
		{
			field : 'weapon.dmgL'
			displayName : \AL
			type : \number
		}
		{
			field : 'weapon.dmgS'
			displayName : \AS
			type : \number
		}
		{
			field : 'weapon.scS'
			displayName : \SS
			minWidth : percentFieldMinWidth
			cellFilter : 'percentage'
			type : \number
		}
		{
			field : 'weapon.scD'
			displayName : \SD
			minWidth : percentFieldMinWidth
			cellFilter : 'percentage'
			type : \number
		}
		{
			field : 'weapon.scI'
			displayName : \SI
			minWidth : percentFieldMinWidth
			cellFilter : 'percentage'
			type : \number
		}
		{
			field : 'weapon.scF'
			displayName : \SF
			minWidth : percentFieldMinWidth
			cellFilter : 'percentage'
			type : \number
		}
		{
			field : 'weapon.defN'
			displayName : \DP
			type : \number
		}
		{
			field : 'weapon.defM'
			displayName : \DM
			type : \number
		}
		{
			field : 'weapon.defF'
			displayName : \DF
			type : \number
		}
		{
			field : 'weapon.defL'
			displayName : \DL
			type : \number
		}
		{
			field : 'weapon.defT'
			displayName : \DT
			type : \number
		}
		{
			field : 'weapon.defB'
			displayName : \DB
			type : \number
		}
		{
			field : 'weapon.defC'
			displayName : \DC
			type : \number
		}
		{
			field : 'weapon.defS'
			displayName : \St
			type : \number
		}
		{
			field : 'weapon.divMod'
			minWidth : percentFieldMinWidth
			displayName : \Div
			cellFilter : 'percentage'
			type : \number
		}
		{
			field : 'weapon.occMod'
			minWidth : percentFieldMinWidth
			displayName : \Occ
			cellFilter : 'percentage'
			type : \number
		}
		{
			field : 'weapon.weight'
			displayName : \Wt
			type : \number
		}
	]