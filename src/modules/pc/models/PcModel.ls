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

	(@pcService) ->
		@forEachStat (stat, name) -> new (require './PcStatModel') name

	forEachStat : (func) !~>
		@pcService.forEachStat this, func

	validate : !~> @forEachStat !->
		it.base = max 8, min 99, it.base