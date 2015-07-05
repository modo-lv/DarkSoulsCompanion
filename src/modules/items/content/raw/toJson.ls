require! [ \fs \csv-parse ]
global <<< require \prelude-ls

raw = {}
	..names = {}
	..effects = {}
	..materialSets = {}
	..upgrades = {}

	..weapons = []
	..items = {}


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
		target[type + row.\Id] = row.\Value
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
					loadUpgrades!
		) type

loadUpgrades = !->
	console.log "Loading reinforcement data..."
	content = fs.readFileSync \upgrades.csv , { \encoding : \utf8 }
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
		rawDataLoaded!


setTexts = (item) !->
	uid = item.itemType + item.id
	item.name = raw.names[uid]


processUpgrades = (folder = '.') !->
	console.log "Processing weapon upgrades..."

	upgrades = []

	for key, rawUp of raw.upgrades
		matSet = raw.materialSets[+rawUp.\Id] ? raw.materialSets[+rawUp.\MaterialSetId]
		#console.log rawUp
		#console.log rawUp.\MaterialSetId
		#console.log raw.materialSets[+rawUp.\MaterialSetId]

		upgrade = { id : +rawUp.\Id }
			..atkModN = +rawUp.\PhysicsAtkRate
			..atkModM = +rawUp.\MagicAtkRate
			..atkModF = +rawUp.\FireAtkRate
			..atkModL = +rawUp.\ThunderAtkRate
			..atkModS = +rawUp.\StaminaAtkRate

			..scModS = +rawUp.\CorrectStrengthRate
			..scModD = +rawUp.\CorrectAgilityRate
			..scModI = +rawUp.\CorrectMagicRate
			..scModF = +rawUp.\CorrectFaithRate

			..defModN = +rawUp.\PhysicsGuardCutRate
			..defModM = +rawUp.\MagicGuardCutRate
			..defModF = +rawUp.\FireGuardCutRate
			..defModL = +rawUp.\ThunderGuardCutRate
			..defModS = +rawUp.\StaminaGuardDefRate

			..defModT = +rawUp.\PoisonGuardResistRate
			..defModB = +rawUp.\BloodGuardResistRate
			..defModC = +rawUp.\CurseGuardResistRate

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
			.. |> setTexts
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
			.. |> setTexts

		# Weapons without names cannot be recognized and so are useless
		if not weapon.name? then continue

		weapon
			..dur = +rawWeapon.\DurabilityMax
			..weight = +rawWeapon.\Weight
			..sell = +rawWeapon.\SellValue
			..path = pathMap[+rawWeapon.\BaseChangeCategory]

			..wepCat = rawWeapon.\WeaponCategory
			..canB = rawWeapon.\EnableGuard == \True
			..canP = rawWeapon.\EnableParry == \True
			..isMag = rawWeapon.\EnableMagic == \True
			..isPyr = rawWeapon.\EnableSorcery == \True
			..isMir = rawWeapon.\EnableMiracle == \True
			..isGhost = rawWeapon.\IsVersusGhostWep == \True
			..isAug = rawWeapon.\IsEnhance == \True

			..iconId = +rawWeapon.\IconId

			..isDmgReg = rawWeapon.\IsNormalAttackType == \True
			..isDmgStr = rawWeapon.\IsBlowAttackType == \True
			..isDmgSl = rawWeapon.\IsSlashAttackType == \True
			..isDmgThr = rawWeapon.\IsThrustAttackType == \True

			..reqS = +rawWeapon.\ProperStrength
			..reqD = +rawWeapon.\ProperAgility
			..reqI = +rawWeapon.\ProperMagic
			..reqF = +rawWeapon.\ProperFaith

			..dmgN = +rawWeapon.\AttackBasePhysics
			..dmgM = +rawWeapon.\AttackBaseMagic
			..dmgF = +rawWeapon.\AttackBaseFire
			..dmgL = +rawWeapon.\AttackBaseThunder
			..dmgS = +rawWeapon.\AttackBaseStamina
			..dmgP = +rawWeapon.\AttackBaseRepel

			..scS = +rawWeapon.\CorrectStrength / 100
			..scD = +rawWeapon.\CorrectAgility / 100
			..scI = +rawWeapon.\CorrectMagic / 100
			..scF = +rawWeapon.\CorrectFaith / 100

			..defN = +rawWeapon.\PhysGuardCutRate
			..defM = +rawWeapon.\MagGuardCutRate
			..defF = +rawWeapon.\FireGuardCutRate
			..defL = +rawWeapon.\ThunGuardCutRate
			..defP = +rawWeapon.\GuardBaseRepel

			..defT = +rawWeapon.\PoisonGuardResist
			..defB = +rawWeapon.\BloodGuardResist
			..defC = +rawWeapon.\CurseGuardResist

			..defS = +rawWeapon.\StaminaGuardDef

			..divMod = +rawWeapon.\AntSaintDamageRate
			..occMod = +rawWeapon.\AntWeakA_DamageRate

			..upCost = +rawWeapon.\BasicPrice

			..path = pathMap[+rawWeapon.\BaseChangeCategory]

			..range = +rawWeapon.\BowDistRate

			..upgradeId = +rawWeapon.\ReinforceTypeId

		# Bleed & poison
		for effectField in [\SpEffectBehaviorId0 \SpEffectBehaviorId1 \SpEffectBehaviorId2 ]
			continue unless +rawWeapon[effectField] > 0

			effect = raw.effects[+rawWeapon[effectField]]

			switch +effect.\StateInfo
			| effectMap.\bleed => weapon
				..atkB = +effect.\RegistBlood
				..dmgB = +effect.\ChangeHpRate
			| effectMap.\toxic => fallthrough
			| effectMap.\poison => weapon
				..atkT = +effect.\PoizonAttackPower
				..dmgT = +effect.\ChangeHpPoint
			| effectMap.\heal => weapon
				..atkH = -1 * effect.\ChangeHpPoint

		#if (not weapon.name?) or weapon.name.indexOf(\Dagger) < 0 then continue

		weapons.push weapon

		weapon |> $addToIndex

	fs.writeFileSync "#{folder}/weapons.json", JSON.stringify weapons


