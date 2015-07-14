angular? .module "dsc" .controller "weaponFinderController" ($scope, storageSvc, weaponFinderSvc, uiGridConstants) ->
	new WeaponFinderController ...

class WeaponFinderController
	(@$scope, @_storageSvc, @_weaponFinderSvc, @$uiGridConstants) ->

		@setup!
		@load!
		@wireUp!


	setup : !~>
		@$scope.results = []

		@$scope.params = {
			statBonus : 0
			searchType : \offence
		} <<< (@_storageSvc.load 'weapon-finder.params')

		@$scope.gridOptions = (require './config/weapon-finder-grid-options') @$uiGridConstants

	load : !~>


	wireUp : !~>
		for func in [
			\findWeapons
		]
			@$scope.[func] = @.[func]

		@$scope.$watch "params", (!~>
			@_storageSvc.save "weapon-finder.params", @$scope.params
		), true


	### Event handlers
	findWeapons : !~>
		@_weaponFinderSvc.params <<< @$scope.params

		@_weaponFinderSvc.findBestWeapons!
		.then (results) !~>
			@$scope.results = results |> map (result) ~> {
				weapon : result
			} <<< result

			@$scope.gridOptions.data = @$scope.results



module?.exports = WeaponFinderController