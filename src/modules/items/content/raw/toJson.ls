require! [ \fs \csv-parse ]
global <<< require \prelude-ls

raw = {}
	..names = {}
	..descs = {}
	..effects = {}
	..materialSets = {}
	..upgrades = {}

	..weapons = []
	..items = {}


$index = []


$addToIndex = (item) !->
	entry = {}
	for field in [\id \name \itemType]
		entry[field] = item[field]

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


parseTexts = (data) !->
	target = {}
	for row in data
		target[+row.\Id] = row.\Value
	return target


console.log "Loading names..."
nameFiles = [ \item_name \item_name_dlc \weapon_name \weapon_name_dlc ]

a = 0
for file in nameFiles
	content = fs.readFileSync "#{file }.csv", { \encoding : \utf8 }
	csvParse content, { \columns : true } (err, data) !->
		if err? then throw err
		raw.{}names <<< parseTexts data
		if ++a == nameFiles.length - 1
			loadDescs!

loadDescs = !->
	a = 0
	console.log "Loading descriptions..."
	descFiles = [ \weapon_desc \weapon_desc_dlc ]
	for file in descFiles
		content = fs.readFileSync "#{file }.csv", { \encoding : \utf8 }
		csvParse content, { \columns : true }, (err, data) !->
			if err? then throw err
			raw.{}descs <<< parseTexts data
			if ++a == descFiles.length - 1
				loadUpgrades!

loadUpgrades = !->
	console.log "Loading reinforcement data..."
	content = fs.readFileSync \upgrades.csv , { \encoding : \utf8 }
	csvParse content, { \columns : true }, (err, data) !->
		if err? then throw err
		for row in data
			raw.{}upgrades[row.\Id] = row
		loadWeapons!

loadWeapons = !->
	console.log "Loading weapon data..."
	content = fs.readFileSync \weapons.csv , { \encoding : \utf8 }
	csvParse content, { \columns : true }, (err, data) !->
		if err? then throw err
		for row in data
			raw.[]weapons.push row
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
	item.name = raw.names[item.id]
	item.desc = raw.descs[item.id]


processUpgrades = (folder = '.') !->
	console.log "Processing upgrades..."

	upgrades = []

	for key, rawUp of raw.upgrades
		matSet = raw.materialSets[+rawUp.\Id] ? raw.materialSets[+rawUp.\MaterialSetId]

		upgrade = { id : +rawUp.\Id }
			..dmgModN = +rawUp.\PhysicsAtkRate
			..dmgModM = +rawUp.\MagicAtkRate
			..dmgModF = +rawUp.\FireAtkRate
			..dmgModL = +rawUp.\ThunderAtkRate
			..dmgModS = +rawUp.\StaminaAtkRate

			..scModP = +rawUp.\CorrectStrengthRate
			..scModD = +rawUp.\CorrectAgilityRate
			..scModI = +rawUp.\CorrectMagicRate
			..scModF = +rawUp.\CorrectFaithRate

			..defModN = +rawUp.\PhysicsGuardCutRate
			..defModM = +rawUp.\MagicGuardCutRate
			..defModF = +rawUp.\FireGuardCutRate
			..defModL = +rawUp.\ThunderGuardCutRate

			..defModT = +rawUp.\PoisonGuardResistRate
			..defModB = +rawUp.\BloodGuardResistRate
			..defModC = +rawUp.\CurseGuardResistRate

			..defModS = +rawUp.\StaminaGuardDefRate

			..matId = +matSet.\MaterialId01
			..matCost = +matSet.\ItemNum01

		upgrades.push upgrade

	fs.writeFileSync "#{folder}/upgrades.json", JSON.stringify upgrades


processItems = (folder = '.') !->
	console.log "Processing items..."

	items = []

	for key, rawItem of raw.items
		item = { id : +rawItem.\Id }
			.. |> setTexts
			..sell = +rawItem.\SellValue
			..itemType = \item

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

			.. |> setTexts

		# Weapons without names cannot be recognized and so are useless
		if not weapon.name? then continue

		weapon
			..itemType = \weapon
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
				..buildB = +effect.\RegistBlood
				..dmgB = +effect.\ChangeHpRate
			| effectMap.\toxic => fallthrough
			| effectMap.\poison => weapon
				..buildT = +effect.\PoizonAttackPower
				..dmgT = +effect.\ChangeHpPoint
			| effectMap.\heal => weapon
				..healHit = -1 * effect.\ChangeHpPoint

		#if (not weapon.name?) or weapon.name.indexOf(\Dagger) < 0 then continue

		weapons.push weapon

		weapon |> $addToIndex

	fs.writeFileSync "#{folder}/weapons.json", JSON.stringify weapons



rawDataLoaded = !->
	folder = ".."
	processItems folder
	processWeapons folder
	processUpgrades folder
	fs.writeFileSync "#{folder}/index.json", JSON.stringify $index