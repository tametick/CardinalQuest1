// THIS FILE IS AUTOMATICALLY GENERATED FROM TEXT FILES IN /BIN. DO NOT MODIFYpackage data;/** * ... * @author randomnine */class StatsFileEmbed {	public static function loadEmbeddedFiles() 	{		var embedText:String;		var embedFile:StatsFile;		embedText = "Field String ID
Field String Sprite
Field Int Portrait
Field String EntryBG
Field Int DamagePref
Field Int AttackPref
Field Int DefensePref
Field Int SpeedPref
Field Int SpiritPref
Field Int LifePref
Field String Item1
Field String Item2
Field String Item3
Field String Item4
Field String Item5
Field String Item6

; ID    Sprite  Prt EntryBG            Dmg Atk Def Spd Spr Lif Items
FIGHTER fighter   1 SpriteKnightEntry   80 100 100  90  25  50 SHORT_SWORD BERSERK     RED_POTION RED_POTION BLUE_POTION
WIZARD  wizard    2 SpriteWizardEntry   25  50  50 200 300 100 STAFF       FIREBALL    RED_POTION PURPLE_POTION PURPLE_POTION
THIEF   thief     0 SpriteThiefEntry    55 100  50 200  50  50 DAGGER      SHADOW_WALK RED_POTION RED_POTION YELLOW_POTION GREEN_POTION
";		embedFile = StatsFile.loadFromString( "classes.txt", embedText );		embedText = "Field String ID
Field Int Level
Field Int Attack
Field Int Defense
Field Int Speed
Field Int Spirit
Field Int Vitality
Field Int HP

; ID    Lvl Atk Def Spd Spr Vit HP
FIGHTER   1   5   3   5   1   4 12
FIGHTER   2   5   3   5   1   4 16
FIGHTER   3   5   3   5   1   4 20
FIGHTER   4   5   3   5   1   4 24
FIGHTER   5   5   3   5   1   4 28
FIGHTER   6   5   3   5   1   4 32
FIGHTER   7   5   3   5   1   4 36
FIGHTER   8   5   3   5   1   4 40
FIGHTER   9   5   3   5   1   4 44

WIZARD    1   2   2   6   4   2  8
WIZARD    2   2   2   6   4   2 10
WIZARD    3   2   2   6   4   2 12
WIZARD    4   2   2   6   4   2 14
WIZARD    5   2   2   6   4   2 16
WIZARD    6   2   2   6   4   2 18
WIZARD    7   2   2   6   4   2 20
WIZARD    8   2   2   6   4   2 22
WIZARD    9   2   2   6   4   2 24

THIEF     1   3   3  10   3   3  6
THIEF     2   3   3  10   3   3  9
THIEF     3   3   3  10   3   3 12
THIEF     4   3   3  10   3   3 15
THIEF     5   3   3  10   3   3 18
THIEF     6   3   3  10   3   3 21
THIEF     7   3   3  10   3   3 24
THIEF     8   3   3  10   3   3 27
THIEF     9   3   3  10   3   3 30";		embedFile = StatsFile.loadFromString( "classStats.txt", embedText );		embedText = "Field String ID
Field String Data

; Cutscenes!
\"AsterionIntro\"    \"The dread minotaur Asterion fell upon the peaceful town of Hallemot late one balmy night.  The few townsfolk he did not kill, he made his slaves.  Their misery is his delight.\n\nYears have passed.  Deep in his underground den, he and his minions exult in the spoils of their wicked deeds.  They revel in human suffering.\n\nYou fled when you were young.  You grew strong.  The time has come to rid the land of his dominion.\"
\"AsterionDefeated\" \"As you slay the last of his servants, Asterion himself draws near, bellowing laughter, pleased by the show.  He intones an ancient incantation.\n\nA shimmering portal appears.  He steps inside.  You have driven the minotaur away!  There is peace again in Hallemot!\n\nYes, there is peace again.  For now.\"

