angular? .module "dsc" .service "trackerSvc", (externalDataSvc) ->
	new TrackerService ...


class TrackerService
	(@_externalDataSvc) ->


	loadAreaContent : (area) ~>
		@_externalDataSvc.loadJson "/modules/tracker/content/areas/#{area}.json"
		.then ~> @process it


	process : (entry, parent) ~>
		if entry.@@ == Array
			output = entry |> map ~> @process it
		else
			output = {} <<< entry

			if typeof output.[]labels == 'string'
				output.labels = [output.labels]

			if output.[\items]?
				text = "<strong>Items:</strong> #{([] ++ output.[\items]) |> join ', '}<br />"
				output.content = text + (output.content ? "")

			if output.children?
				output.children = output.children |> map ~> @process it, output

			output.parent = parent

		return output


module?.exports = TrackerService