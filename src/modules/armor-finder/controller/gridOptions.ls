module?.exports = (uiGridConstants) ->
	percentFieldMinWidth = 45

	columnDefs : [
		{
			field : 'score'
			width : 75
			cellFilter : 'number:2'
			sort : {
				direction : uiGridConstants.DESC
				priority : 0
			}
			type : \number
		}
		{
			field : 'weight'
			width : 50
			cellFilter : 'number:2'
			type : \number
			sort : {
				direction : uiGridConstants.ASC
				priority : 1
			}
		}

		{
			field : 'armors'
			minWidth : 700
		}

		{
			field : 'detailScores.phy'
			minWidth : 50
			cellFilter : 'number:0'
			type : \number
			displayName : \Phys.
		}
		{
			field : 'detailScores.mag'
			minWidth : 50
			cellFilter : 'number:0'
			type : \number
			displayName : \Magic
		}
		{
			field : 'detailScores.fir'
			minWidth : 50
			cellFilter : 'number:0'
			type : \number
			displayName : \Fire
		}
		{
			field : 'detailScores.lit'
			minWidth : 50
			cellFilter : 'number:0'
			type : \number
			displayName : \Light.
		}
		{
			field : 'detailScores.blo'
			minWidth : 50
			cellFilter : 'number:0'
			type : \number
			displayName : \Bleed
		}
		{
			field : 'detailScores.tox'
			minWidth : 50
			cellFilter : 'number:0'
			type : \number
			displayName : \Tox.
		}
		{
			field : 'detailScores.cur'
			minWidth : 50
			cellFilter : 'number:0'
			type : \number
			displayName : \Curse
		}
		{
			field : 'detailScores.poise'
			minWidth : 50
			cellFilter : 'number:0'
			type : \number
			displayName : \Poise
		}
	]