; Classes.
\"FIGHTER\"    \"A mighty warrior of unparalleled strength and vigor, honorable in battle, high master of hack-n-slash melee.\n\nThe best choice for new players.\"
\"WIZARD\"     \"A wise sage, knower of secrets, worker of miracles, master of the arcane arts, maker of satisfactory mixed drinks.\n\nCan cast spells rapidly - use his mystic powers as often as possible.\"
\"THIEF\"      \"A cunning and agile rogue whose one moral credo is this: Always get out alive.\n\nThe most challenging character - use his speed and skills to avoid taking damage.\"

; Class entry blurb.
\"SpriteKnightEntry\" \"You descend with shining sword into the dismal dwelling of the maleficent minotaur.  The haughty chatter of his servants, twisted and evil, fills the air.\n\nYou smile, for today you will shed much blood.\"
\"SpriteWizardEntry\" \"The unsettled souls of the anguished dead whisper of the minotaur's misdeeds.  On bended knee you swear to them that they will be avenged.\n\nArcane flames dance between your hands.  The minotaur's wretched minions will be the most delightful playthings.\"
\"SpriteThiefEntry\"  \"You slink silently down unlit stairs.  The minotaur's wicked servants suspect nothing.\n\nYou cannot help but grin at the thought of the bounteous treasure they will soon relinquish.\"

; Potions.
RED_POTION       \"A small vial containing a fragrant, red salve. It restores life when applied.\"
PURPLE_POTION    \"A refreshing draught which charges spells and sets nerves tingling.\"
GREEN_POTION     \"This elixir temporarily grants ultra-human strength and reflexes.\"
BLUE_POTION      \"This elixir temporarily protects the drinker's body with a thick hide.\"
YELLOW_POTION    \"This mysterious beverage grants great speed when quaffed.\"

; Boots.
BOOTS            \"These finely crafted leather boots allow the wearer to run with great speed.\"
WINGED_SANDALS   \"These winged sandals are made of imperishable gold and allow the wearer to move as swiftly as any bird.\"
TUNDRA_BOOTS     \"Made for the toughest of conditions, these boots give you superior mobility on every terrain.\"

; Armor.
LEATHER_ARMOR    \"This armor is made of leather that was boiled in wax for extra toughness.\"
BREASTPLATE      \"This iron breastplate offers excellent protection to vital organs without limiting mobility.\"
CLOAK            \"Made from enchanted cloth, both light and durable. Wearing this feels like touching the sky.\"
FULL_PLATE_MAIL  \"A classic, well tested model of armor highly praised by knights from around the globe.\"

; Jewelry.
RING             \"This small, silver ring imbues its wearer with uncanny wisdom.\"
AMULET           \"Enlightenment permeates this simple looking amulet, granting its wearer the spirit of the gods.\"
GEMMED_AMULET    \"Inscribed upon this amulet are magic runes, which yield many benefits for the wearer.\"
GEMMED_RING      \"You sense a powerful force in this ring. It feels like life itself is flowing from it.\"

; Hats.
CAP              \"This steel skullcap protects the head without restricting the wearer's ability to wear fashionable hats.\"
HELM             \"This helm is crafted by dwarven smiths in the Roshaggon mines using an alloy jealously kept secret.\"
FULL_HELM        \"Originally worn by dark priests, this helmet helps you tap into energies of the full moon.\"
GOLDEN_HELM      \"Made of pure gold, this helmet gives you unbreachable head protection and irresistible looks.\"

; Gloves.
GLOVE            \"The swiftness of these hand gloves allows their wearer to perform faster in battle.\"
BRACELET         \"This magical bronze bracer contains within it the great warrior's spirit.\"
GAUNTLET         \"These decorated gauntlets are crafted skillfully and with attention to detail.\"

; Weapons.
DAGGER           \"A double-edged blade used for stabbing or thrusting.\"
SHORT_SWORD      \"A one handed hilt attached to a thrusting blade approximately 60cm in length.\"
STAFF            \"A sturdy shaft of hardwood with metal tips.\"
LONG_SWORD       \"Long swords have long cruciform hilts with grips and double-edged blades over one meter long.\"
AXE              \"A mighty axe, good for chopping both wood and flesh.\"
BATTLE_AXE       \"Crafted from the finest of metals, this axe can deal lethal slashing, cleaving and slicing blows.\"
RUNE_SWORD       \"This finely crafted sword pulses with mystical energy.\"
MACE             \"A mighty huge and spiky mace made for fast swinging and powerful rips.\"
CLAYMORE         \"An ancient weapon. Many bards have sung of glorious victories won with it.\"
BROAD_SWORD      \"An elegant weapon for a more civilized age. It was crafted by a master blacksmith from the distant orient.\"

