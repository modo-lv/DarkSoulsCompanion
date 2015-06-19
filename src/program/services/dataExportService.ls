angular.module "dsc.services"
	.service 'dataExportService', ->
		{
			exportJson : (data) !->
				window.open encodeURI "data:application/json,#{JSON.stringify data }"
		}