processArmor = (folder) !->
	console.log "Processing armors..."
	armors = []

	for armorData in raw.armors
		armor = {}
			..id = +armorData.\Id
			..itemType = \armor
			.. |> setTexts

		# armors without names cannot be recognized and so are useless
		if not armor.name? then continue

		armor
			..dur = +armorData.\DurabilityMax
			..weight = +armorData.\Weight
			..sell = +armorData.\SellValue


			..armorType = switch +armorData.\DefenseMaterialSfx
				| 5 => \head
				| 2 => \chest
				| 1 => \hands
				| 6 => \legs

			..armorSet = armorData.\Set

			..iconId = +armorData.\IconIdF

			..defN = +armorData.\DefensePhysics
			..defSl = +armorData.\DefenseSlash
			..defSt = +armorData.\DefenseBlow
			..defTh = +armorData.\DefenseThrust
			..defM = +armorData.\DefenseMagic
			..defF = +armorData.\DefenseFire
			..defL = +armorData.\DefenseThunder
			..defP = +armorData.\Poise

			..defT = +armorData.\ResistPoison
			..defB = +armorData.\ResistBlood
			..defC = +armorData.\ResistCurse

			..matSetId = +armorData.\MaterialSetId
			..upgradeId = if ..matSetId > 0 then +armorData.\ShopLv else -1

		# Bleed & poison
		for effectField in [\ResidentSpEffectId \ResidentSpEffectId2 \ResidentSpEffectId3 ]
			if +armorData[effectField] < 0 then continue

			effect = raw.effects[+armorData[effectField]]

			if +effect.\StaminaRecoverChangeSpeed != 0
				armor.stRec = +effect.\StaminaRecoverChangeSpeed


		armors.push armor

		armor
			.. |> $addToIndex
			.. |> $addToSetIndex


	fs.writeFileSync "#{folder}/armors.json", JSON.stringify armors


processArmorUpgrades = (folder = '.') !->
	console.log "Processing armor upgrades..."

	upgrades = []

	for key, rawUp of raw.armorUpgrades
		upgrade = { id : +rawUp.\Id }
			..defModN = +rawUp.\PhysicsDefRate
			..defModSl = +rawUp.\SlashDefRate
			..defModSt = +rawUp.\BlowDefRate
			..defModTh = +rawUp.\ThrustDefRate
			..defModM = +rawUp.\MagicDefRate
			..defModF = +rawUp.\FireDefRate
			..defModL = +rawUp.\ThunderDefRate

			..defModT = +rawUp.\ResistPoisonRate
			..defModB = +rawUp.\ResistBloodRate
			..defModC = +rawUp.\ResistCurseRate

			# For upgrades, MaterialSetId is added to the
			# existing MaterialSetId on the armor and the result
			# is the actual material set ID containing requirements
			# for the upgrade
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