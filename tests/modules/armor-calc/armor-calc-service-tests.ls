_ <-! describe "armor-calc-service"

var svc, edSvc, inventorySvc, itemUpSvc, itemSvc, storageSvc, itemIndexSvc, notifySvc

beforeEach (done) !->
	edSvc := new MockExternalDataService
	storageSvc := new MockStorageService
	notifySvc := new (testRequire 'app/services/notification-service') {}
	itemIndexSvc := new (testRequire 'modules/items/item-index-service') edSvc
	inventorySvc := new (testRequire 'modules/pc/inventory-service') storageSvc, itemIndexSvc, notifySvc, $q
	itemSvc := new (testRequire 'modules/items/item-service') edSvc, itemIndexSvc, inventorySvc, $q
	itemUpSvc := itemSvc.upgradeComp
	svc := new (testRequire 'modules/armor-calc/armor-calc-service') inventorySvc, itemSvc, $q

	# Setup default data
	inventory = require './test-data/armor-calc-test-inventory.json'
	armors = require './test-data/armor-calc-test-armors.json'
	materialSets = require './test-data/armor-calc-material-sets.json'
	upgrades = require './test-data/armor-calc-upgrades.json'
	index = require './test-data/armor-calc-index.json'

#	inventory = require './test-data/temp-inventory.json'
#	armors = testRequire './modules/items/content/armors.json'
#	materialSets = testRequire './modules/items/content/material-sets.json'
#	upgrades = testRequire './modules/items/content/armor-upgrades.json'
#	index = testRequire './modules/items/content/index.json'

	storageSvc.loadReturnValue = inventory


	edSvc.loadJsonReturnValue = materialSets
	itemUpSvc.loadAllMaterialSets!
	.then ->
		edSvc.loadJsonReturnValue = upgrades
		itemUpSvc.loadAllUpgrades \armor
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

	svc.calculateCombinationScores combinations

	expect combinations.0.score .to.equal 40
	expect combinations.1.score .to.equal 100


it "should correctly find all available upgrades for a piece of armor", (done) !->
	itemSvc.findItem \armor, (.id == 11000)
	.then (armor) ->
		itemSvc.upgradeComp.findAllAvailableUpgradesFor armor
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


#it "an already applied upgrade and a potential one should have the same score", (done) !->
#	armor = {
#		id : 1000
#		itemType : \armor
#		armorType : \chest
#		upgradeId : 0
#		matSetId : 0
#		defPhy : 50
#		weight : 1
#	}
#
#	armor2 = {
#		id : 1200
#		itemType : \armor
#		armorType : \chest
#		upgradeId : 100
#		matSetId : 0
#		defPhy : 100
#		weight : 1
#	}
#
#	upgraded = {} <<< armor <<< {
#		id : 1201
#		score : 100
#		defPhy : 100
#		upgradeId : 101
#		matSetId : 0
#	}
#
#	upgrades = [
#		{id : 1, matSetId : 1, defModPhy : 2}
#		{id : 101, matSetId : 1, defModPhy : 1}
#	]
#	inventory = [
#		{ id : 1000 , uid : \armor1000 , amount : 1 , itemType : \armor }
#		{ id : 1201 , uid : \armor1201 , amount : 1 , itemType : \armor }
#	]
#	materialSets = [{id : 1, matId : -1, matCost : -1}]
#	index = inventory ++ [armor] ++ [
#		{ id : 1000 , uid : \armor1000 , name : "Armor" , itemType : \armor }
#		{ id : 1001 , uid : \armor1001 , name : "Armor +1" , itemType : \armor }
#		{ id : 1200 , uid : \armor1200 , name : "Other armor" , itemType : \armor }
#		{ id : 1201 , uid : \armor1201 , name : "Other armor +1" , itemType : \armor }
#	]
#
#	edSvc.loadJsonReturnValue = [armor, armor2]
#	itemSvc.clear \armor .loadAllItems \armor
#	.then ->
#		edSvc.loadJsonReturnValue = upgrades
#		itemUpSvc.clearUpgrades!.loadAllUpgrades \armor
#	.then ->
#		edSvc.loadJsonReturnValue = materialSets
#		itemUpSvc.clearMaterialSets!.loadAllMaterialSets!
#	.then ->
#		edSvc.loadJsonReturnValue = index
#		itemIndexSvc.clear!.loadAllEntries!
#	.then ->
#		storageSvc.loadReturnValue = inventory
#		inventorySvc.clear!.load!
#	.then (inventory) ->
#		svc.freeWeight = 10
#		svc.params = {
#			includeUpgrades : true
#			modifiers : {
#				\phy : 1
#			}
#		}
#		svc._debugLog = true
#		svc.findBestCombinations!
#	.then (combs) !->
#		console.log combs
#		expect combs .to.have.length 4
#		done!
#	.catch done