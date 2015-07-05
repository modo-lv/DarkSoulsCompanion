angular.module "dsc"
	.service 'dataExportService', ->
		{
			exportJson : (data) !->
				window.open encodeURI "data:application/json,#{JSON.stringify data }"

			exportCsv : (data) !->
				firstLine = data |> first |> keys |> join ','

				rows = []
				for item in data
					row = []
					for key, value of item
						if typeof value == "string" then
							value = value
								.replace '"', '""'
								.replace /(\r\n|\n|\r)/g, '\\n'
							value = "\"#value\""

						row.push value

					row = row |> join ','
					rows.push row

				output = "#{firstLine }\n#{rows |> join "\n" }"

				window.open encodeURI "data:text/plain,#{output }"


		}