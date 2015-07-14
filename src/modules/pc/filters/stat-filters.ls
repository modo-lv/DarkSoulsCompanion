statSvc <-! angular.module "dsc" .filter "toStatArray"

output = []

return (model) !->
	if output.length > 0 then return output

	statSvc.forEachStat ((name, value) !->
		output.push model[name]
	), model

	return output