; Spells.
BERSERK          \"Induces a berserked rage that greatly increases your strength and speed.\"
BLESS_WEAPON     \"Blesses the currently wielded weapon, providing a temporary boost to its effectiveness.\"
HASTE            \"Makes you faster and more nimble.\"
SHADOW_WALK      \"Renders you invisible for a few seconds.\"
STONE_SKIN       \"Hardens your skin, rendering you tough but slow.\"
BLINK            \"Transports you to a random location.\"
MAGIC_ARMOR      \"Engulfs you in a magical protective aura.\"
PASS_WALL        \"Enables walking through walls as if they were thin air.\"
REVEAL_MAP       \"Reveals the layout of the current floor.\"
HEAL             \"Restores health and vigor.\n\nCharge this spell by defeating foes.\"

FREEZE           \"Freezes a monster in place for a short duration.\"
FIREBALL         \"Hurls a ball of fire that explodes on impact.\"
ENFEEBLE_MONSTER \"Weakens monsters and renders them less dangerous.\"
CHARM_MONSTER    \"Charms a foe and temporarily brings them to your side.\"
POLYMORPH        \"Transform a creature into another form.\"
SLEEP            \"Puts a monster into a deep slumber.\"
FEAR             \"Makes a monster flee in horror.\"

MAGIC_MIRROR     \"Creates a duplicate of yourself to draw enemies away.\"
TELEPORT         \"Transports you to a specific location of your choice.\"
";		embedFile = StatsFile.loadFromString( "descriptions.txt", embedText );		embedText = "Field String ID
Field String Sprite
Field String Slot
Field Int LevelMin
Field Int LevelMax
Field Int Weight
Field Int DamageMin
Field Int DamageMax
Field String Buff1
Field Int Buff1Val
Field String Buff2
Field Int Buff2Val

; ID            Sprite          Slot    Lv- Lv+ Wgt Dmg- Dmg+ Buff1   V1 Buff2   V2 
BOOTS           boots           SHOES     1   1 100    0    0 speed    1
WINGED_SANDALS  winged_sandals  SHOES     3   4 100    0    0 speed    2
TUNDRA_BOOTS    tundra_boots    SHOES     7  99 100    0    0 speed    2 defense  1

; ID            Sprite          Slot    Lv- Lv+ Wgt Dmg- Dmg+ Buff1   V1 Buff2   V2 
LEATHER_ARMOR   leather_armor   ARMOR     1   1 100    0    0 defense  1
BREASTPLATE     breastplate     ARMOR     2   3 100    0    0 defense  2
CLOAK           cloak           ARMOR     5   6 100    0    0 defense  2 speed    2
FULL_PLATE_MAIL full_plate_mail ARMOR     7  99 100    0    0 defense  4

; ID            Sprite          Slot    Lv- Lv+ Wgt Dmg- Dmg+ Buff1   V1 Buff2   V2 
RING            ring            JEWELRY   2   3 100    0    0 spirit   1
AMULET          amulet          JEWELRY   4   5 100    0    0 spirit   2
GEMMED_AMULET   gemmed_amulet   JEWELRY   6   7 100    0    0 spirit   2 defense  2
GEMMED_RING     gemmed_ring     JEWELRY   8  99 100    0    0 life     3 spirit   2

; ID            Sprite          Slot    Lv- Lv+ Wgt Dmg- Dmg+ Buff1   V1 Buff2   V2 
CAP             cap             HAT       1   2 100    0    0 life     1
HELM            helm            HAT       4   5 100    0    0 life     2
FULL_HELM       full_helm       HAT       6   7 100    0    0 life     4
GOLDEN_HELM     golden_helm     HAT       8  99 100    0    0 life     2 defense  3

