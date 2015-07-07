angular? .module "dsc" .service "armorCalcSvc" (inventorySvc, itemSvc, $q) ->
	new ArmorCalcSvc inventorySvc, itemSvc, $q

class ArmorCalcSvc
	(@_inventorySvc, @_itemSvc, @$q) ->
		# Weight limit that the armor combinations must not exceed
		@freeWeight = 0

		@armorTypes = [ \head \chest \hands \legs ]
		@armorTypeKeys = { \head : 0, \chest : 1, \hands : 2, \legs : 3 }

	/**
	 * Find armors fit for using in calculations.
	 */
	findUsableArmors : ~>
		@_inventorySvc .load!
		.then (inventory) ~>
			@$q.all (inventory
				|> filter ( .itemType == \armor )
				|> map (entry) ~> @_itemSvc.findAnyItem (.uid == entry.uid)
			)
		.then (armors) ~>
			armors |> filter ~> it.weight <= @freeWeight


	/**
	 * Take a list of armors and generate every possible combination of them
	 * within the current weight limit.
	 * @returns Promise that will be resolved with an array of combinations.
	 */
	findAllCombinationsOf : (armors) !~>
		def = @$q.defer!
		combinations = []

		# Add (nothing)s if they aren't already in the armor list
		for type, index in @armorTypes
			if not (armors |> any -> it.armorType == type and it.weight == 0)
				armors.push @_itemSvc.createItemModel {
					itemType : \armor
					name : "(nothing)"
					armorType : type
					weight : 0
					upgradeId : -1
					id : -1
				}

		groupOf = armors |> groupBy (.armorType)

		lengths = [ groupOf.[\head], groupOf.[\chest], groupOf.[\hands], groupOf.[\legs] ]
			|> map -> it.length

		combCount = lengths |> product

		# start with chest and leg armor which are usually the
		# heaviest so as to eliminate overweight combinations
		# as early as possible
		indexes = [ 0 0 0 0 ]
		for a from 1 to combCount
			combination = {
				armors : [{},{},{},{}]
				weight : 0
			}
			for b in [ 1 3 0 2 ]
				piece = groupOf.[@armorTypes.[b]][indexes.[b]]

				combination
					..armors.[b] = piece
					..weight += piece.weight

				if combination.weight > @freeWeight
					break
				if combination.weight == @freeWeight or b == 2
					combinations.push combination
					if b != 2
						break

			prod = 1
			for b in [ 1 3 0 2 ]
				prod *= lengths.[b]
				if a % (combCount / prod) == 0
					indexes.[b] = (indexes.[b] + 1) % lengths.[b]
					break

		def.resolve combinations

		return def.promise


module?.exports = ArmorCalcSvc
