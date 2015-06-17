angular.module "dsc-guide"
	.controller "GuideController", ($scope, storageService) !->
		$scope.entry =
			children : require '../content.json'

		$scope.getClassesFor = (item) !->
			classes = ["entry"]

			for a in ["content", "children"]
				classes.push (if item[a]? then "with-#a" else "without-#a")

			return classes

		$scope.getExpanderSettingsFor = (item) -> {
			expanded : item.children?
			toggleMode : if item.content? or item.children? then \click else \none
		}


