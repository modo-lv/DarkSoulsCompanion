module?.exports = class PcModel
	@Stats = [
		\vitality
		\attunement
		\endurance
		\strength
		\dexterity
		\resistance
		\intelligence
		\faith
		\humanity
	]

	(@statSvc) ->
		@forEachStat (stat, name) -> new (require './PcStatModel') name

	forEachStat : (func) !~>
		@statSvc.forEachStat func, this

	validate : !~> @forEachStat !->
		it.base = max 8, min 99, it.base