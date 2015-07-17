angular? .module "dsc" .controller "trackerController", ($sce, $scope, trackerSvc, notificationSvc, inventorySvc) ->
	new TrackerController ...


class TrackerController
	(@$sce, @$scope, @_trackerSvc, @_notificationSvc, @_inventorySvc) ->
		@setUp!
		@wireUp!
		@loadUp!


	setUp : !~>
		@$scope.allAreas = [
			{ key : \asylum , name : "Northern Undead Asylum" }
		]
		@$scope.areaContent = []

		# What the user has selected in the auto-complete
		@$scope.selectedArea = {originalObject : @$scope.allAreas.0 }

		# The currently selected area object
		@$scope.currentArea = @$scope.allAreas.0

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


	### EVENT HANDLERS

	performActionOn : (entry) ~>
		#console.log "Preforming '#{action}' action on '#{entry.title}'."
		switch entry.action
		| \kill =>
			@$scope.globals.{}enemies.{}[entry.title].isDead = true
		| \pick-up =>
			@addItemsFrom entry.[\title]

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
			entry.meta.isAvailable = true

			if entry.parent?.meta? and entry.parent.meta.isAvailable == false
				entry.meta.isAvailable = false
				continue

			if entry.if?
				if typeof entry.if == \string then entry.if = [entry.if]

				if entry.if.@@ != Array then
					console.log entry
					throw new Error "Can't process the above entry's [.if] property"

				entry.if |> each (requirement) ~> @set entry .availabilityAccordingTo requirement

			if entry.children? then @checkAvailability entry.children


	set : (entry) ~>
		availabilityAccordingTo : (req) !~>
			parts = req.split '|'
			inverse = parts[*-1] == \not
			switch parts.0
			| \global =>
				parts = parts.1.split ':'
				name = parts.0
				value = parts.1 ? true
				entry.meta.isAvailable = (@$scope.globals.[\vars].[name] == value) != inverse

			| \enemy =>
				name = parts.1
				shouldBeDead = (parts.2 ? \alive) == \dead

				if inverse
					shouldBeDead = !shouldBeDead

				entry.meta.isAvailable = (@$scope.globals.[\enemies].[name]?.isDead ? false) == shouldBeDead
				#console.log "#{name} should-be-dead condition is #{shouldBeDead}, so setting #{entry.title} availability to #{entry.meta.isAvailable}."


	addItemsFrom : (itemText) ~>
		itemTexts = [] ++ itemText
		for text in itemTexts
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
			@_inventorySvc.addAllByName batch



module?.exports = TrackerController