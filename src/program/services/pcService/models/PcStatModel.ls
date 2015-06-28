module?.exports = class PcStatModel
	(@name, @base = 0) ->
		@bonus = 0

	total :~ -> @base + @bonus

	displayName :~ -> capitalize @name