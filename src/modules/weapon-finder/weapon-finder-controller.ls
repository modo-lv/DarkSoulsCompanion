angular? .module "dsc" .controller "weaponFinderController" ($scope, storageSvc, weaponFinderSvc, uiGridConstants, statSvc) ->
	new WeaponFinderController ...

class WeaponFinderController
	(@$scope, @_storageSvc, @_weaponFinderSvc, @$uiGridConstants, @_statSvc) ->

		@setup!
		@load!
		@wireUp!


	setup : !~>
		@$scope.results = []

		@$scope.params = {
			statBonus : 0
			reqLimits : {
				\str : 20
				\dex : 20
				\int : 20
				\fai : 20
			}
			searchType : \offence
			includeUpgrades : true
			modifiers : {
				\atkPhy : 0
				\atkMag : 0
			}
		}

		@$scope.gridOptions = (require './config/weapon-finder-grid-options') @$uiGridConstants


	load : !~>
		@$scope.params <<< (@_storageSvc.load 'weapon-finder.params')


	wireUp : !~>
		for func in [
			\findWeapons
			\copyStatsToReqs
		]
			@$scope.[func] = @.[func]

		@$scope.$watch "params", (!~>
			@_storageSvc.save "weapon-finder.params", @$scope.params
		), true


	### EVENT HANDLERS

	copyStatsToReqs : !~>
		for key in [\str \dex \int \fai]
			@$scope.params.reqLimits[key] = @_statSvc.statValueOf key


	findWeapons : !~>
		@_weaponFinderSvc.params <<< @$scope.params

		@_weaponFinderSvc.findBestWeapons!
		.then (results) !~>
			@$scope.results = results |> map (result) ~> {
				weapon : result

				statReqs : [\reqStr \reqDex \reqInt \reqFai] |> (map ~> result.[it]) |> join '/'
				atk : [\atkPhy \atkMag \atkFir \atkLit] |> (map ~> Math.floor result.[it]) |> join '/'
				dps : [\dpsPhy \dpsMag \dpsFir \dpsLit] |> (map ~> Math.floor result.[it]) |> join '/'
			} <<< result

			@$scope.gridOptions.data = @$scope.results



module?.exports = WeaponFinderController