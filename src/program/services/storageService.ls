angular.module "dsc.services"
	.config (localStorageServiceProvider) !->
		localStorageServiceProvider
			.setPrefix "DSC"
	.service 'storageService', ['localStorageService', (localStorage) ->
		{
			save : (key, data) !-> localStorage.set key, data
			load : (key) -> localStorage.get key
		}
	]