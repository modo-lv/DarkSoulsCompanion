$sce, $scope, $routeParams, $resource, guideService, storageService <-! angular .module "dsc" .controller "GuideController"

### Setup

$scope.sections = [
	{ id : \intro , name : "Intro" }
	{ id : \asylum , name : "Northern Undead Asylum" }
	{ id : \firelink , name : "Firelink Shrine" }
	{ id : \burg , name : "Undead Burg" }
	{ id : \parish , name : "Undead Parish" }
	{ id : \low , name : "Lower Undead Burg" }
	{ id : \depths , name : "The Depths" }
	{ id : \blight , name : "Blighttown" }
]

$scope.section = $routeParams.\section

$scope.userData = null

$scope.entryIndex = {}


### Utility methods

_getArrowFor = (entry) !->
	if not entry.{}meta.isExpandable then return ''

	return if entry.{}meta.isCollapsed then '[..]' else ''


_prepareGuideContent = (entry) !->
	if entry.id?
		$scope.entryIndex[entry.id] = entry
	if entry.content?
		entry.content = $sce.trustAsHtml entry.content

	userMeta = $scope.{}userData.{}entryMeta[entry.id] ? {}

	entry.{}meta
		..isCollapsed = userMeta.isCollapsed ? entry.content?
		..isDone = userMeta.isDone ? false
		..isExpandable = entry.children? or entry.content?
		..arrow = _getArrowFor entry

	for check in [\content \children]
		entry.{}meta.[]additionalClasses.push (if entry[check]? then "with-#{check}" else "without-#{check}")

	if entry.children?
		for child in entry.children
			_prepareGuideContent child


_saveUserData = !->
	for id, entry of $scope.entryIndex
		for field in [\isCollapsed \isDone]
			$scope.{}userData.{}entryMeta.{}[id].[field] = entry.meta[field]

	storageService.save 'guide:userData', $scope.userData

_loadUserData = !->
	$scope.userData = (storageService.load 'guide:userData') ? {}



### Load content

_loadUserData!

data = guideService.getContentFor $scope.section
$scope.entry = { children : data }
data.$promise.then !-> _prepareGuideContent $scope.entry



### Event handlers

$scope.canAddToInventory = (entry) !->
	can = (entry.[]labels |> any (== 'item'))

	can = can and not (entry.[]flags |> any (== 'abstract'))

	return can


$scope.entryClicked = ($event, entry) !->
	$event.stopPropagation!
	if not entry.{}meta.isExpandable
		return
	entry.{}meta
		..isCollapsed = not entry.{}meta.isCollapsed
		..arrow = _getArrowFor entry

	_saveUserData!


$scope.entryDone = (entry) !->
	entry.meta.isDone = true
	_saveUserData!
