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
			field : 'weapon.reqStr'
			displayName : \RS
			type : \number
		}
		{
			field : 'weapon.reqDex'
			displayName : \RD
			type : \number
		}
		{
			field : 'weapon.reqInt'
			displayName : \RI
			type : \number
		}
		{
			field : 'weapon.reqFai'
			displayName : \RF
			type : \number
		}
		{
			field : 'atkPhy'
			displayName : \AP
			type : \number
			cellFilter : "number:0"
		}
		{
			field : 'atkMag'
			displayName : \AM
			type : \number
			cellFilter : "number:0"
		}
		{
			field : 'weapon.atkFir'
			displayName : \AF
			type : \number
			cellFilter : "number:0"
		}
		{
			field : 'weapon.atkLit'
			displayName : \AL
			type : \number
			cellFilter : "number:0"
		}
		{
			field : 'weapon.atkStaCost'
			displayName : \AS
			type : \number
			cellFilter : "number:0"
		}
		{
			field : 'weapon.bonusStr'
			displayName : \SS
			minWidth : percentFieldMinWidth
			cellFilter : 'percentage'
			type : \number
		}
		{
			field : 'weapon.bonusDex'
			displayName : \SD
			minWidth : percentFieldMinWidth
			cellFilter : 'percentage'
			type : \number
		}
		{
			field : 'weapon.bonusInt'
			displayName : \SI
			minWidth : percentFieldMinWidth
			cellFilter : 'percentage'
			type : \number
		}
		{
			field : 'weapon.bonusFai'
			displayName : \SF
			minWidth : percentFieldMinWidth
			cellFilter : 'percentage'
			type : \number
		}
		{
			field : 'weapon.defPhy'
			displayName : \DP
			type : \number
		}
		{
			field : 'weapon.defMag'
			displayName : \DM
			type : \number
		}
		{
			field : 'weapon.defFir'
			displayName : \DF
			type : \number
		}
		{
			field : 'weapon.defLit'
			displayName : \DL
			type : \number
		}
		{
			field : 'weapon.defTox'
			displayName : \DT
			type : \number
		}
		{
			field : 'weapon.defBlo'
			displayName : \DB
			type : \number
		}
		{
			field : 'weapon.defCur'
			displayName : \DC
			type : \number
		}
		{
			field : 'weapon.defSta'
			displayName : \St
			type : \number
			cellFilter : "number:0"
		}
		{
			field : 'weapon.divine'
			minWidth : percentFieldMinWidth
			displayName : \Div
			cellFilter : 'percentage'
			type : \number
		}
		{
			field : 'weapon.occult'
			minWidth : percentFieldMinWidth
			displayName : \Occ
			cellFilter : 'percentage'
			type : \number
		}
		{
			field : 'weapon.weight'
			displayName : \Wt
			type : \number
			cellFilter : "number:2"
		}
	]