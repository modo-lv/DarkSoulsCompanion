angular? .module "dsc" .controller "trackerController", ($location, $routeParams, $sce, $scope, trackerSvc, notificationSvc, inventorySvc, $q) ->
	new TrackerController ...


class TrackerController
	(@$location, @$routeParams, @$sce, @$scope, @_trackerSvc, @_notificationSvc, @_inventorySvc, @$q) ->
		@setUp!
		@wireUp!
		@loadUp!


	setUp : !~>
		@$scope.allAreas = [
			{ key : \asylum , name : "Northern Undead Asylum" }
			{ key : \blighttown , name : "Blighttown" }
			{ key : \darkroot-garden , name : "Darkroot Garden" }
			{ key : \sen , name : "Sen's Fortress" }
		]

		@$scope.currentArea = @$scope.allAreas |> Obj.find ~> it.key == @$routeParams.[\area]

		if not @$scope.currentArea?
			@$location.path "/tracker"

		@$scope.areaContent = []

		# What the user has selected in the auto-complete
		@$scope.selectedArea = null

		# GUID-keyed index of entries for easy access
		@$scope.entryIndex = {}

		@$scope.globals = {
			"enemies" : {}
			"npcs" : []
			"vars" : {
				"asylum-done" : false
				"pc-class" : null
			}
		}


	loadUp : !~>
		@_trackerSvc.loadAreaContent @$scope.currentArea.key
		.then (content) ~>
			content |> each ~> @process it

			@checkAvailability content

			@$scope.areaContent = content

			# Fake entry for display template
			@$scope.entry = { children : content }


	wireUp : !~>
		for func in [
			\performActionOn
			\expandOrCollapse
		]
			@$scope.[func] = @.[func]

		@$scope.$watch "selectedArea", (value) !~>
			if not value?.originalObject? then return
			@$location.path "/tracker/#{value.originalObject.key}"



	### EVENT HANDLERS

	performActionOn : (entry) ~>
		#console.log "Preforming '#{action}' action on '#{entry.title}'."
		def = @$q.defer!
		switch entry.action
		| \kill =>
			@$scope.globals.{}enemies.{}[entry.title].isDead = true
			def.resolve!
		| \pick-up =>
			def.promise = @addItemsFrom entry.[\title]
		| otherwise => def.resolve!

		def.promise
		.then ~>
			if entry.[\setVar]?
				parts = entry.[\setVar].split '|'
				switch parts.0
				| \global =>
					parts = parts.1.split ':'
					name = parts.0
					value = parts.1 ? true

					@$scope.globals.[\vars].[name] = value

			if entry.[\items]?
				@addItemsFrom entry.[\items]
		.then !~>
			entry.meta.isHidden = true

			@checkAvailability!


	expandOrCollapse : ($event, entry) ~>
		$event.stopPropagation!

		entry.meta.isCollapsed = !entry.meta.isCollapsed


	### UTILITIES

	process : (entry) !~>
		entry.{}meta
			..isCollapsed = ..{}userData.isCollapsed ? (\spoiler in entry.labels)
			..isHidden = ..{}userData.isHidden ? false
			..isExpandable = entry.children? or entry.content?
			..additionalClasses = []
				..push "#{if entry.children? then "with" else "without"}-children"
				..push "#{if entry.content? then "with" else "without"}-content"


		# Actions
		if \enemy in entry.labels
			entry.action ?= \kill
		if \item in entry.labels
			entry.action ?= \pick-up

		if entry.children?
			entry.children |> each ~> @process it

		entry.content = @$sce.trustAsHtml entry.content

		# Add to index
		@$scope.{}entryIndex[entry.id] = entry


	checkAvailability : (entries = @$scope.areaContent) !~>
		for entry in entries
			let entry = entry
				entry.meta.additionalClasses = entry.meta.additionalClasses |> reject (== \unavailable)

				def = @$q.defer!

				if entry.parent?.meta? and entry.parent.meta.isAvailable == false
					def.resolve false
				else if entry.if?
					if typeof entry.if == \string then entry.if = [entry.if]

					if entry.if.@@ != Array then
						console.log entry
						throw new Error "Can't process the above entry's [.if] property"

					def.promise = @$q.all(entry.if |> map (requirement) ~> @set entry .availabilityAccordingTo requirement)
				else
					def.resolve true

				def.promise
				.then (isAvailable) ~>
					isAvailable = ([] ++ isAvailable) |> all (== true)
					#console.log "#{entry.title} is available: #{isAvailable}"
					if not isAvailable
						entry.meta.additionalClasses.push \unavailable

					entry.meta.isAvailable = isAvailable

					if entry.children? then @checkAvailability entry.children


	set : (entry) ~>
		availabilityAccordingTo : (req) ~>
			def = @$q.defer!

			parts = req.split '|'
			inverse = parts[*-1] == \not
			switch parts.0
			| \global =>
				parts = parts.1.split ':'
				name = parts.0
				value = parts.1 ? true
				def.resolve((@$scope.globals.[\vars].[name] == value) != inverse)

			| \item =>
				def.promise = @_inventorySvc.hasItemWithName parts.1

			| \enemy =>
				name = parts.1
				shouldBeDead = (parts.2 ? \alive) == \dead

				if inverse
					shouldBeDead = !shouldBeDead

				def.resolve((@$scope.globals.[\enemies].[name]?.isDead ? false) == shouldBeDead)
				#console.log "#{name} should-be-dead condition is #{shouldBeDead}, so setting #{entry.title} availability to #{entry.meta.isAvailable}."
			| otherwise => throw new Error "Unrecognized condition: '#{req}'"

			def.promise
			.then (isAvailable) ~>
				if isAvailable != entry.meta.isAvailable
					#console.log entry, "#{isAvailable} != #{entry.meta.isAvailable} changed available status, collapsed will be: #{!isAvailable}"
					entry.meta.isCollapsed = !isAvailable
				#console.log "Setting #{entry.title} availability to #{isAvailable}"
				return isAvailable


	addItemsFrom : (text) ~>
		promises = []
		potentials = (text.split ',') |> map (.trim!)
		batch = []
		for potential in potentials
			result = /([^()]+)(?:\s+\((\d+)\)|$)/ .exec potential
			#console.log result
			batch.push {
				name : result.1
				amount : result.2 ? 1
			}
		#console.log batch
		promises.push @_inventorySvc.addAllByName batch
		return @$q.all promises




module?.exports = TrackerController