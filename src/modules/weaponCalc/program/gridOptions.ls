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
		}
		{
			field : 'weapon.reqI'
			displayName : \RI
		}
		{
			field : 'weapon.reqF'
			displayName : \RF
		}
		{
			field : 'weapon.dmgP'
			displayName : \AP
		}
		{
			field : 'weapon.dmgM'
			displayName : \AM
		}
		{
			field : 'weapon.dmgF'
			displayName : \AF
		}
		{
			field : 'weapon.dmgL'
			displayName : \AL
		}
		{
			field : 'weapon.dmgS'
			displayName : \AS
		}
		{
			field : 'weapon.scS'
			displayName : \SS
			minWidth : percentFieldMinWidth
			cellFilter : 'percentage'
		}
		{
			field : 'weapon.scD'
			displayName : \SD
			minWidth : percentFieldMinWidth
			cellFilter : 'percentage'
		}
		{
			field : 'weapon.scI'
			displayName : \SI
			minWidth : percentFieldMinWidth
			cellFilter : 'percentage'
		}
		{
			field : 'weapon.scF'
			displayName : \SF
			minWidth : percentFieldMinWidth
			cellFilter : 'percentage'
		}
		{
			field : 'weapon.defP'
			displayName : \DP
		}
		{
			field : 'weapon.defM'
			displayName : \DM
		}
		{
			field : 'weapon.defF'
			displayName : \DF
		}
		{
			field : 'weapon.defL'
			displayName : \DL
		}
		{
			field : 'weapon.defT'
			displayName : \DT
		}
		{
			field : 'weapon.defB'
			displayName : \DB
		}
		{
			field : 'weapon.defC'
			displayName : \DC
		}
		{
			field : 'weapon.defS'
			displayName : \St
		}
		{
			field : 'weapon.divMod'
			minWidth : percentFieldMinWidth
			displayName : \Div
			cellFilter : 'percentage'
		}
		{
			field : 'weapon.occMod'
			minWidth : percentFieldMinWidth
			displayName : \Occ
			cellFilter : 'percentage'
		}
	]