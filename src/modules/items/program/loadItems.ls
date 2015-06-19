module?.exports = ($scope) !->
	for armor in require "../content/armors.json"
		armor = new (require "../models/armor.ls") <<< armor
		delete armor.EquipmentType
		$scope.itemData[\armors].push armor

	for key in require "../content/keys.json"
		key = new (require "../models/item.ls") <<< key
		$scope.itemData[\keys].push key
		
	for material in require "../content/materials.json"
		material = new (require "../models/item.ls") <<< material
		$scope.itemData[\materials].push material
		
	for ring in require "../content/rings.json"
		ring = new (require "../models/item.ls") <<< ring
		$scope.itemData[\rings].push ring
		
	for item in require "../content/items.json"
		item = new (require "../models/item.ls") <<< item
		$scope.itemData[\items].push item
		
