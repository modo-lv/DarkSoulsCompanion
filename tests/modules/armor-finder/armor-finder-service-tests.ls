_ <-! describe "armor-finder-service"

var svc

beforeEach (done) !->
	createServiceStack!
	svc := new (testRequire 'modules/armor-finder/armor-finder-service') inventorySvc, itemSvc, $q

	# Setup default data
	inventory = require './test-data/armor-finder-test-inventory.json'
	armors = require './test-data/armor-finder-test-armors.json'
	materialSets = require './test-data/armor-finder-material-sets.json'
	upgrades = require './test-data/armor-finder-upgrades.json'
	index = require './test-data/armor-finder-index.json'

#	inventory = require './test-data/temp-inventory.json'
#	armors = testRequire './modules/items/content/armors.json'
#	materialSets = testRequire './modules/items/content/material-sets.json'
#	upgrades = testRequire './modules/items/content/armor-upgrades.json'
#	index = testRequire './modules/items/content/index.json'

	storageSvc.loadReturnValue = inventory


	edSvc.loadJsonReturnValue = materialSets
	itemSvc.upgradeComp.loadAllMaterialSets!
	.then ->
		edSvc.loadJsonReturnValue = upgrades
		itemSvc.upgradeComp.loadAllUpgrades \armor
	.then ->
		edSvc.loadJsonReturnValue = armors
		itemSvc.loadAllItems \armor
	.then ->
		edSvc.loadJsonReturnValue = index
		itemIndexSvc.loadAllEntries!
	.then ->
		done!



it "should correctly find potential armors", (done) !->
	svc.freeWeight = 3

	svc.findUsableArmors!
	.then (armors) !->
		expect armors .to.have.length 3
		for armor in armors
			expect armor .to.have.property \itemType, \armor
			expect armor .to.have.property \weight .at.most svc.freeWeight
		done!
	.catch done


it "should correctly generate armor combinations", !->
	armors = [
		{
			\id : 100
			\name : "One"
			\weight : 1
			\armorType : \head
		}
		{
			\id : 200
			\name : "Two"
			\weight : 2
			\armorType : \hands
		}
		{
			\id : 300
			\name : "Three"
			\weight : 3
			\armorType : \chest
		}
		{
			\id : 400
			\name : "Four"
			\weight : 4
			\armorType : \legs
		}
	]

	svc.freeWeight = 4
	#svc._debugLog = true

	# 4 slots * 2 possible values each = 2*2*2*2 = 16 possible combinations
	# Weight limit 4 means:
	#   "Four" can't combine with any combination of the lighter three: -(2*2*2)
	#		except if all three are empties: +1
	# 		== -7
	#   "Three" can't combine with any combination of the lighter two: -(2*2)
	# 		except if one of them is empty +(1+1)
	# 		== -2
	# 16 - 7 - 2 = 7
	expectedCount = 7

	svc.findAllCombinationsOf armors
	|> (combinations) !->
		expect combinations
			.to.have.length expectedCount
		#console.log combinations


it "should correctly calculate score for a set of armors", !->
	svc.{}params.{}modifiers.fir = 0.5

	armors = [
		{
			"defFir" : 100
		},
		{
			"defFir" : 200
		},
	]

	armors = svc.calculateArmorScores armors

	expect armors.0.score .to.equal 50
	expect armors.1.score .to.equal 100

it "should correctly calculate scores for a set of combinations", !->
	combinations = [
		{
			armors : [
				{score : 10}
				{score : 10}
				{score : 10}
				{score : 10}
			]
		}
		{
			armors : [
				{ score : 10 }
				{ score : 20 }
				{ score : 30 }
				{ score : 40 }
			]
		}
	]

	best = svc.calculateCombinationScores combinations

	expect best.1.score .to.equal 40
	expect best.0.score .to.equal 100


it "should correctly find all available upgrades for a piece of armor", (done) !->
	itemSvc.findItem \armor, (.id == 11000)
	.then (armor) ->
		inventorySvc.findAllAvailableUpgradesFor armor
	.then (upgradeList) ->
		expect upgradeList .to.have.length 5
		done!
	.catch done


it "should not give unoffordable combinations", (done) !->
	inventory = [
		{ id : 100, amount : 3, itemType : \item }
	]

	combinations = [
		{
			armors : [
				{ totalCost : [ { matId : 100, matCost : 2} ] }
				{ totalCost : [ { matId : 100, matCost : 2} ] }
			]
		}
		{
			armors : [
				{ totalCost : [ { matId : 100, matCost : 2} ] }
				{ totalCost : [ { matId : 100, matCost : 1} ] }
			]
		}
	]

	storageSvc.loadReturnValue = inventory
	inventorySvc.clear!.load!
	.then ->
		svc.takeOnlyAffordable combinations
	.then (canAfford) !->
		expect canAfford .to.have.length 1
		expect canAfford.0.totalCost.0 .to.have.properties {
			matId : 100
			matCost : 3
		}
		done!
	.catch done


it "should not override combinations with better ones while there are still empty slots in the 'best' array", !->
	combs = [
		{armors : [{score : 1}, {score : 2}, {score : 3}, {score : 4}]}
		{armors : [{score : 10}, {score : 20}, {score : 30}, {score : 40}]}
		{armors : [{score : 1}, {score : 2}, {score : 3}, {score : 4}]}
	]

	best = svc.calculateCombinationScores combs

	expect best .to.have.length 3
