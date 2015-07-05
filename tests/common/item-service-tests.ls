_ <-! describe "item-service"

var svc, edSvc

beforeEach !->
	edSvc := new MockExternalDataService
	svc := new (testRequire "modules/items/services/item-service") edSvc


it "should find an item by id", (done) !->
	sample =
		\id : 10013
		\name : "Sample item"

	edSvc.loadJsonReturnValue = [ sample ]

	expect(svc.findItem \item, (.id == 10013))
		.to.eventually.equal sample
		.notify done