angular.module "dsc-guide"
	.controller "GuideController", ($sce, $scope, storageService) !->
		$scope.entry =
			children : require './content.json'

		# Create ID-entry index
		$scope.entryIndex = {}

		do addToIndex = (entry = $scope.entry) !->
			if entry.id?
				$scope.entryIndex[entry.id] = entry
			if entry.children? then for child in entry.children
				addToIndex child

		(require './program/doneEntries') $scope, storageService

		for id in $scope.userData.doneEntryIds
			$scope.entryIndex[id].done = true
		$scope.processDoneEntryParents!


		trustGuideContent = (entry) !->
			if entry.content?
				entry.content = $sce.trustAsHtml entry.content

			if entry.children?
				for child in entry.children
					trustGuideContent child

		trustGuideContent $scope.entry

		$scope.getClassesFor = (item) !->
			classes = ["entry"]

			for a in ["content", "children"]
				classes.push (if item[a]? then "with-#a" else "without-#a")

			return classes

		$scope.depth = 0


		$scope.getExpanderSettingsFor = (item) -> item.settings ?= {
			expanded : item.children?
			toggleMode : if item.content? or item.children? then \click else \none
		}




