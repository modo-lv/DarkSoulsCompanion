# Filter to create a proper-order array from a stats object

angular.module "dsc"

.filter "toStatArray" (statSvc) ->
	output = []
	(model) !->
		if output.length > 0 then return output

		statSvc.forEachStat ((name, value) !->
			output.push {"name" : name, "value" : value}
		), model

		return output


.filter "fullStatName" (statSvc) ->
	output = {}
	(shortName) !->
		if output.[shortName]? then return output.[shortName]

		return output.[shortName] = statSvc.fullStatNameOf shortName