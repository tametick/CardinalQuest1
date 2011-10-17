// THIS FILE IS AUTOMATICALLY GENERATED FROM TEXT FILES IN /BIN. DO NOT MODIFY
Field String Name
Field String Slot
Field String Buff1
Field Int Buff1Val
Field String Buff2
Field Int Buff2Val

; ID            Name                         Slot    Buff1   V1 Buff2   V2 
BOOTS           [Boots of Escape]            SHOES   speed    1
WINGED_SANDLES  [Hermes' Sandals]            SHOES   speed    2
TUNDRA_BOOTS    [Tundra Lizard Boots]        SHOES   speed    2 defense  1

; ID            Name                         Slot    Buff1   V1 Buff2   V2 
LEATHER_ARMOR   [Leather Armor]              ARMOR   defense  1
BRESTPLATE      [Breastplate]                ARMOR   defense  2
FULL_PLATE_MAIL [Full Plate Armor]           ARMOR   defense  3
CLOAK           [Rogues' Cloak of Swiftness] ARMOR   defense  2 speed    2

; ID            Name                         Slot    Buff1   V1 Buff2   V2 
RING            [Ring of Wisdom]             JEWELRY spirit   1
AMULET          [Amulet of Enlightenment]    JEWELRY spirit   2
GEMMED_AMULET   [Supernatural Amulet]        JEWELRY spirit   2 defense  2
GEMMED_RING     [Ring of Rubies]             JEWELRY life     3 spirit   2

; ID            Name                         Slot    Buff1   V1 Buff2   V2 
CAP             [Cap of Endurance]           HAT     life     1
HELM            [Helm of Hardiness]          HAT     life     2
GOLDEN_HELM     [King's Golden Helm]         HAT     life     2 defense  3
FULL_HELM       [Full Helmet of Vitality]    HAT     life     4

; ID            Name                         Slot    Buff1   V1 Buff2   V2 
GLOVE           [Goves of Dexterity]         GLOVES  attack   1
BRACELET        [Achilles' Bracer]           GLOVES  attack   2
GAUNTLET        [Gauntlets of Sturdiness]    GLOVES  attack   2 defense  2
";
Field String Name
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

; ID                     Name               Atk Def Spd Spr V- V+ D- D+  XP Spell1           Spell2
BANDIT_LONG_SWORDS       [Captain]            2   2   4  30  2  3  1  1   5
BANDIT_SHORT_SWORDS      [Bandit]             2   2   2  30  4  6  1  1   5
BANDIT_SINGLE_LONG_SWORD [Bandit]             2   2   3  30  2  3  1  1   5
BANDIT_KNIVES            [Bandit]             2   2   3  30  2  3  1  1   5

; ID                     Name               Atk Def Spd Spr V- V+ D- D+  XP Spell1           Spell2
KOBOLD_SPEAR             [Spearkobold]        4   3   3   3  1  4  2  4  10
KOBOLD_KNIVES            [Kobold]             4   3   3   3  1  4  1  3  10
KOBOLD_MAGE              [Kobold Trickster]   4   3   3  12  1  4  1  3  10 TELEPORT

; ID                     Name               Atk Def Spd Spr V- V+ D- D+  XP Spell1           Spell2
SUCCUBUS                 [Succubus]           3   4   4   4  2  8  2  4  25 ENFEEBLE_MONSTER
SUCCUBUS_STAFF           [Succubus]           3   4   4   4  2  8  2  4  25 ENFEEBLE_MONSTER
SUCCUBUS_WHIP            [Dominatrix]         3   4   6   2  2  8  2  4  25 ENFEEBLE_MONSTER
SUCCUBUS_SCEPTER         [Succubus]           3   4   4   8  2  8  2  4  25 ENFEEBLE_MONSTER SHADOW_WALK

; ID                     Name               Atk Def Spd Spr V- V+ D- D+  XP Spell1           Spell2
SPIDER_YELLOW            [Spider]             5   3   3   4  3 12  2  6  50 FREEZE
SPIDER_RED               [Black Widow]        5   1   4   7 10 19  2  6  50 FREEZE
SPIDER_GRAY              [Wolf Spider]        5   3   6   1  3 12  2  6  50 FREEZE
SPIDER_GREEN             [Spider]             5   3   3   4  3 12  2  6  50 FREEZE

; ID                     Name               Atk Def Spd Spr V- V+ D- D+  XP Spell1           Spell2
APE_BLUE                 [Ape]                6   6   6   3  4 16  4  6 125
APE_BLACK                [Ape]                6   6   6   3  4 16  4  6 125
APE_RED                  [Demon Ape]          7   8   3   3  8 20  4  6 125
APE_WHITE                [Ape]                6   6   6   3  4 16  4  6 125

; ID                     Name               Atk Def Spd Spr V- V+ D- D+  XP Spell1           Spell2
ELEMENTAL_GREEN          [Air Elemental]      4   4   8   6  8 26  4  8 275 FIREBALL         SHADOW_WALK
ELEMENTAL_WHITE          [Nature Elemental]   4   4   4   6 14 32  4  8 275 FIREBALL         STONE_SKIN
ELEMENTAL_RED            [Sorcery Elemental]  4   4   4  18  8 26  4  8 275 MAGIC_MIRROR     TELEPORT
ELEMENTAL_BLUE           [Chaos Elemental]    4   4   4  12  8 26  4  8 275 FIREBALL

; ID                     Name               Atk Def Spd Spr V- V+ D- D+  XP Spell1           Spell2
WEREWOLF_GRAY            [Werewolf]           5   5   8   4  8 32  4  8 500 HASTE
WEREWOLF_BLUE            [Werewolf]           5   5   8   4  8 32  4  8 500 HASTE
WEREWOLF_PURPLE          [Werewolf]           5   5   8   4  8 32  4  8 500 HASTE

; ID                     Name               Atk Def Spd Spr V- V+ D- D+  XP Spell1           Spell2
MINOTAUER                [Minotaur]           7   4   7   4 24 48 12 32 950 BERSERK
MINOTAUER_AXE            [Minotaur]           7   4   7   4 24 48 12 32 950 BERSERK
MINOTAUER_SWORD          [Minotaur]           7   4   7   4 24 48 12 32 950 BERSERK";
Field String Name
Field Int Duration
Field String Buff
Field Int BuffVal
Field String Effect
Field String EffectVal

; ID          Name                     Duration Buff      BV Effect             EV
GREEN_POTION  [Elixir of the Hawk]     120      attack     3
PURPLE_POTION [Elixir of the Lion]     120      []         0 [damage multipler] 2
BLUE_POTION   [Elixir of the Elephant] 120      defense    3
YELLOW_POTION [Coca-leaf Cocktail]     120      speed      3
RED_POTION    [Healiong Potion]        0        []         0 heal               full
";
Field String Name
Field String Slot
Field Int DamageMin
Field Int DamageMax
Field String Buff1
Field Int Buff1Val
Field String Buff2
Field Int Buff2Val

; ID            Name                         Slot    Dmg1 Dmg2 Buff1   V1 Buff2   V2 
DAGGER          [Dagger]                     WEAPON     1    2
STAFF           [Staff]                      WEAPON     1    3
SHORT_SWORD     [Short Sword]                WEAPON     1    3
LONG_SWORD      [Long Sword]                 WEAPON     2    4
AXE             [Axe]                        WEAPON     4    6
BATTLE_AXE      [Hardened Battle Axe]        WEAPON     5   12 speed   -2
MACE            [Beastly Mace]               WEAPON     4   11
CLAYMORE        [Broad Claymore]             WEAPON     6   10 speed   -1
BROAD_SWORD     [Twin Bladed Katana]         WEAPON     5   12 defense -2 speed    2
";