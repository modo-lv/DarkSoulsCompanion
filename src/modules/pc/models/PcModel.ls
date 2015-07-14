module?.exports = class PcModel
	(@statSvc) ->
		@forEachStat (stat, name) -> new (require './PcStatModel') name

	forEachStat : (func) !~>
		@statSvc.forEachStat func, this

	validate : !~> @forEachStat !->
		it.base = max 8, min 99, it.base