; ID            Sprite          Slot    Lv- Lv+ Wgt Dmg- Dmg+ Buff1   V1 Buff2   V2 
GLOVE           glove           GLOVES    1   2 100    0    0 attack   1
BRACELET        bracelet        GLOVES    3   4 100    0    0 attack   2
GAUNTLET        gauntlet        GLOVES    6   7 100    0    0 attack   2 defense  2

; ID            Sprite          Slot    Lv- Lv+ Wgt Dmg- Dmg+ Buff1   V1 Buff2   V2 
DAGGER          dagger          WEAPON    1   1 100    1    2
SHORT_SWORD     short_sword     WEAPON    1   2 100    1    3
STAFF           staff           WEAPON    2   3 100    1    3 spirit   1
LONG_SWORD      long_sword      WEAPON    3   4 100    2    4
MACE            mace            WEAPON    4   5 100    4    9 speed   -1
AXE             axe             WEAPON    5   6 100    3    6
BATTLE_AXE      battle_axe      WEAPON    6   7 100    4   12 speed   -2
RUNE_SWORD      rune_sword      WEAPON    6   7  50    2    7 spirit   1
CLAYMORE        claymore        WEAPON    7  99 100    6   11 speed   -1
BROAD_SWORD     broad_sword     WEAPON    8  99 100    5   12 defense -2 speed    2
";		embedFile = StatsFile.loadFromString( "items.txt", embedText );		embedText = "Field String Class
Field Int Weight
Field String Sprite
Field String NameID
Field Int Attack
Field Int Defense
Field Int Speed
Field Int Spirit
Field Int VitalityMin
Field Int VitalityMax
Field Int DamageMin
Field Int DamageMax
Field Int XP
Field String Spell1
Field String Spell2

; Class     Wgt Sprite                   NameID             Atk Def Spd Spr V- V+ D- D+  XP Spell1           Spell2
Bandit        1 bandit_long_swords       BANDIT_CAPTAIN       2   2   8  30  2  3  1  1   5
Bandit        1 bandit_short_swords      BANDIT               2   2   5  30  4  6  1  1   5
Bandit        1 bandit_single_long_sword BANDIT               2   2   6  30  2  3  1  1   5
Bandit        1 bandit_knives            BANDIT               2   2   6  30  2  3  1  1   5

; Class     Wgt Sprite                   NameID             Atk Def Spd Spr V- V+ D- D+  XP Spell1           Spell2
Kobold        1 kobold_spear             KOBOLD_SPEAR         4   3   6   3  2  6  2  4  10
Kobold        1 kobold_knives            KOBOLD               4   3   8   3  2  6  1  4  10
Kobold        1 kobold_mage              KOBOLD_MAGE          4   3   6  12  2  6  1  3  10 TELEPORT

; Class     Wgt Sprite                   NameID             Atk Def Spd Spr V- V+ D- D+  XP Spell1           Spell2
Succubus      1 succubus                 SUCCUBUS             3   2   8   4  2  8  2  5  25 ENFEEBLE_MONSTER
Succubus      1 succubus_staff           SUCCUBUS             3   2   8   4  2  8  2  5  25 ENFEEBLE_MONSTER
Succubus      1 succubus_whip            SUCCUBUS_WHIP        3   2  10   2  2  8  2  5  25 ENFEEBLE_MONSTER
Succubus      1 succubus_scepter         SUCCUBUS             3   2   8   8  2  8  2  5  25 ENFEEBLE_MONSTER SHADOW_WALK

; Class     Wgt Sprite                   NameID             Atk Def Spd Spr V- V+ D- D+  XP Spell1           Spell2
Spider        1 spider_yellow            SPIDER               5   3   6   2  5 12  2  8  50 FREEZE
Spider        1 spider_red               SPIDER_RED           5   1   6   4 10 19  2  6  50 FREEZE
Spider        1 spider_gray              SPIDER_GRAY          5   2   9   1  5 12  2  6  50 FREEZE
Spider        1 spider_green             SPIDER               5   3   6   2  5 12  2  8  50 FREEZE

