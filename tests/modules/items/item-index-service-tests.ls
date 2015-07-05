_ <-! describe "item-index-service"

var svc, storageSvc, itemIndexSvc, edSvc

beforeEach !->
	edSvc := new MockExternalDataService
	storageSvc := new MockStorageService
	svc := new (testRequire "modules/items/item-index-service") edSvc


it "should find items by UID", (done) !->
	sample = {
		\uid : "armor100"
		\name : "Armor One"
	}
	edSvc.loadJsonReturnValue = [ sample ]

	expect svc.findEntry ( .uid == \armor100 )
		.to.eventually.have.property \name, "Armor One"
		.notify done


it "should return all items when asked", (done) !->
	sample = [
		{ \uid : "weapon100" }
		{ \uid : "item200" }
	]

	edSvc.loadJsonReturnValue = sample

	expect svc.getAllEntries!
		.to.eventually.have.length 2
		.notify done


it "should load all armor sets", (done) !->
	armorSets = [ { \name : \Test1 }, { \name : \Test2 } ]

	edSvc.loadJsonReturnValue = armorSets

	expect(svc.loadAllArmorSetEntries!)
		.to.eventually.have.length 2
		.notify done



it "should find and return armors in a set", (done) !->
	armorSets = [ { \name : "Test", \armors : [ 100, 101 ] } ]
	armors = [ { \id : 100 }, { \id : 101 } ]

	edSvc.loadJsonReturnValue = armorSets
	svc.loadAllArmorSetEntries!
	.then ->
		edSvc.loadJsonReturnValue = armors
		expect(svc.findByArmorSet armorSets.0)
			.to.eventually.have.length 2
			.notify done
	.catch done