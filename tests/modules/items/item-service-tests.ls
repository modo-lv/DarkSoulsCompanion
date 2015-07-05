_ <-! describe "item-service"

var svc, edSvc

beforeEach !->
	edSvc := new MockExternalDataService
	svc := new (testRequire "modules/items/item-service") edSvc


it "should find an item by id", (done) !->
	sample =
		\id : 10013
		\name : "Sample item"
		\itemType : \item

	edSvc.loadJsonReturnValue = [ sample ]

	result = svc.findItem \item, (.id == 10013)

	expect(result).to.eventually.be.instanceof svc._models.Item
	expect(result).to.eventually.have.property \id, sample.id
	expect(result).to.eventually.have.property \name, sample.name
	expect(result).to.eventually.have.property \itemType, sample.itemType
	expect(result).notify done