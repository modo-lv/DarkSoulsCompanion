angular? .module "dsc" .service "externalDataSvc" ($resource, $q) ->
	new ExternalDataService $resource, $q

class ExternalDataService

	(@$resource, @$q) ->
		@_cache = {}


	/**
	 * Load an external JSON resource and parse it into an array
	 */
	loadJson : (url, returnPromise = true) !~>
		# Validate URL
		if not url? or typeof url != "string" or url.length < 1
			throw new Error "Invalid URL: [#{url}]"

		# Setup return value
		task = @$q.defer!

		# Get the data
		if @_cache.[][url] |> empty
			@_cache.[url] = @$resource url .query !~>
				task.resolve @_cache.[url]
		else
			task.resolve @_cache.[url]

		# Return data or promise as per argument
		return if returnPromise then task.promise else @_cache.[url]


module?.exports = ExternalDataService