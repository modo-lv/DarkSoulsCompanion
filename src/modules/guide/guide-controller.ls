angular?.module "dsc" .controller "GuideController" ($sce, $scope, $routeParams, $resource, guideSvc, storageSvc) ->
	new GuideController ...
	
class GuideController
	(@$sce, @$scope, @$routeParams, @$resource, @_guideSvc, @_storageSvc) ->
	
		@setup!
		@load!
		@wireUp!
		
	
	setup : !~>

		@$scope.sections = [
			{ id : \intro , name : "Intro" }
			{ id : \asylum , name : "Northern Undead Asylum" }
			{ id : \firelink , name : "Firelink Shrine" }
			{ id : \burg , name : "Undead Burg" }
			{ id : \parish , name : "Undead Parish" }
			{ id : \low , name : "Lower Undead Burg" }
			{ id : \depths , name : "The Depths" }
			{ id : \blight , name : "Blighttown" }
			{ id : \quelaag , name : "Quelaag's Domain" }
		]

		@$scope.section = @$routeParams.\section

		@$scope.userData = null

		@$scope.entryIndex = {}


	load : !~>
		@loadUserData!
		data = @_guideSvc.getContentFor @$scope.section
		@$scope.entry = { children : data }
		data.$promise.then !~>
			@prepareGuideContent @$scope.entry
			@processReqs!


	wireUp : !~>
		for func in [\canAddToInventory \markDone \entryClicked \enact]
			@$scope.[func] = @.[func]


	### Event handlers

	canAddToInventory : (entry) !~>
		can = (entry.[]labels |> any (== 'item'))

		return can


	entryClicked : ($event, entry) !~>
		$event.stopPropagation!
		if not entry.{}meta.isExpandable
			return
		entry.{}meta
			..isCollapsed = not entry.{}meta.isCollapsed
			..arrow = @getArrowFor entry

		@saveUserData!


	entryDone : (entry) !->
		entry.meta.isDone = true
		@saveUserData!


	enact : (entry) !~>
		for type in [\setFlags \clearFlags]
			if not entry.[type]? then continue

			if entry.[type].@@ != Array
				entry.[type] = [entry.[type]]

			for flag in entry.[type]
				@$scope.userData.{}flags.[flag] = (type == \setFlags)

		@processReqs!


	### Utility methods

	getArrowFor : (entry) !~>
		if not entry.{}meta.isExpandable then return ''
	
		return if entry.{}meta.isCollapsed then '[..]' else ''


	prepareGuideContent : (entry) !~>
		if entry.id?
			@$scope.entryIndex[entry.id] = entry
		if entry.content?
			entry.content = @$sce.trustAsHtml entry.content
	
		userMeta = @$scope.{}userData.{}entryMeta[entry.id] ? {}

		if typeof entry.[]labels == 'string'
			entry.labels = [entry.labels]

		entry.{}meta
			..isCollapsed = userMeta.isCollapsed ? entry.content?
			..isDone = userMeta.isDone ? false
			..isExpandable = entry.children? or entry.content?
			..arrow = @getArrowFor entry
			..setsFlags = entry.setFlags? or entry.clearFlags?
			..isItem = \item in entry.labels

		for check in [\content \children]
			entry.{}meta.[]additionalClasses.push (if entry[check]? then "with-#{check}" else "without-#{check}")


		if entry.children?
			for child in entry.children
				@prepareGuideContent child


	saveUserData : !~>
		for id, entry of @$scope.entryIndex
			for field in [\isCollapsed \isDone]
				@$scope.{}userData.{}entryMeta.{}[id].[field] = entry.meta[field]

		@_storageSvc.save 'guide:userData', @$scope.userData


	loadUserData : !~>
		@$scope.userData = (@_storageSvc.load 'guide:userData') ? {}


	/**
	 *
	 */
	processReqs : !~>
		for id, entry of @$scope.entryIndex
			entry.meta.isEnabled = true
			for key in [\req \reqNot]
				if not entry[key]? then continue

				if entry.[key].@@ != Array then entry.[key] = [entry.[key]]

				for req in entry.[key]
					if typeof req == \string
						entry.meta.isEnabled = (key == \req) == (@$scope.userData.{}flags[req] == true)

					if not entry.meta.isEnabled
						break

				if not entry.meta.isEnabled
					break


module?.exports = GuideController