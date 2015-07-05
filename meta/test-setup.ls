global
	.. <<< require \chai
	..use require \chai-as-promised
	.. <<< require \prelude-ls
	..sinon = require \sinon
	..$q = require \q

	..testRequire = (path) -> require "../src/#{path}"



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