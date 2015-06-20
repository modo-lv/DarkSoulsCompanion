module?.exports = {
	columnDefs : [
		{
			field : 'name'
			displayName : 'Item'
		}
		{
			field : 'amount'
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
