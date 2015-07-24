angular? .module "dsc" .controller "weaponFinderController" ($scope, storageSvc, weaponFinderSvc, uiGridConstants, statSvc, itemSvc) ->
	new WeaponFinderController ...

class WeaponFinderController
	(@$scope, @_storageSvc, @_weaponFinderSvc, @$uiGridConstants, @_statSvc, @_itemSvc) ->
		@setup!
		@load!
		@wireUp!


	setup : !~>
		@$scope.results = []

		@$scope.paramSetNames = [ \weapon \shield ]

		@$scope.statArray = @_weaponFinderSvc.statArray
		@$scope.reqLimitArray = @_statSvc.@@weaponStats

		@$scope.statNames = @_statSvc.@@statNames

		@$scope.dpsCalcOptions = [
			"One-hand light"
			"One-hand heavy"
			"Two-hand light"
			"Two-hand heavy"
		]

		# Set default params
		for a from 0 to 1
			@$scope.[]paramSets.{}[a] <<< @_weaponFinderSvc.params

		@$scope.gridOptions = (require './config/weapon-finder-grid-options') @$uiGridConstants


	load : !~>
		# Load user's params
		userSets = (@_storageSvc.load 'weapon-finder.param-sets') ? []
		console.log userSets

		for set, a in @$scope.paramSets
			@$scope.paramSets[a] <<< userSets[a]

		@$scope.params = @$scope.paramSets.0


	wireUp : !~>
		for func in [
			\findWeapons
			\copyStatsToReqs
		]
			@$scope.[func] = @.[func]

		@$scope.$watch "paramSets", (!~>
			@_storageSvc.save "weapon-finder.param-sets", @$scope.paramSets
		), true


	### EVENT HANDLERS

	copyStatsToReqs : !~>
		for key in [\str \dex \int \fai]
			@$scope.params.reqLimits[key] = @_statSvc.statValueOf key


	findWeapons : !~>
		@_weaponFinderSvc.params <<< @$scope.params

		@_weaponFinderSvc.findBestWeapons!
		.then (results) !~>
			@$scope.results = results |> map (result) ~> result <<< {
				statReqs : [\reqStr \reqDex \reqInt \reqFai] |> (map ~> result.[it]) |> join '/'
				atk : [\atkPhy \atkMag \atkFir \atkLit] |> (map ~> Math.floor result.[it]) |> join '/'
				def : @_itemSvc.@@DefenseTypes |> (map ~> Math.floor result.[it]) |> join '/'
				dps : "#{(result.dps |> join '/')} (#{result.atkCost})"
			}

			@$scope.gridOptions.data = @$scope.results



module?.exports = WeaponFinderController