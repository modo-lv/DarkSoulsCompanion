module?.exports = (uiGridConstants) -> {
	enableFiltering : true

	columnDefs : [
		{
			field : 'name'
			sort : {
				direction : uiGridConstants.ASC
			}
		}
		{
			field : 'itemType'
			displayName : 'Type'
			filter : {
				type : uiGridConstants.filter.SELECT
				selectOptions : [
					{ value : \weapon label : "Weapons" }
					{ value : \armor label : "Armor" }
					{ value : \item label : "Items" }
				]
			}
		}
		{
			field : 'amount'
			width : 50
		}
	]
}
