require! [ \fs \csv-parse ]
global <<< require \prelude-ls

raw = {}
	..names = {}
	..effects = {}
	..materialSets = {}
	..upgrades = {}
	..behavior = {}
	..weapons = []
	..items = {}

usedNames = {}


$index = []
$armorSetIndex = []


$addToSetIndex = (armor) !->
	if armor.armorSet == '' or not armor.armorSet? then return

	entry = $armorSetIndex |> find (.name == armor.armorSet)
	if not entry?
		entry ?= {name : armor.armorSet}
		$armorSetIndex.push entry

	entry.[]armors.push armor.id


$addToIndex = (item) !->
	uid = item.itemType + item.id
	entry = ($index |> find (.uid == uid)) ? {}
	for field in [\id \name \itemType]
		entry[field] = item[field]
	entry.\uid = uid

	$index.push entry


pathMap =
	0 : null # Normal
	5 : \Crystal
	10 : \Lightning
	15 : \Raw
	20 : \Magic
	22 : \Enchanted
	25 : \Divine
	30 : \Occult
	35 : \Fire
	40 : \Chaos
	45 : null  # Unique (demon, dragon, boss, etc.)


effectMap =
	\bleed : 6
	\poison : 2
	\toxic : 5
	\heal : 199


parseTexts = (data, type) !->
	target = {}
	for row in data
		uid = "#{type}#{row.\Id}"
		name = row.\Value
		if (uid.indexOf \weapon1332) == 0
			name = name.replace "Pyromancy Flame", "Pyromancy Flame (ascended)"
		else
			name = switch uid
				# Crystal Greatswords
				| \weapon304000 => name + " (store-bought)"
				| \weapon351100 => name + " (ascended)"
				# Traveling Gloves
				| \armor382000 => name + " (Big Hat's)"
				| \armor312000 => name + " (cleric's)"
				| otherwise => name

		target[type + row.\Id] = name
	return target


console.log "Loading names..."
itemTypes = [ \item \armor \weapon \ring ]

a = 0
total = itemTypes.length * 2
for type in itemTypes
	for file in ["#{type}_names", "#{type}_names_dlc"]
		content = fs.readFileSync "#{file }.csv", { \encoding : \utf8 }
		((type) !->
			csvParse content, { \columns : true } (err, data) !->
				if err? then throw err
				raw.{}names <<< parseTexts data, type
				if ++a == total
					loadWeaponTypeNames!
		) type

loadWeaponTypeNames = !->
	a = 0
	total = 2
	for file in [\weapon-types, \weapon-types-dlc]
		content = fs.readFileSync "#{file }.csv", { \encoding : \utf8 }
		((type) !->
			csvParse content, { \columns : true } (err, data) !->
				if err? then throw err
				for row in data
					raw.{}weaponTypes[row.\Id] = row.\Value
				if ++a == total
					loadUpgrades!
		) type



loadUpgrades = !->
	console.log "Loading reinforcement data..."
	content = fs.readFileSync \weapon-upgrades.csv , { \encoding : \utf8 }
	csvParse content, { \columns : true }, (err, data) !->
		if err? then throw err
		for row in data
			raw.{}upgrades[row.\Id] = row
		loadArmorUpgrades!

loadArmorUpgrades = !->
	console.log "Loading armor upgrade data..."
	content = fs.readFileSync \armor_upgrades.csv , { \encoding : \utf8 }
	csvParse content, { \columns : true }, (err, data) !->
		if err? then throw err
		for row in data
			raw.{}armorUpgrades[row.\Id] = row
		loadWeapons!

loadWeapons = !->
	console.log "Loading weapon data..."
	content = fs.readFileSync \weapons.csv , { \encoding : \utf8 }
	csvParse content, { \columns : true }, (err, data) !->
		if err? then throw err
		for row in data
			raw.[]weapons.push row
		loadArmors!


loadArmors = !->
	console.log "Loading armor data..."
	content = fs.readFileSync \armors.csv , { \encoding : \utf8 }
	csvParse content, { \columns : true }, (err, data) !->
		if err? then throw err
		for row in data
			raw.[]armors.push row
		loadEffects!