; Class     Wgt Sprite                   NameID             Atk Def Spd Spr V- V+ D- D+  XP Spell1           Spell2
Ape           1 ape_blue                 APE                  6   6  10   3  4 16  3  6 125
Ape           1 ape_black                APE                  6   6  10   3  4 16  3  6 125
Ape           1 ape_red                  APE_DEMONIC          7   8   7   3  8 20  3  6 125
Ape           1 ape_white                APE                  6   6  10   3  4 16  3  6 125

; Class     Wgt Sprite                   NameID             Atk Def Spd Spr V- V+ D- D+  XP Spell1           Spell2
Elemental     1 elemental_green          ELEMENTAL_AIR        4   4  12   6  8 26  4  8 275 FIREBALL         SHADOW_WALK
Elemental     1 elemental_white          ELEMENTAL_NATURE     4   4   8   6 14 32  4  8 275 FIREBALL         STONE_SKIN
Elemental     1 elemental_red            ELEMENTAL_SORCERY    4   4  10  18  8 26  4  8 275 MAGIC_MIRROR     TELEPORT
Elemental     1 elemental_blue           ELEMENTAL_CHAOS      4   4   8  12  8 26  4  8 275 FIREBALL

; Class     Wgt Sprite                   NameID             Atk Def Spd Spr V- V+ D- D+  XP Spell1           Spell2
Werewolf      1 werewolf_gray            WEREWOLF             5   5  12   4 12 32  4 10 500 HASTE
Werewolf      1 werewolf_blue            WEREWOLF             5   5  12   4 12 32  4 10 500 HASTE
Werewolf      1 werewolf_purple          WEREWOLF             5   5  12   4 12 32  4 10 500 HASTE

; Class     Wgt Sprite                   NameID             Atk Def Spd Spr V- V+ D- D+  XP Spell1           Spell2
Minotaur      1 minotaur                 MINOTAUR             7   6  12   4 48 72  8 14 950 BERSERK
Minotaur      1 minotaur_axe             MINOTAUR             7   6  10   4 48 72 12 18 950 BERSERK
Minotaur      1 minotaur_sword           MINOTAUR             7   6  10   4 48 72 12 18 950 BERSERK
";		embedFile = StatsFile.loadFromString( "mobs.txt", embedText );		embedText = "Field String ID
Field String Sprite
Field Int Weight
Field Int Duration
Field String Buff
Field Int BuffVal
Field String Effect
Field String EffectVal

; ID          Sprite        Weight Duration Buff      BV Effect              EV
RED_POTION    red_potion       100        0 \"\"         0 heal                full
PURPLE_POTION purple_potion     65        0 \"\"         0 charge              full
GREEN_POTION  green_potion      50       80 attack     3 \"damage multiplier\" 2
BLUE_POTION   blue_potion       50      120 defense    6
YELLOW_POTION yellow_potion     35       80 speed      6
";		embedFile = StatsFile.loadFromString( "potions.txt", embedText );		embedText = "Field String ID
Field Int Level
Field Int DamageMin
Field Int DamageMax

; ID      Lvl D- D+
FIREBALL    0  1  3
FIREBALL    1  1  4
FIREBALL    2  1  5
FIREBALL    3  2  6
FIREBALL    4  3  8
FIREBALL    5  3  9
FIREBALL    6  4 10
FIREBALL    7  4 12
FIREBALL    8  5 14";		embedFile = StatsFile.loadFromString( "spellDamage.txt", embedText );		embedText = "Field String ID
Field String Sprite
Field Int Target
Field Int Duration
Field String Stat
Field Int StatPoints
Field String Buff1
Field Int Buff1Val
Field String Buff2
Field Int Buff2Val
Field String Effect
Field String EffectVal

; Legit values for Stat are attack, defense, speed, spirit and vitality.

; Targets self.

; ID             Sprite           Tr Dur Stat    Pts. (B1 B1V B2 B2V Ef EfV)
BERSERK          berserk           0  45 attack  1080 attack 3 speed 3
BLESS_WEAPON     bless_weapon      0  60 spirit   360 attack 3
HASTE            haste             0  60 spirit   540 speed  5
SHADOW_WALK      shadow_walk       0  60 speed   1200 \"\" 0 \"\" 0 invisible
STONE_SKIN       stone_skin        0  60 spirit   480 defense 5 speed -1
BLINK            blink             0   0 spirit   360 \"\" 0 \"\" 0 blink
MAGIC_ARMOR      magic_armor       0  60 spirit   480 defense 3
REVEAL_MAP       reveal_map        0   0 spirit  3600 \"\" 0 \"\" 0 reveal
HEAL             heal              0  60 xp      1600 defense -3 \"\" 0 heal full

