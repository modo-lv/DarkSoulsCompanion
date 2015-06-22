module?.exports = {
	columnDefs : [
		{
			field : 'item.fullName'
			displayName : 'Item'
		}
		{
			field : 'amount'
			width : 50
		}
	]
	onRegisterApi : (gridApi) !->
		gridApi.core.addRowHeaderColumn {
			name : 'rowHeaderCol'
			displayName : ''
			width : 100
			cellTemplate : 'GridRowHeader.html'
		}
}
