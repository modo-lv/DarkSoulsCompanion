_ <-! describe "external-data-service"

var svc, $resource

beforeEach !->
	returnValue = ['aaaa']
		..$promise = $q.defer!.promise

	$resource := sinon.stub!.returns {
		query : sinon.stub!.returns returnValue .callsArgAsync 0
	}
	svc := new (testRequire "app/services/external-data-service") $resource


it "should return promise instead of data when told", !->
	expect (svc.loadJson '/random', true)
		.to.eventually.be.resolved


it "should use cache on repeated calls with the same URL", (done) ->
	svc
		.loadJson '/dummy/address', true
		.then -> svc.loadJson '/dummy/address', true
		.then ->
			expect($resource!.query.callCount) .to.equal 1
			done!
		.catch done


it "should include $promise property in the data", !->
	expect(svc.loadJson '/test', false).to.have.property \$promise