; Targets enemy.

; ID             Sprite           Tr Dur Stat   Pts. (B1 B1V B2 B2V Ef EfV)
FREEZE           freeze            1  60 spirit  360 speed -4
FIREBALL         fireball          1   0 spirit  360 
ENFEEBLE_MONSTER enfeeble_monster  1  60 spirit  360 attack -3
CHARM_MONSTER    charm_monster     1  60 spirit  720 \"\" 0 \"\" 0 charm
POLYMORPH        polymorph         1   0 spirit 1080 \"\" 0 \"\" 0 polymorph true
SLEEP            sleep             1  45 spirit  720 \"\" 0 \"\" 0 sleep
FEAR             fear              1  90 spirit  480 \"\" 0 \"\" 0 fear

; Targets empty square.

; ID             Sprite           Tr Dur Stat   Pts. (B1 B1V B2 B2V Ef EfV)
MAGIC_MIRROR     magic_mirror     2   90 spirit  720 \"\" 0 \"\" 0 magic_mirror
TELEPORT         teleport         2    0 spirit  720 \"\" 0 \"\" 0 teleport
";		embedFile = StatsFile.loadFromString( "spells.txt", embedText );		embedText = "Field String ID
Field String Data

; Class names.

FIGHTER         \"Fighter\"
WIZARD          \"Wizard\"
THIEF           \"Thief\"

; Item names.

BOOTS           \"Boots of Escape\"
WINGED_SANDALS  \"Hermes' Sandals\"
TUNDRA_BOOTS    \"Tundra Lizard Boots\"

LEATHER_ARMOR   \"Leather Armor\"
BREASTPLATE     \"Breastplate\"
CLOAK           \"Rogues' Cloak of Swiftness\"
FULL_PLATE_MAIL \"Full Plate Armor\"

RING            \"Ring of Wisdom\"
AMULET          \"Amulet of Enlightenment\"
GEMMED_AMULET   \"Supernatural Amulet\"
GEMMED_RING     \"Ring of Rubies\"

CAP             \"Cap of Endurance\"
HELM            \"Helm of Hardiness\"
FULL_HELM       \"Full Helmet of Vitality\"
GOLDEN_HELM     \"King's Golden Helm\"

GLOVE           \"Gloves of Dexterity\"
BRACELET        \"Achilles' Bracer\"
GAUNTLET        \"Gauntlets of Sturdiness\"

DAGGER          \"Dagger\"
SHORT_SWORD     \"Short Sword\"
STAFF           \"Staff\"
LONG_SWORD      \"Long Sword\"
AXE             \"Axe\"
BATTLE_AXE      \"Hardened Battle Axe\"
RUNE_SWORD      \"Rune Sword\"
MACE            \"Beastly Mace\"
CLAYMORE        \"Broad Claymore\"
BROAD_SWORD     \"Twin Bladed Katana\"

; Potions.

RED_POTION      \"Healing Potion\"
PURPLE_POTION   \"Mana Potion\"
BLUE_POTION     \"Elixir of the Elephant\"
GREEN_POTION    \"Elixir of the Tiger\"
YELLOW_POTION   \"Coca-leaf Cocktail\"

; Spells.

BERSERK         \"Berserk\"
BLESS_WEAPON    \"Bless Weapon\"
HASTE           \"Haste\"
SHADOW_WALK     \"Shadow Walk\"
STONE_SKIN      \"Stone Skin\"
BLINK           \"Blink\"
MAGIC_ARMOR     \"Magic Armor\"
REVEAL_MAP      \"Reveal Map\"
HEAL            \"Heal\"

