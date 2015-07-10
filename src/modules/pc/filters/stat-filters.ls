statSvc <-! angular.module "dsc" .filter "toStatArray"

output = []

return (model) !->
	if output.length > 0 then return output

	statSvc.forEachStat ((stat, name) !->
		output.push model[name]
	), model

	return output