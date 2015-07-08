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
		}
	]