FREEZE          \"Freeze\"
FIREBALL        \"Fireball\"
ENFEEBLE_MONSTER \"Enfeeble Monster\"
CHARM_MONSTER   \"Charm Monster\"
POLYMORPH       \"Polymorph\"
SLEEP           \"Sleep\"
FEAR            \"Fear\"

MAGIC_MIRROR    \"Magic Mirror\"
TELEPORT        \"Teleport\"

; Mobs.

BANDIT_CAPTAIN  \"Captain\"
BANDIT          \"Bandit\"

KOBOLD_SPEAR    \"Spearkobold\"
KOBOLD          \"Kobold\"
KOBOLD_MAGE     \"Kobold Trickster\"

SUCCUBUS        \"Succubus\"
SUCCUBUS_WHIP   \"Dominatrix\"

SPIDER          \"Spider\"
SPIDER_RED      \"Black Widow\"
SPIDER_GRAY     \"Wolf Spider\"

APE             \"Ape\"
APE_DEMONIC     \"Demon Ape\"

ELEMENTAL_AIR     \"Air Elemental\"
ELEMENTAL_NATURE  \"Nature Elemental\"
ELEMENTAL_SORCERY \"Sorcery Elemental\"
ELEMENTAL_CHAOS   \"Chaos Elemental\"

WEREWOLF        \"Werewolf\"

MINOTAUR        \"Minotaur\"

; Misc.

CHEST           \"Chest\"

; Statistics
\"damage\"        \"damage\"
\"attack\"        \"attack\"
\"defense\"       \"defense\"
\"life\"          \"life\"
\"vitality\"      \"vitality\"
\"speed\"         \"speed\"
\"spirit\"        \"spirit\"

; Special effects
\"damage multiplier\" \"damage multiplier\"
\"charm\"             \"charm\"
\"fear\"              \"fear\"
\"sleep\"             \"sleep\"
\"heal\"              \"heal\"
\"charge\"            \"charge\"

; Ingame messages.
STAT_HEALTH          \"Health\"
STAT_ATTACK          \"Attack\"
STAT_DEFENSE         \"Defense\"
STAT_LIFE            \"Life\"
STAT_VITALITY        \"Vitality\"
STAT_SPEED           \"Speed\"
STAT_SPIRIT          \"Spirit\"

PREFIX_SUPERB        \"Superb\"
PREFIX_WONDROUS      \"Wondrous\"
PREFIX_MAGICAL       \"Magical\"

UI_LEVEL             \"Level\"
UI_TIMES             \"x\"
UI_FLOOR             \"Floor\"
UI_MAP               \"Map\"
UI_INV               \"Inv\"
UI_CHAR              \"Char\"
UI_DAMAGE            \"Damage\"
UI_DESTROY           \"Destroy\"

POPUP_C              \"[hotkey C]\"
POPUP_I              \"[hotkey I]\"
POPUP_M              \"[hotkey M]\"
POPUP_0              \"[hotkey 0]\"
POPUP_1              \"[hotkey 1]\"
POPUP_2              \"[hotkey 2]\"
POPUP_3              \"[hotkey 3]\"
POPUP_4              \"[hotkey 4]\"
POPUP_5              \"[hotkey 5]\"
POPUP_6              \"[hotkey 6]\"
POPUP_7              \"[hotkey 7]\"
POPUP_8              \"[hotkey 8]\"
POPUP_9              \"[hotkey 9]\"
POPUP_ENTER          \"[hotkey enter]\"
POPUP_ESC            \"[hotkey ESC]\"
POPUP_F1             \"[hotkey F1]\"

POPUP_RECOVERED      \"recovered\"
POPUP_EXPIRED        \"wears off\"
POPUP_MIRROR         \"Mirror\"
POPUP_MIRROR_EXPIRED \"Shattered\"
POPUP_INVIS_EXPIRED  \"Reappeared\"
POPUP_EFFECT_EXPIRED \"runs out\"
POPUP_INVIS_BREAK1   \"An invisible\"
POPUP_INVIS_BREAK2   \"appears!\"
POPUP_INVIS_BROKEN   \"You reappear\"
POPUP_FEAR_BREAK     \"Fear broken!\"
POPUP_BACKSTAB       \"Backstab!\"
POPUP_BUMP1          \"You stumble into an invisible\"
POPUP_BUMP2          \".\"
POPUP_BUMPED         \"You have been discovered!\"
POPUP_INVIS          \"Vanished\"
POPUP_HEALED         \"Healed\"
POPUP_CHARGED        \"Charged\"
POPUP_CHARM          \"Charm\"
POPUP_FEAR           \"Fear\"
POPUP_SLEEP          \"Sleep\"
POPUP_POLYMORPH      \"Morph\"
POPUP_COIN           \"coin\"
POPUP_COINS          \"coins\"

