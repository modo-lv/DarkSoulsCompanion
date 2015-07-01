$sce, $scope, $routeParams, $resource <-! angular .module "dsc" .controller "GuideController"

getArrowFor = (entry) !->
	if not entry.{}meta.isExpandable then return ''

	return if entry.{}meta.isCollapsed then '(..)' else ''

prepareGuideContent = (entry) !->
	if entry.content?
		entry.content = $sce.trustAsHtml entry.content

	entry.{}meta
		..isCollapsed = entry.content?
		..isExpandable = entry.children? or entry.content?
		..arrow = getArrowFor entry

	for check in [\content \children]
		entry.{}meta.[]additionalClasses.push (if entry[check]? then "with-#{check}" else "without-#{check}")

	if entry.children?
		for child in entry.children
			prepareGuideContent child

$scope.sections = [
	{ id : \intro , name : "Intro" }
	{ id : \asylum , name : "Northern Undead Asylum" }
]

$scope.section = $routeParams.\section

data = $resource "/modules/guide/content/#{$scope.section}.json" .query !->
	$scope.entry = { children : data }
	prepareGuideContent $scope.entry


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
		..arrow = getArrowFor entry