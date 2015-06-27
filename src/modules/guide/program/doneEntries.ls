module?.exports = ($scope, storageService) !->

	$scope.processDoneEntryParents = (entry = $scope.entry) !->
		if entry.children?
			for child in entry.children
				$scope.processDoneEntryParents child
			if entry.children |> all (.done)
				entry.done = true

	$scope.{}userData.doneEntryIds = (storageService.load 'guide:done') ? []

	$scope.entryDone = ($event, entry) !->
		$event.stopPropagation!
		entry.done = true
		unless $scope.userData.doneEntryIds |> any (== entry.id)
			$scope.userData.doneEntryIds.push entry.id
		storageService.save 'guide:done', $scope.userData.doneEntryIds
		$scope.processDoneEntryParents!