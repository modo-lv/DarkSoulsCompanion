angular? .module "dsc" .service "armorCalcSvc" (inventorySvc, itemSvc, $q) ->
	new ArmorCalcSvc ...

class ArmorCalcSvc
	(@_inventorySvc, @_itemSvc, @$q) ->
		# Weight limit that the armor combinations must not exceed
		@freeWeight = 0
		@params = {}
		@_debugLog = true

		@armorTypes = [ \head \chest \hands \legs ]
		@armorTypeKeys = { \head : 0, \chest : 1, \hands : 2, \legs : 3 }


	findBestCombinations : ~>
		if not @.{}params.includeUpgrades? then @params.includeUpgrades = true

		start = null

		# Take armors that are within the weight allowance.
		@findUsableArmors!

		# Put aside non-upgradeables and find combinations for upgradeables
		.then (armors) ~>
			start := new Date!.getTime!
			@calculateArmorScores armors
			end = new Date!.getTime!
			time = end - start
			console.log "Calculated scores for #{armors.length} armors in #{time / 1000} seconds"
			if @params.includUpgrades
				; # @findCombinationsWithUpgrades armors
			else
				start := new Date!.getTime!
				@findAllCombinationsOf armors
				.then (combs) ~>
					end = new Date!.getTime!
					time = end - start
					console.log "Permutated #{armors.length} armors into #{combs.length} combinations in #{time / 1000} seconds"

					start := new Date!.getTime!
					combs = @calculateCombinationScores combs
					end = new Date!.getTime!
					time = end - start
					console.log "Calculated scores and found the best #{combs.length} combinations in #{time / 1000} seconds"

					return combs
		.then (combs) ~>
			for comb in combs
				comb.detailScores = {}
				for armor in comb.armors
					for key, val of armor.detailScores
						if not comb.detailScores[key]?
							comb.detailScores[key] = 0
						comb.detailScores[key] += val
			return combs


	findCombinationsWithUpgrades : (armors) ~>
		start = new Date!.getTime!
		staticArmors = armors |> filter (.matSetId < 0)
		dynamicArmors = armors |> reject (.matSetId < 0)

		@findAllCombinationsOf dynamicArmors

		# Take the best combination(s) and discard all other upgradable armors
		.then (combinations) !~>
			@calculateScoreFor combinations

			end = new Date!.getTime!
			time = end - start
			if @_debugLog
				console.log "Permutated and scored #{combinations.length} combinations in #{time / 1000} seconds"

			start := new Date!.getTime!

			if @params.includeUpgrades
				scores = []
				for comb in combinations
					scores.push comb.score


				best = [0 til 50]

				for a from 10 til scores.length
					for bestScore, b in best
						if scores[a] > bestScore
							best[b] = a
							break

				for a from 0 til best.length
					best[a] = combinations[best[a]]

				dynamicArmors.length = 0
				for comb in best
					for armor in comb.armors
						dynamicArmors.push armor

				dynamicArmors := dynamicArmors |> unique

			end = new Date!.getTime!
			time = end - start
			if @_debugLog
				console.log "Found the best #{dynamicArmors.length} armors in #{time / 1000} seconds"

			return dynamicArmors

		# Find all upgradable versions for the best armors
		.then ~>
			if not @params.includeUpgrades
				return dynamicArmors

			promises = []
			for armor in dynamicArmors
				promises.push(
					@_itemSvc.upgradeComp.findAllAvailableUpgradesFor armor
					.then (upgrades) ~>
						#console.log upgrades
						dynamicArmors ++= upgrades
				)
			return @$q.all promises

		# Find all combinations of the upgradable armors and their upgrades
		.then ~>
			if @params.includeUpgrades
				@findAllCombinationsOf dynamicArmors
			else
				return

		# Drop unaffordable combinations
		.then (combinations) ~>
			@takeOnlyAffordable combinations

		# Discard inferior duplicate combinations
		# (same armors but less upgraded),
		# add back in the un-upgradables and
		# and find all the combinations
		.then (combs) ~>
			bestArmors = []
			console.log (@params.includeUpgrades)
			if @params.includeUpgrades
				#console.log combs
				sets = combs |> groupBy (.pieces) |> Obj.values
				best = []
				for set in sets
					best.push (set |> sortBy (.upgradeLevel) |> reverse |> first)

				for set in best
					bestArmors ++= set.armors

				bestArmors = (bestArmors |> unique) ++ staticArmors
			else
				bestArmors = dynamicArmors

			console.log (dynamicArmors |> map (.name))
			console.log (bestArmors |> map (.name))

			@findAllCombinationsOf bestArmors

		# Drop unaffordable combinations
		.then (combs) ~>
			@takeOnlyAffordable combs

		# Calculate scores and return
		.then (combs) ~>
			@calculateScoreFor combs


	/**
	 * Given a list of combinations, only take those that the user can afford.
	 */
	takeOnlyAffordable : (combinations) ~>
		if not @params.includeUpgrades
			return combinations

		canAfford = []
		for comb in combinations
			comb.totalCost = []
			promises = []
			for armor in comb.armors |> filter (.totalCost?)
				for aCost in armor.totalCost
					cCost = comb.totalCost |> find (.matId == aCost.matId)
					if not cCost?
						cCost = {
							matId : aCost.matId
							matCost : 0
						}
						comb.totalCost.push cCost
					cCost.matCost += aCost.matCost

			promises.push (((comb) ~>
				@_inventorySvc.load!.then (inventory) !->
					materials = inventory |> filter (.itemType == \item)

					#console.log comb.names, "has total price", comb.totalCost, ", user has", (materials |> map -> [it.id, it.amount])

					can = true
					for cost in comb.totalCost
						material = materials |> find (.id == cost.matId)
						if not (material? and material.amount >= cost.matCost)
							can = false

					if can
						canAfford.push comb
						#console.log "can afford"
						return comb
					else
						return null
			) comb)

		return @$q.all promises .then ~> canAfford


	/**
	 * Find armors fit for using in calculations.
	 */
	findUsableArmors : ~>
		@_inventorySvc .load!
		.then (inventory) ~>
			promises = []
			for entry in inventory |> filter (.itemType == \armor )
				let entry = entry
					promises.push @_itemSvc.findAnyItemByUid entry.uid
			return @$q.all promises
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
		empties = []

		# Add (nothing)s if they aren't already in the armor list
		for type, index in @armorTypes
			empty = armors |> find -> it.armorType == type and it.id < 0

			if not empty?
				empty = {
					name : "(bare #{type})"
					armorType : type
					weight : 0
					upgradeId : -1
					id : -(index + 1)
					score : 0
				}

				armors.push empty

			empties.push empty

		# Group by type and get number of pieces in each
		groupOf = armors |> groupBy (.armorType)
		lengths = [ groupOf.[\head], groupOf.[\chest], groupOf.[\hands], groupOf.[\legs] ]
			|> map -> it?.length or 0
		combCount = lengths |> product

		pieces = [null null null null]
		a = lengths.0 - 1
		do
			pieces.0 = groupOf.[\head].[a]
			pieces.1 = pieces.2 = pieces.3 = null
			b = lengths.1 - 1
			do
				pieces.1 = groupOf.[\chest].[b]
				pieces.2 = pieces.3 = null
				c = lengths.2 - 1
				do
					pieces.2 = groupOf.[\hands].[c]
					pieces.3 = null
					d = lengths.3 - 1
					do
						pieces.3 = groupOf.[\legs].[d]
						weight = 0
						weight = pieces[0].weight + pieces[1].weight + pieces[2].weight + pieces[3].weight
						upgradeLevel =
							pieces[0].upgradeLevel + pieces[1].upgradeLevel + pieces[2].upgradeLevel + pieces[3].upgradeLevel
						if weight <= @freeWeight
							combinations.push {
								armors : [] ++ pieces
								weight : weight
								upgradeLevel : upgradeLevel
							}
					while --d >=0
				while --c >= 0
			while --b >= 0
		while --a >= 0

		def.resolve combinations

		return def.promise


	calculateArmorScores : (armors) !~>
		modSet = [
			[\phy \defPhy]
			[\mag \defMag]
			[\fir \defFir]
			[\lit \defLit]
			[\blo \defBlo]
			[\tox \defTox]
			[\cur \defCur]
			[\poise \defPoise]
		]

		for armor in armors
			armor.score = 0
			armor.detailScores = {}
			for mod in modSet
				armor.detailScores[mod.0] = armor.[mod.1] * @params.modifiers[mod.0]
				armor.score += armor.detailScores[mod.0]


	calculateCombinationScores : (combinations) ~>
		best = for from 0 til @params.resultLimit
			-1
		min = 10000

		for comb in combinations by -1
			comb.score = comb.armors.0.score + comb.armors.1.score + comb.armors.2.score + comb.armors.3.score

			for a from 0 til @params.resultLimit
				if best.[a] == -1 or comb.score > best.[a].score
					best.[a] = comb
					break



		return best |> filter (!= -1)


module?.exports = ArmorCalcSvc