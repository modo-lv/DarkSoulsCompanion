global
	.. <<< require \chai
	..use require \chai-as-promised
	..use require \chai-properties
	.. <<< require \prelude-ls
	..sinon = require \sinon
	..$q = require \q

	..testRequire = (path) -> require "../src/#{path}"


global.createServiceStack = !->
	global
		..edSvc := new MockExternalDataService
		..storageSvc := new MockStorageService
		..notifySvc := new (testRequire 'app/services/notification-service') {}
		..itemIndexSvc := new (testRequire "modules/items/item-index-service") edSvc
		..inventorySvc := new (testRequire "modules/pc/inventory-service") storageSvc, itemIndexSvc, notifySvc, $q
		..itemSvc := new (testRequire "modules/items/item-service") edSvc, itemIndexSvc, inventorySvc, $q
		..statSvc := new (testRequire "modules/pc/stat-service") storageSvc


class global.MockExternalDataService
	->
		@loadJsonReturnValue = []


	loadJson : (url, usePromise = true) !~>
		def = $q.defer!
		@loadJsonReturnValue.$promise = def.promise
		def.resolve @loadJsonReturnValue
		return if usePromise then def.promise else @loadJsonReturnValue


class global.MockStorageService
	->
		@loadReturnValue = []

	load : !-> return @loadReturnValue

	save : !->