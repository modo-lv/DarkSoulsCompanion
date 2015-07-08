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

	(@pcSvc) ->
		@forEachStat (stat, name) -> new (require './PcStatModel') name

	forEachStat : (func) !~>
		@pcSvc.forEachStat this, func

	validate : !~> @forEachStat !->
		it.base = max 8, min 99, it.base