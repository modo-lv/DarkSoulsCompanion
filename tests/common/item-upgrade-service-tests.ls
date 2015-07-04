_ <-! describe "item-upgrade-service"

var svc, edSvc

beforeEach !->
	edSvc := new MockExternalDataService
	svc := new (testRequire "/common/services/item-upgrade-service") edSvc


it "should correctly calculate the base item ID from an upgraded one", !->
	baseId = svc.getBaseItemIdFrom 103012
	expect baseId .to.equal 103000