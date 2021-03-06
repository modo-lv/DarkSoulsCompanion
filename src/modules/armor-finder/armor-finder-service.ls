angular? .module "dsc" .service "armorFinderSvc" (inventorySvc, itemSvc, $q) ->
	new ArmorFinderSvc ...

class ArmorFinderSvc
	(@_inventorySvc, @_itemSvc, @$q) ->
		# Weight limit that the armor combinations must not exceed
		@freeWeight = 0
		@params = {
			resultLimit : 20

			modifiers : {
				def : 0
			}
		}
		@_debugLog = true

		@armorTypes = [ \head \chest \hands \legs ]
		@armorTypeKeys = { \head : 0, \chest : 1, \hands : 2, \legs : 3 }


	findBestCombinations : ~>
		if not @.{}params.includeUpgrades? then @params.includeUpgrades = true

		start = null

		# Take armors that are within the weight allowance.
		@findUsableArmors!

		.then (armors) ~>
			# Clear out any old scores
			for armor in armors
				delete armor.score

			@calculateArmorScores armors

			if @params.includeUpgrades
				@findCombinationsWithUpgrades armors
			else
				start := new Date!.getTime!
				combs = @findAllCombinationsOf armors
				end = new Date!.getTime!
				time = end - start
				if @_debugLog
					console.log "Permutated #{armors.length} armors into #{combs.length} combinations in #{time / 1000} seconds"

				start := new Date!.getTime!
				@calculateCombinationScores combs
				.then (combs) ~>
					end = new Date!.getTime!
					time = end - start
					if @_debugLog
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
		staticArmors = armors
		dynamicArmors = armors |> reject (.matSetId < 0)

		combinations = @findAllCombinationsOf dynamicArmors

		end = new Date!.getTime!
		time = end - start
		if @_debugLog
			console.log "Permutated #{dynamicArmors.length} upgradeable armors into #{combinations.length} combinations in #{time / 1000} seconds"

		start := new Date!.getTime!

		@calculateCombinationScores combinations, 10
		.then (best) ~>

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
			upgradedArmors = []
			promises = []
			for armor in dynamicArmors
				promises.push(
					@_inventorySvc.findAllAvailableUpgradesFor armor
					.then (upgrades) ~>
						for upgrade in upgrades
							delete upgrade.score
						#console.log upgrades
						upgradedArmors ++= upgrades
				)

			@$q.all promises

		# Find all combinations of the upgradable armors and their upgrades
		.then (upgradedArmors)~>
			dynamicArmors = upgradedArmors |> flatten

			# Clear out leftovers
			upgradedArmors = null

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
			dynamicArmors = []
			for comb in combs
				for armor in comb.armors
					dynamicArmors.push armor

			dynamicArmors = (dynamicArmors ++ staticArmors) |> unique
			end = new Date!.getTime!
			time = end - start
			if @_debugLog
				console.log "Extracted and merged #{dynamicArmors.length} armors, upgrades and un-upgradable armors in #{time / 1000} seconds"

			start := new Date!.getTime!

			combs = @findAllCombinationsOf dynamicArmors

			end = new Date!.getTime!
			time = end - start
			if @_debugLog
				console.log "Permutated #{dynamicArmors.length} armors, upgrades and un-upgradable armors into #{combs.length} combinations in #{time / 1000} seconds"

			dynamicArmors = null

			start := new Date!.getTime!

			for comb in combs
				comb.armors = @calculateArmorScores comb.armors

			end = new Date!.getTime!
			time = end - start
			if @_debugLog
				console.log "Calculated armor scores for #{combs.length} combinations in #{time / 1000} seconds"

			start := new Date!.getTime!

			return @calculateCombinationScores combs, @params.resultLimit, true
		.then (combs) ~>
			end = new Date!.getTime!
			time = end - start
			if @_debugLog
				console.log "Calculated scores and found the best #{combs.length} affordable combinations in #{time / 1000} seconds"

			return combs

	canAfford : (comb) ~>
		having : (inventory) ~>
			comb.totalCost = []
			unUpgraded = 0
			# Find the total cost of the combination
			for armor in comb.armors
				if not armor.totalCost?
					unUpgraded++
					continue

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

			can = true

			if unUpgraded < 4
				#console.log comb.names, "has total price", comb.totalCost, ", user has", (materials |> map -> [it.id, it.amount])

				for cost in comb.totalCost
					material = null
					for mat in inventory
						if mat.id == cost.matId
							material = mat
							break

					if not (material? and material.amount >= cost.matCost)
						can = false

			return can


	/**
	 * Given a list of combinations, only take those that the user can afford.
	 */
	takeOnlyAffordable : (combinations) ~>
		@_inventorySvc.load!
		.then (inventory) !~>
			canAfford = []

			for a from combinations.length - 1 to 0 by -1
				comb = combinations.pop!

				if @canAfford comb .having inventory
					canAfford.push comb

			return canAfford


	/**
	 * Find armors fit for using in calculations.
	 */
	findUsableArmors : ~>
		@_inventorySvc .load!
		.then (inventory) ~>
			promises = []
			for entry in inventory
				if not entry.itemType?
					console.log entry
					throw new Error "Above inventory entry does not have an [.itemType] set:"
				if entry.itemType != \armor
					continue
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
					itemType : \armor
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

		if @_debugLog
			console.log "Lengths:", lengths

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
		for armor in armors
			if armor.score? then continue
			armor.score = 0
			armor.detailScores = {}
			for name, index in @_itemSvc.@@DefenseTypes
				armor.detailScores[name] = armor.def[index] ? 0
				armor.score += (armor.def[index] ? 0) * (@params.{}modifiers.def[index] ? 0)


		return armors


	calculateCombinationScores : (combinations, limit = @params.resultLimit, checkAffordability = false) ~>
		@_inventorySvc.load!
		.then (inventory) !~>
			best = []

			for a from 0 til limit
				if not (comb = combinations.pop!)? then continue
				comb.score = comb.armors.0.score + comb.armors.1.score + comb.armors.2.score + comb.armors.3.score
				if isNaN(comb.score)
					console.log comb
					throw new Error "Combination above does not have a score."
				best.push comb

			for a from limit til combinations.length
				comb = combinations.pop!
				comb.score = comb.armors.0.score + comb.armors.1.score + comb.armors.2.score + comb.armors.3.score

				for a from 0 til limit
					if comb.score > best.[a].score and ((not checkAffordability) or @canAfford comb .having inventory)
						best.[a] = comb
						break

			return best


module?.exports = ArmorFinderSvc