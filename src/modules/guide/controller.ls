module?.exports = ($scope, storageService) !->
	$scope.entry =
		children : require './content.json'

	$scope.getClassesFor = (item) !->
		classes = ["entry"]
		if not item.content?
			classes.push "with-content"
		if item.children?
			classes.push "with-children"