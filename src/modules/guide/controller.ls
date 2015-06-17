angular.module "dsc-guide"
	.controller "GuideController", ($sce, $scope, storageService) !->
		$scope.entry =
			children : require './content.json'

		$scope.userData = {
			doneEntryIds : []
		}

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


		$scope.getExpanderSettingsFor = (item) -> item.settings ?= {
			expanded : item.children?
			toggleMode : if item.content? or item.children? then \click else \none
		}


		$scope.entryDone = ($event, entry) !->
			$event.stopPropagation!
			entry.done = true
			unless $scope.userData.doneEntryIds |> any (== entry.id)
				$scope.userData.doneEntryIds.push entry.id