angular?.module "dsc" .controller "mainController" ($scope, $location, storageSvc, inventorySvc, notificationSvc, $route) ->
	new MainController ...

class MainController
	(@$scope, @$location, @_storageSvc, @_inventorySvc, @_notificationSvc, @$route) ->
		@$scope.profileEditStatus = null
		@$scope.newProfileName = ''
		@$scope.currentProfile = ''

		@$scope.$watch (~> @$location.path!), !~> @$scope.thisLocation = it

		@setup!

		@loadAndInit!

		@wireUp!


	setup : !~>
		@$scope.menu = [
			{ path : "/tracker" name : "Game state tracker" }
			{ path : "/pc" name : "Stats & inventory" }
			{ path : "/armor-calc" name : "Armor finder" }
			{ path : "/weapon-finder" name : "Weapon & shield finder" }
			{ path : "/items" name : "Item data" }
		]


	loadAndInit : !~>
		@_storageSvc.switchToCurrentProfile!
		@profilesUpdated!


	wireUp : !~>
		for func in [
			\addNewProfile \switchProfile \deleteProfile \resetProfile
			\resetProfileEditStatus
			\dismissNotifications
		]
			@$scope.[func] = @.[func]


	### EVENT HANDLERS

	profilesUpdated : !~>
		@$scope.profileList = @_storageSvc.loadProfileList!
		@$scope.currentProfile = @_storageSvc.profileName
		@resetProfileEditStatus!


	addNewProfile : !~>
		if @$scope.profileEditStatus == \new
			@_storageSvc.addProfile @$scope.newProfileName
			@profilesUpdated!
			@switchProfile!
		else
			@$scope.profileEditStatus = \new


	switchProfile : !~>
		@_storageSvc.switchTo @$scope.currentProfile
		@$route.reload!


	deleteProfile : !~>
		if @$scope.profileEditStatus == \delete
			@_storageSvc.deleteProfile!
			@profilesUpdated!
			@switchProfile!
		else
			@$scope.profileEditStatus = \delete


	resetProfileEditStatus : !~>
		@$scope.profileEditStatus = null


	resetProfile : !~>
		@_storageSvc.clearProfile!
		@switchProfile!


	dismissNotifications : !~>
		@_notificationSvc.clear!


module?.exports = MainController