loadEffects = !->
	console.log "Loading effect data..."
	content = fs.readFileSync \effects.csv , { \encoding : \utf8 }
	csvParse content, { \columns : true }, (err, data) !->
		if err? then throw err
		for row in data
			raw.{}effects[row.\Id] = row
		loadItems!


loadItems = !->
	console.log "Loading item data..."
	content = fs.readFileSync \items.csv , { \encoding : \utf8 }
	csvParse content, { \columns : true }, (err, data) !->
		if err? then throw err
		for row in data
			raw.{}items[row.\Id] = row

		loadMaterialSets!


loadMaterialSets = !->
	console.log "Loading material set data..."
	content = fs.readFileSync \materialSets.csv , { \encoding : \utf8 }
	csvParse content, { \columns : true }, (err, data) !->
		if err? then throw err
		for row in data
			raw.{}materialSets[row.\Id] = row
		loadBehavior!


loadBehavior = !->
	console.log "Loading behavior data..."
	content = fs.readFileSync \pc-behavior.csv , { \encoding : \utf8 }
	csvParse content, { \columns : true }, (err, data) !->
		if err? then throw err
		for row in data
			raw.{}behavior["#{row.\VariationId }#{row.\BehaviorJudgeId}"] = row
		rawDataLoaded!


setName = (item) !->
	uid = item.itemType + item.id
	item.name = raw.names[uid]
	if not item.name?
		return
	if usedNames[item.name]?
		console.info "Item name already used, skipping item: #{item.name}."
		item.name = ''
	else
		usedNames[item.name] = true


processUpgrades = (folder = '.') !->
	console.log "Processing weapon upgrades..."

	upgrades = []

	for key, rawUp of raw.upgrades
		#console.log rawUp
		#console.log rawUp.\MaterialSetId
		#console.log raw.materialSets[+rawUp.\MaterialSetId]

		upgrade = { id : +rawUp.\Id }
			..atkMod = [
				+rawUp.\PhysicsAtkRate
				+rawUp.\MagicAtkRate
				+rawUp.\FireAtkRate
				+rawUp.\ThunderAtkRate
			]

			..bonusMod = [
				+rawUp.\CorrectStrengthRate
				+rawUp.\CorrectAgilityRate
				+rawUp.\CorrectMagicRate
				+rawUp.\CorrectFaithRate
			]

			..defMod = [
				+rawUp.\PhysicsGuardCutRate
				+rawUp.\MagicGuardCutRate
				+rawUp.\FireGuardCutRate
				+rawUp.\ThunderGuardCutRate

				+rawUp.\PoisonGuardResistRate
				+rawUp.\BloodGuardResistRate
				+rawUp.\CurseGuardResistRate

				+rawUp.\StaminaGuardDefRate
			]

			..matSetId = +rawUp.\MaterialSetId

		upgrades.push upgrade

	fs.writeFileSync "#{folder}/weapon-upgrades.json", JSON.stringify upgrades


processMaterialSets = (folder = '.') !->
	console.log "Processing material sets..."

	matSets = []

	for key, data of raw.materialSets
		matSet = { id : +data.\Id }
			..matId = +data.\MaterialId01
			..matCost = +data.\ItemNum01

		matSets.push matSet

	fs.writeFileSync "#{folder}/material-sets.json", JSON.stringify matSets


processItems = (folder = '.') !->
	console.log "Processing items..."

	items = []

	for key, rawItem of raw.items
		item = { id : +rawItem.\Id }
			..itemType = \item
			.. |> setName
			..sell = +rawItem.\SellValue

		if not item.name? or item.name.length < 1
			#console.log "[#{item.name}]"
			continue

		items.push item

		item |> $addToIndex

	fs.writeFileSync "#{folder}/items.json", JSON.stringify items

	console.log "Items done."



