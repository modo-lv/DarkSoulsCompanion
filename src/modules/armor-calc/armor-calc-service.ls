angular? .module "dsc" .service "armorCalcSvc" (inventorySvc, itemSvc, itemUpgradeSvc, $q) ->
	new ArmorCalcSvc inventorySvc, itemSvc, itemUpgradeSvc, $q

class ArmorCalcSvc
	(@_inventorySvc, @_itemSvc, @_itemUpgradeSvc, @$q) ->
		# Weight limit that the armor combinations must not exceed
		@freeWeight = 0
		@params = {}

		@armorTypes = [ \head \chest \hands \legs ]
		@armorTypeKeys = { \head : 0, \chest : 1, \hands : 2, \legs : 3 }


	findBestCombinations : (params) ~>
		if not params?
			params =
				takeBest : 10

		staticArmors = []
		dynamicArmors = []
		canAfford = []

		# Take armors that are withing the weight allowance.
		@findUsableArmors!

		# Put aside non-upgradeables and find combinations for upgradeables
		.then (armors) !~>
			staticArmors := armors |> filter -> (it.matSetId < 0)
			dynamicArmors := armors |> reject (.upgradeId < 0)

			return @findAllCombinationsOf dynamicArmors

		# Take the best combination(s) and discard all other upgradable armors
		.then (combinations) !~>

			for comb in combinations
				comb.score = @calculateScoreFor comb

			best = combinations |> sortBy (.score) |> reverse |> take params.\takeBest

			dynamicArmors := []
			for comb in best
				for armor in comb.armors
					dynamicArmors.push armor

			dynamicArmors := dynamicArmors |> unique

		# Find all upgradable versions for the best armors
		.then ~>
			promises = []
			for armor in dynamicArmors
				promises.push(
					@findAllAvailableUpgradesFor armor
					.then (upgrades) ~>
						#console.log upgrades
						dynamicArmors ++= upgrades
				)
			return @$q.all promises

		# Find all combinations of the upgradable armors and their upgrades
		.then ~>
			@_debugLog = false
			@findAllCombinationsOf dynamicArmors

		# Drop unaffordable combinations
		.then (combinations) ~>
			@takeOnlyAffordable combinations

		# Discard inferior duplicate combinations
		# (same armors but less upgraded),
		# add back in the un-upgradables and
		# and find all the combinations
		.then (combs) ~>
			#console.log combs
			sets = combs |> groupBy (.pieces) |> Obj.values
			best = []
			for set in sets
				best.push (set |> sortBy (.upgradeLevel) |> reverse |> first)

			bestArmors = []
			for set in best
				bestArmors ++= set.armors

			bestArmors = (bestArmors |> unique) ++ staticArmors

			#console.log (bestArmors |> map (.name))

			@findAllCombinationsOf bestArmors

		# Drop unaffordable combinations
		.then (combs) ~>
			@takeOnlyAffordable combs

		# Calculate scores and return
		.then (combs) ~>
			combs |> each @calculateScoreFor


	/**
	 * Given a list of combinations, only take those that the user can afford.
	 */
	takeOnlyAffordable : (combinations) ~>
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
		empties = []

		# Add (nothing)s if they aren't already in the armor list
		for type, index in @armorTypes
			empty = armors |> find -> it.armorType == type and it.weight == 0

			if not empty?
				empty = @_itemSvc.createItemModel {
					itemType : \armor
					name : "(bare #{type})"
					armorType : type
					weight : 0
					upgradeId : -1
					id : -(index + 1)
				}

				armors.push empty

			empties.push empty

		# Group by type and get number of pieces in each
		groupOf = armors |> groupBy (.armorType)
		lengths = [ groupOf.[\head], groupOf.[\chest], groupOf.[\hands], groupOf.[\legs] ]
			|> map -> it?.length or 0
		combCount = lengths |> product

		#console.log (groupOf |> Obj.values |> map -> it |> map (.name)), lengths

		# Index split points
		prod = 1
		splitAt = [ 0 0 0 0 ]
		for b in [ 1 3 0 2 ]
			prod *= lengths.[b]
			splitAt[b] = (combCount / prod)

		combinationIndex = {}
		indexes = [ 0 0 0 0 ]
		a = 0
		while ++a <= combCount
			combination = {
				armors : [null null null null]
				weight : 0
			}

			# Do the pieces in order chest, legs, head, hands,
			# since chest and legs are usually the heaviest and
			# the second heaviest pieces.
			log = []
			log.push "#{a} : #{indexes |> join ','}"
			ciKey = ""
			for b, key in (seq = [ 1 3 0 2 ])
				if combination.weight < @freeWeight
					piece = groupOf.[@armorTypes.[b]][indexes.[b]]
					log.push "#{combination.weight} < #{@freeWeight} => +#{indexes.[b]} (#{piece.name})"
					combination
						..armors.[b] = piece
						..weight += piece.weight
					ciKey += "#{if piece.id > 0 then indexes.[b] else piece.id},"
				else
					if combination.weight == @freeWeight
						log.push "#{combination.weight} == #{@freeWeight} => +#{empties.[b].name}"
						combination.armors.[b] = empties.[b]
						ciKey += "#{empties.[b].id},"
						if key > 0
							split = splitAt.[seq[key-1]]
							jumpTo = a + (split - a % split)
							if jumpTo != a
								log.push "Jumping to #{a} + (#{split} - #{a} % #{split}) = #{jumpTo}"
								a = jumpTo

			if combination.weight <= @freeWeight
				if combinationIndex[ciKey]?
					log.push "Combination [#{ciKey}] already added, skipping"
				else
					log.push "Adding combination [#{ciKey}] to list"
					combinationIndex[ciKey] = true
					combinations.push combination
				if @_debugLog
					console.log (log |> join "\n")

			#console.log combination

			for b in [ 1 3 0 2 ]
				if a % splitAt.[b] == 0
					indexes.[b] = (indexes.[b] + 1) % lengths.[b]
					break

			#console.log indexes

		for comb in combinations
			# Add armor names for debugging
			comb.names = comb.armors |> map -> it?.name
			comb.pieces = (comb.armors |> map ~> (@_itemUpgradeSvc.getBaseIdFrom it.id)) |> join ','
			#comb.upLevels = (comb.armors |> map (.upgradeLevel))
			comb.upgradeLevel = (comb.armors |> map ~> (it.upgradeLevel ? 0)) |> sum

		def.resolve combinations

		return def.promise


	calculateScoreFor : (combination) ~>
		combination.score = 0
		combination.detailScores = {}
		@params.modifiers ?= { phy : 2, poise : 1 }
		for armor in combination.armors
			armor.score = 0
			for mod in [\Phy \Mag \Fir \Lit \Blo \Tox \Cur \Poise]
				modifier = @params.modifiers[mod.toLowerCase!] ? 0
				score = (armor.["def#{mod}"] ? 0) * modifier
				armor.score += score
				combination.detailScores.[mod.toLowerCase!] = (combination.detailScores.[mod.toLowerCase!] ? 0) + score
			combination.score += armor.score

		return combination.score



	/**
	 * Find all upgrades that can be applied to a given item,
	 * within the limits
	 */
	findAllAvailableUpgradesFor : (armor) ~>
		if armor.id < 0 or armor.upgradeId < 0 then
			@$q.defer!
				..resolve []
				return ..promise

		upgradeList = []

		@_inventorySvc.load!
		.then (inventory) ~>
			materials = inventory |> filter (.itemType == \item ) |> map -> {} <<< it

			promise = @$q (resolve, reject) !-> resolve!

			for level from (@_itemUpgradeSvc.getUpgradeLevelFrom armor.id) + 1 to 10
				((materials, level) !~>
					#console.log level
					promise := promise
					.then ~>
						@_itemUpgradeSvc .are materials .enoughToUpgrade armor, level
					.then (canUpgrade) !~>
						if canUpgrade
							return @$q.all [
								@_itemSvc.getUpgraded armor, level
								@_itemUpgradeSvc.deductFrom materials .costOfUpgrade armor, level
							]
						else
							materials.length = 0
							return null
					.then (result) !~>
						upArmor = result?.0
						cost = result?.1
						if upArmor?
							totalCost = materials.[]totalCost
							costEntry = totalCost |> find (.matId == cost.matId)
							if not costEntry?
								costEntry = {
									matId : cost.matId
									matCost : 0
								}
								totalCost.push costEntry

							costEntry.matCost += cost.matCost
							upArmor
								..totalCost = totalCost |> map -> {} <<< it
								# Upgrade level counting from the starting level as it's in the inventory
								..upgradeLevel = level - @_itemUpgradeSvc.getUpgradeLevelFrom armor.id

							upgradeList.push upArmor
				) materials, level
			return promise
		.then ->
			#console.log upgradeList
			return upgradeList



module?.exports = ArmorCalcSvc