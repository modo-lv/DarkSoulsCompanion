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

		.then (armors) ~>
			@calculateArmorScores armors

			if @params.includeUpgrades
				@findCombinationsWithUpgrades armors
			else
				start := new Date!.getTime!
				@findAllCombinationsOf armors
				.then (combs) ~>
					end = new Date!.getTime!
					time = end - start
					#console.log "Permutated #{armors.length} armors into #{combs.length} combinations in #{time / 1000} seconds"

					start := new Date!.getTime!
					combs = @calculateCombinationScores combs
					end = new Date!.getTime!
					time = end - start
					#console.log "Calculated scores and found the best #{combs.length} combinations in #{time / 1000} seconds"

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

		combinations = @findAllCombinationsOf dynamicArmors

		end = new Date!.getTime!
		time = end - start
		console.log "Permutated #{dynamicArmors.length} upgradeable armors into #{combinations.length} combinations in #{time / 1000} seconds"

		start := new Date!.getTime!

		best = @calculateCombinationScores combinations, 40

		end = new Date!.getTime!
		time = end - start
		if @_debugLog
			console.log "Scored and found the #{best.length} best combinations in #{time / 1000} seconds"

		dynamicArmors.length = 0
		for comb in best
			for armor in comb.armors
				dynamicArmors.push armor

		dynamicArmors := dynamicArmors |> unique

		# Find all upgradable versions for the best armors
		promises = []
		for armor in dynamicArmors
			promises.push(
				@_itemSvc.upgradeComp.findAllAvailableUpgradesFor armor
				.then (upgrades) ~>
					#console.log upgrades
					dynamicArmors ++= upgrades
			)

		@$q.all promises

		# Find all combinations of the upgradable armors and their upgrades
		.then (armors)~>
			start := new Date!.getTime!
			combs = @findAllCombinationsOf dynamicArmors

			end = new Date!.getTime!
			time = end - start
			if @_debugLog
				console.log "Permutated #{dynamicArmors.length} armors & upgrades into #{combs.length} combinations in #{time / 1000} seconds"

			start := new Date!.getTime!
			@takeOnlyAffordable combs

		.then (combs) ~>
			end = new Date!.getTime!
			time = end - start
			if @_debugLog
				console.log "Kept #{combs.length} affordable combinations in #{time / 1000} seconds"

			start := new Date!.getTime!
			allArmors = []
			for comb in combs
				for armor in comb.armors
					allArmors.push armor
			allArmors = (allArmors ++ staticArmors) |> unique
			end = new Date!.getTime!
			time = end - start
			if @_debugLog
				console.log "Extracted and merged #{allArmors.length} armors, upgrades and un-upgradable armors in #{time / 1000} seconds"


			start := new Date!.getTime!
			combs = @findAllCombinationsOf allArmors
			end = new Date!.getTime!
			time = end - start
			if @_debugLog
				console.log "Permutated #{allArmors.length} armors, upgrades and un-upgradable armors into #{combs.length} combinations in #{time / 1000} seconds"

			for comb in combs
				comb.armors = @calculateArmorScores comb.armors

			start := new Date!.getTime!

			combs = @calculateCombinationScores combs

			end = new Date!.getTime!
			time = end - start
			if @_debugLog
				console.log "Calculated scores and found the best #{combs.length} combinations in #{time / 1000} seconds"

			return combs


	/**
	 * Given a list of combinations, only take those that the user can afford.
	 */
	takeOnlyAffordable : (combinations) ~>
		canAfford = []

		@_inventorySvc.load!
		.then (inventory) !~>
			for comb in combinations
				comb.totalCost = []

				# Find the total cost of the combination
				for armor in comb.armors
					if not armor.totalCost? then continue

					for aCost in armor.totalCost
						# Find the existing combination cost record
						# if it exists
						cCost = null
						for x in comb.totalCost
							if x.matId == aCost.matId
								cCost = x
								break

						# Insert a new cost record if it doesn't exist
						if not cCost?
							cCost = {
								matId : aCost.matId
								matCost : 0
							}
							comb.totalCost.push cCost

						# Add the armor upgrade cost to the total cost of the combination
						cCost.matCost += aCost.matCost


				materials = []
				for item in inventory
					if item.itemType == \item
						materials.push item

				#console.log comb.names, "has total price", comb.totalCost, ", user has", (materials |> map -> [it.id, it.amount])

				can = true
				for cost in comb.totalCost
					material = null
					for mat in materials
						if mat.id == cost.matId
							material = mat
							break

					if not (material? and material.amount >= cost.matCost)
						can = false

				if can
					canAfford.push comb

			return canAfford


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

		return combinations


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
			if armor.score? then continue
			armor.score = 0
			armor.detailScores = {}
			for mod in modSet
				armor.detailScores[mod.0] = armor.[mod.1]
				armor.score += armor.[mod.1] * @params.modifiers[mod.0]


		return armors


	calculateCombinationScores : (combinations, limit = @params.resultLimit) ~>
		best = for from 0 til limit
			-1

		for comb in combinations by -1
			comb.score = comb.armors.0.score + comb.armors.1.score + comb.armors.2.score + comb.armors.3.score

			for a from 0 til limit
				if best.[a] == -1 or comb.score > best.[a].score
					best.[a] = comb
					break

		return best |> filter (!= -1)


module?.exports = ArmorCalcSvc