NOTIFY_INV_FULL      \"Inventory is full!\"
NOTIFY_STAIRS        \"You have found the stairs!\"
NOTIFY_LATE_STAIRS   \"At long last, the stairway down!\"
NOTIFY_EXPLORE       \"Keep exploring!\"
NOTIFY_LATE_EXPLORE  \"Head for the stairs!\"
NOTIFY_DOWNSTAIRS    \"Click to go downstairs\"
NOTIFY_PICK_SPACE1   \"Select a space for your\"
NOTIFY_PICK_SPACE2   \"spell\"
NOTIFY_PICK_TARGET1  \"Select a target for your\"
NOTIFY_PICK_TARGET2  \"spell\"
NOTIFY_GET_FIRST     \"I've been wanting one of these.\"
NOTIFY_GET_DUPLICATE \"I already have one just like this.\"
NOTIFY_GET_SELLOLD1  \"I will sell my old\"
NOTIFY_GET_SELLOLD2  \" now.\"
NOTIFY_GET_SELLNEW1  \"Ha! Not half as good as my\"
NOTIFY_GET_SELLNEW2  \".\"
NOTIFY_GET_STASHOLD1 \"I'll keep my old\"
NOTIFY_GET_STASHOLD2 \" in my bag.\"
NOTIFY_GET_REDUNDANT \"I've got better in my bag.\"
NOTIFY_GET_STASHNEW1 \"I'll put this\"
NOTIFY_GET_STASHNEW2 \" in my bag.\"
NOTIFY_GET_STASHSPELL1 \"I'll put this\"
NOTIFY_GET_STASHSPELL2 \" spell in my bag.\"
NOTIFY_EMPTYCELL     \"Use an empty cell to swap items!\"

LOG_YOU_HIT          \"You hit\"
LOG_HIT_YOU          \"Hit you\"
LOG_YOU_KILL         \"You kill\"
LOG_KILLS_YOU        \"kills you\"
LOG_YOU_MISS         \"You miss\"
LOG_MISS_YOU         \"Misses you\"
LOG_EFFECT           \"Applied special effect:\"
LOG_XP1              \"gained\"
LOG_XP2              \"xp\"
LOG_EXPIRED_TIMER    \"removed expired timer:\"
LOG_POTION           \"Using potion\"

; UI - Menu
MENU_NEW_GAME        \"New Game\"
MENU_RESUME_GAME     \"Resume Game\"
MENU_CREDITS         \"Credits\"
MENU_QUIT            \"Quit\"
MENU_MUSIC           \"Music\"
MENU_SOUND           \"Sound\"
MENU_COPYRIGHT       \"Copyright 2011\"
MENU_PORTEDBY        \"Ported by\"
MENU_VERSION         \"Version\"
MENU_STANDALONE      \"Get stand-alone version at\"

MENU_HIGHSCORES      \"Highscores\"

MENU_CREATECHARACTER \"Create Character\"
MENU_START           \"Start\"
MENU_MENU            \"Menu\"
MENU_MAIN_MENU       \"Main Menu\"
MENU_HELP            \"Help\"
MENU_GAME_OVER       \"Game over\"

PRELOADER1           \"Hi there!  It looks like somebody copied this game without my permission.  Just click anywhere, or copy-paste this URL into your browser.\n\n\"
PRELOADER2           \"\n\nto play the game at my site.  Thanks, and have fun!\"

DEMO_OVER            \"Demo Over!\"
DEMO_OVER_MORE       \"Want more?\"";		embedFile = StatsFile.loadFromString( "strings.txt", embedText );	}}