processWeapons = (folder = '.')!->
	console.log "Processing weapons..."
	weapons = []
	for rawWeapon in raw.weapons
		# Skip ammo
		if [\Arrow \Bolt] |> any (== rawWeapon.\WeaponCategory)
			continue

		weapon = {}
			..id = +rawWeapon.\Id
			..itemType = \weapon
			.. |> setName
			..sellValue = +rawWeapon.\SellValue
			..durability = +rawWeapon.\DurabilityMax
			..weight = +rawWeapon.\Weight
			..iconId = +rawWeapon.\IconId

			..def = [
				+rawWeapon.\PhysGuardCutRate
				+rawWeapon.\MagGuardCutRate
				+rawWeapon.\FireGuardCutRate
				+rawWeapon.\ThunGuardCutRate

				+rawWeapon.\PoisonGuardResist
				+rawWeapon.\BloodGuardResist
				+rawWeapon.\CurseGuardResist

				# Stability
				+rawWeapon.\StaminaGuardDef
			]

			..matSetId = +rawWeapon.\MaterialSetId
			..upgradeCost = +rawWeapon.\BasicPrice
			..upgradeId = +rawWeapon.\ReinforceTypeId


		# Weapons without names cannot be recognized and so are useless
		if not weapon.name? then continue

		weapon
			..weaponType = rawWeapon.\WeaponCategory
			..weaponSubtype = raw.weaponTypes[..id]
			..path = pathMap[+rawWeapon.\BaseChangeCategory]

			..canBlock = rawWeapon.\EnableGuard .toLowerCase! == \true
			..canParry = rawWeapon.\EnableParry .toLowerCase! == \true
			..casts = if rawWeapon.\EnableMagic .toLowerCase! == \true then \sorcery
				else if rawWeapon.\EnableSorcery .toLowerCase! == \true then \pyromancy
				else if rawWeapon.\EnableMiracle .toLowerCase! == \true then \miracles
				else null
			..damagesGhosts = rawWeapon.\IsVersusGhostWep .toLowerCase! == \true
			..isAugmentable = rawWeapon.\IsEnhance .toLowerCase! == \true

			..dmgTypes = [
				rawWeapon.\IsNormalAttackType .toLowerCase! == \true
				rawWeapon.\IsBlowAttackType .toLowerCase! == \true
				rawWeapon.\IsSlashAttackType .toLowerCase! == \true
				rawWeapon.\IsThrustAttackType .toLowerCase! == \true
			]


			..req = [
				+rawWeapon.\ProperStrength
				+rawWeapon.\ProperAgility
				+rawWeapon.\ProperMagic
				+rawWeapon.\ProperFaith
			]

			..atk = [
				+rawWeapon.\AttackBasePhysics
				+rawWeapon.\AttackBaseMagic
				+rawWeapon.\AttackBaseFire
				+rawWeapon.\AttackBaseThunder

			]

			..bonus = [
				+rawWeapon.\CorrectStrength / 100
				+rawWeapon.\CorrectAgility / 100
				+rawWeapon.\CorrectMagic / 100
				+rawWeapon.\CorrectFaith / 100
			]

			..dmg = [
				+rawWeapon.\AntSaintDamageRate
				+rawWeapon.\AntWeakA_DamageRate
			]

			..range = +rawWeapon.\BowDistRate

			# Attack costs
			..atkCosts = [
				+raw.behavior["#{rawWeapon.[\BehaviorVariationId]}0"]?.[\Stamina]
				+raw.behavior["#{rawWeapon.[\BehaviorVariationId]}100"]?.[\Stamina]
				+raw.behavior["#{rawWeapon.[\BehaviorVariationId]}200"]?.[\Stamina]
				+raw.behavior["#{rawWeapon.[\BehaviorVariationId]}300"]?.[\Stamina]
			]


		# Bleed, poison and healing
		values = [0 0 0]
		dmgValues = [0 0]
		for effectField in [\SpEffectBehaviorId0 \SpEffectBehaviorId1 \SpEffectBehaviorId2 ]
			if +rawWeapon[effectField] < 1 then continue

			effect = raw.effects[+rawWeapon[effectField]]

			switch +effect.\StateInfo
			| effectMap.\bleed =>
				values.0 = +effect.\RegistBlood
				dmgValues.0 = +effect.\ChangeHpRate
			| effectMap.\toxic => fallthrough
			| effectMap.\poison =>
				values.1 = +effect.\PoizonAttackPower
				dmgValues.1 = +effect.\ChangeHpPoint
			| effectMap.\heal =>
				values.2 = -1 * effect.\ChangeHpPoint

		weapon.atk ++= values ++ +rawWeapon.\AttackBaseStamina
		weapon.dmg = dmgValues ++ weapon.dmg

		#if (not weapon.name?) or weapon.name.indexOf(\Dagger) < 0 then continue

		weapons.push weapon

		weapon |> $addToIndex
		# Also add to index all the upgrade versions
		for a from 1 to 15
			{
				\id : weapon.id + a
				\itemType : \weapon
			}
				.. |> setName
				.. |> $addToIndex if ..name?

	fs.writeFileSync "#{folder}/weapons.json", JSON.stringify weapons


