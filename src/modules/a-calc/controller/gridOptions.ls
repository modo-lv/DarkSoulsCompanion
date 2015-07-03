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
			field : 'head.name'
		}
		{
			field : 'head.score'
			type : \number
			width : 50
			cellFilter : 'number:2'
		}

		{
			field : 'chest.name'
		}
		{
			field : 'chest.score'
			type : \number
			width : 50
			cellFilter : 'number:2'
		}

		{
			field : 'hands.name'
		}
		{
			field : 'hands.score'
			type : \number
			width : 50
			cellFilter : 'number:2'
		}

		{
			field : 'legs.name'
		}
		{
			field : 'legs.score'
			type : \number
			width : 50
			cellFilter : 'number:2'
		}

	]