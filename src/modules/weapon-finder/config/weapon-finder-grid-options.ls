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
		}
		{
			field : 'name'
			minWidth : 210
			displayName : 'Name'
		}
		{
			field : 'statReqs'
			displayName : 'Requirements'
			minWidth : 50
		}
		{
			field : 'dps',
			displayName : 'DPS',
			minWidth : 50
		}
		{
			field : 'atk',
			displayName : 'ATK'
			minWidth : 50
		}
		{
			field : 'def',
			displayName : 'DEF'
			minWidth : 50
		}
#		{
#			field : 'weapon.bonusStr'
#			displayName : \SS
#			minWidth : percentFieldMinWidth
#			cellFilter : 'percentage'
#			type : \number
#		}
#		{
#			field : 'weapon.bonusDex'
#			displayName : \SD
#			minWidth : percentFieldMinWidth
#			cellFilter : 'percentage'
#			type : \number
#		}
#		{
#			field : 'weapon.bonusInt'
#			displayName : \SI
#			minWidth : percentFieldMinWidth
#			cellFilter : 'percentage'
#			type : \number
#		}
#		{
#			field : 'weapon.bonusFai'
#			displayName : \SF
#			minWidth : percentFieldMinWidth
#			cellFilter : 'percentage'
#			type : \number
#		}
#		{
#			field : 'weapon.defPhy'
#			displayName : \DP
#			type : \number
#		}
#		{
#			field : 'weapon.defMag'
#			displayName : \DM
#			type : \number
#		}
#		{
#			field : 'weapon.defFir'
#			displayName : \DF
#			type : \number
#		}
#		{
#			field : 'weapon.defLit'
#			displayName : \DL
#			type : \number
#		}
#		{
#			field : 'weapon.defTox'
#			displayName : \DT
#			type : \number
#		}
#		{
#			field : 'weapon.defBlo'
#			displayName : \DB
#			type : \number
#		}
#		{
#			field : 'weapon.defCur'
#			displayName : \DC
#			type : \number
#		}
#		{
#			field : 'weapon.defSta'
#			displayName : \St
#			type : \number
#			cellFilter : "number:0"
#		}
#		{
#			field : 'weapon.divine'
#			minWidth : percentFieldMinWidth
#			displayName : \Div
#			cellFilter : 'percentage'
#			type : \number
#		}
#		{
#			field : 'weapon.occult'
#			minWidth : percentFieldMinWidth
#			displayName : \Occ
#			cellFilter : 'percentage'
#			type : \number
#		}
#		{
#			field : 'weapon.weight'
#			displayName : \Wt
#			type : \number
#			cellFilter : "number:2"
#		}
	]