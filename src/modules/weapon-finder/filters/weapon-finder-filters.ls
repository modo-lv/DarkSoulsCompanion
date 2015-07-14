statSvc <- angular.module "dsc" .filter "statName"

(name) ->
	if (name.indexOf 'req') == 0
		name = name.substr 3

	return name