processArmor = (folder) !->
	console.log "Processing armors..."
	armors = []

	for armorData in raw.armors
		armor = {}
			..id = +armorData.\Id
			..itemType = \armor
			.. |> setName

		# armors without names cannot be recognized and so are useless
		if not armor.name? then continue

		armor
			..durability = +armorData.\DurabilityMax
			..weight = +armorData.\Weight
			..sellValue = +armorData.\SellValue
			..iconId = +armorData.\IconIdF

			..def = [
				+armorData.\DefensePhysics
				+armorData.\DefenseMagic
				+armorData.\DefenseFire
				+armorData.\DefenseThunder

				+armorData.\ResistPoison
				+armorData.\ResistBlood
				+armorData.\ResistCurse

				+armorData.\Poise
			]

			..defPhy = [
				+armorData.\DefenseSlash
				+armorData.\DefenseBlow
				+armorData.\DefenseThrust
			]

			..matSetId = +armorData.\MaterialSetId
			..upgradeCost = +armorData.\BasicPrice
			..upgradeId = if ..matSetId > 0 then +armorData.\ShopLv else -1

			..armorType = switch +armorData.\DefenseMaterialSfx
				| 5 => \head
				| 2 => \chest
				| 1 => \hands
				| 6 => \legs

			..armorSet = armorData.\Set


		# Stamina recovery mod
		armor.staRegenMod = 0
		for effectField in [\ResidentSpEffectId \ResidentSpEffectId2 \ResidentSpEffectId3 ]
			if +armorData[effectField] < 0 then continue

			effect = raw.effects[+armorData[effectField]]

			if +effect.\StaminaRecoverChangeSpeed != 0
				armor.staRegenMod = +effect.\StaminaRecoverChangeSpeed


		armors.push armor

		armor
			.. |> $addToIndex
			.. |> $addToSetIndex

		# Also add to index all the upgrade versions
		for a from 1 to 10
			upArmor = {
				\id : armor.id + a
				\itemType : \armor
			}
				.. |> setName
				.. |> $addToIndex if ..name?



	fs.writeFileSync "#{folder}/armors.json", JSON.stringify armors


processArmorUpgrades = (folder = '.') !->
	console.log "Processing armor upgrades..."

	upgrades = []

	for key, rawUp of raw.armorUpgrades
		upgrade = { id : +rawUp.\Id }
			..defMod = [
				+rawUp.\PhysicsDefRate
				+rawUp.\MagicDefRate
				+rawUp.\FireDefRate
				+rawUp.\ThunderDefRate
				+rawUp.\ResistPoisonRate
				+rawUp.\ResistBloodRate
				+rawUp.\ResistCurseRate
			]

			..defPhyMod = [
				+rawUp.\SlashDefRate
				+rawUp.\BlowDefRate
				+rawUp.\ThrustDefRate
			]

			..matSetId = +rawUp.\MaterialSetId

		upgrades.push upgrade

	fs.writeFileSync "#{folder}/armor-upgrades.json", JSON.stringify upgrades


rawDataLoaded = !->
	folder = ".."
	processMaterialSets folder
	processItems folder
	processWeapons folder
	processUpgrades folder
	processArmor folder
	processArmorUpgrades folder

	fs.writeFileSync "#{folder}/index.json", JSON.stringify $index

	fs.writeFileSync "#{folder}/armor-set-index.json", JSON.stringify $armorSetIndex