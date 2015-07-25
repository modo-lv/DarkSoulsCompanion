angular? .module "dsc" .controller "weaponFinderController" ($scope, storageSvc, weaponFinderSvc, uiGridConstants, statSvc, itemSvc) ->
	new WeaponFinderController ...

class WeaponFinderController
	(@$scope, @_storageSvc, @_weaponFinderSvc, @$uiGridConstants, @_statSvc, @_itemSvc) ->
		@setup!
		@load!
		@wireUp!


	setup : !~>
		@$scope.results = []

		@$scope.paramSetNames = [ \weapons \shields ]

		@$scope.statArray = @_itemSvc.@@WeaponStats

		@$scope.atkNames = @_itemSvc.@@AllAttackTypeNames

		@$scope.defNames = @_itemSvc.@@DefenseTypeNames

		@$scope.statNames = @_statSvc.@@statNames

		@$scope.dpsCalcOptions = [
			"One-hand light"
			"One-hand heavy"
			"Two-hand light"
			"Two-hand heavy"
		]

		@$scope.params = @_weaponFinderSvc.params <<< {
			usePlayers : true
		}

		# Set default params
		for a from 0 to 1
			@$scope.[]paramSets.{}[a] <<< @$scope.params
			for array in [\atk \def \stats]
				@$scope.paramSets[a].[array] = @$scope.paramSets[a].[][array].slice!


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
			@$scope.params.stats[key] = @_statSvc.statValueOf key


	findWeapons : !~>
		@_weaponFinderSvc.params <<< @$scope.params

		if @$scope.params.usePlayers
			@_weaponFinderSvc.params.stats = [\str \dex \int \fai] |> map ~> @_statSvc.statValueOf it

		@_weaponFinderSvc.findBestWeapons!
		.then (results) !~>
			@$scope.results = results |> map (result) ~> result <<< {
				statReqs : result.req.join '/'
				atk : (result.atk |> map -> Math.floor it).join '/'
				def : (result.def |> map -> Math.floor it).join '/'
				dps : "#{(result.dps |> join '/')}#{if result.atkCost then ' ('+result.atkCost+')' else ''}"
			}

			@$scope.gridOptions.data = @$scope.results



module?.exports = WeaponFinderController