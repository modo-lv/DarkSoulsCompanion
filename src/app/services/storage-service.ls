angular.module "dsc"
	.config (localStorageServiceProvider) !->
		localStorageServiceProvider
			.setPrefix "DSC"
	.service 'storageSvc', ['localStorageService', (localStorage) ->
		{
			save : (key, data) !-> localStorage.set key, data
			load : (key) -> localStorage.get key
		}
	]