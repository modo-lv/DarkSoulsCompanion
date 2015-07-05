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