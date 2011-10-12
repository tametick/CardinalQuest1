package cq;
import cq.CqActor;
import cq.CqResources;
import cq.CqItem;
import cq.CqSpell;
import cq.CqWorld;
import cq.GameUI;
import cq.ui.CqVitalBar;
import cq.effects.CqEffectSpell;

import data.Resources;
import data.Configuration;

import haxel.HxlUtil;


class CqMobFactory {	
	static var inited = false;
	
	public static function initDescriptions() {
		if (inited)
			return;
		
		if(Resources.descriptions==null)
			Resources.descriptions = new Hash<String>();
		
		// this is a very questionable place for these descriptions to come up
		Resources.descriptions.set("Fighter", "A mighty warrior of unparalleled strength and vigor, honorable in battle, high master of hack-n-slash melee.\n\nThe best choice for new players.");
		Resources.descriptions.set("Wizard", "A wise sage, knower of secrets, worker of miracles, master of the arcane arts, maker of satisfactory mixed drinks.\n\nCan cast spells rapidly - use his mystic powers as often as possible.");
		Resources.descriptions.set("Thief", "A cunning and agile rogue whose one moral credo is this: Always get out alive.\n\nThe most challenging character - use his speed and skills to avoid taking damage." );
		
		inited = true;
	}
	
	public static function newMobFromLevel(X:Float, Y:Float, level:Int, ?cloneOf:CqActor = null):CqMob {
		initDescriptions();
		var mob;
		var typeName:String = "";
		
		if (cloneOf != null) {
			if (Std.is(cloneOf, CqPlayer)) {
				// pretend the player is a bandit, just for mirror bookkeeping
				mob = new CqMob(X, Y, HxlUtil.getRandomElement(SpriteMonsters.bandits), true);
			} else {
				mob = new CqMob(X, Y, cast(cloneOf, CqMob).typeName, false);
			}
			mob.attack = cloneOf.attack;
			mob.defense = cloneOf.defense;
			mob.speed = cloneOf.speed;
			mob.spirit = cloneOf.spirit;
			mob.hp = mob.maxHp = mob.vitality = cloneOf.maxHp;
			mob.damage = cloneOf.damage;
			mob.xpValue = 0;
			mob.name = "Mirror";
			return mob;
		}
		
		var specialname:String = null;
		var weaktype, strongtype;
		
		switch(level+1) {
			case 1:
				weaktype = SpriteMonsters.bandits;
				strongtype = SpriteMonsters.bandits;
			case 2:
				weaktype = SpriteMonsters.bandits;
				strongtype = SpriteMonsters.kobolds;
			case 3:
				weaktype = SpriteMonsters.kobolds;
				strongtype = SpriteMonsters.succubi;
			case 4:
				weaktype = SpriteMonsters.succubi;
				strongtype = SpriteMonsters.spiders;
			case 5:
				weaktype = SpriteMonsters.spiders;
				strongtype = SpriteMonsters.apes;
			case 6:
				weaktype = SpriteMonsters.apes;
				strongtype = SpriteMonsters.elementeals;
			case 7:
				weaktype = SpriteMonsters.elementeals;
				strongtype = SpriteMonsters.werewolves;
			case 8, 9:// for "out of depth" enemies in the 8th level 
				weaktype = SpriteMonsters.werewolves;
				strongtype = SpriteMonsters.minotauers;
			case 99,100,101:
				//ending boss
				weaktype = SpriteMonsters.minotauers;
				strongtype = SpriteMonsters.minotauers;
				specialname = "Asterion";
			default:
				weaktype = SpriteMonsters.kobolds;
				strongtype = SpriteMonsters.kobolds;
		}

		typeName = HxlUtil.getRandomElement(if (Math.random() < Configuration.strongerEnemyChance) weaktype else strongtype);
		mob = new CqMob(X, Y, typeName.toLowerCase());
		
		switch(mob.type) {
			case BANDIT_LONG_SWORDS, BANDIT_SHORT_SWORDS, BANDIT_SINGLE_LONG_SWORD, BANDIT_KNIVES:
				mob.name = "Bandit";
				mob.attack = 2;
				mob.defense = 2;
				mob.speed = 3;
				mob.spirit = 30;
				mob.vitality = HxlUtil.randomIntInRange(2, 3);
				mob.damage = new Range(1, 1);
				mob.xpValue = 5;
				
				if (mob.type == BANDIT_LONG_SWORDS) {
					mob.name = "Captain";
					mob.speed++;
				}
				
				if (mob.type == BANDIT_SHORT_SWORDS) {
					// short chubby guy
					mob.speed--;
					mob.vitality *= 2;
				}
			case KOBOLD_SPEAR, KOBOLD_KNIVES, KOBOLD_MAGE:
				mob.name = "Kobold";
				mob.attack = 4;
				mob.defense = 3;
				mob.speed = 3;
				mob.spirit = 3;
				mob.hp = mob.maxHp = mob.vitality = HxlUtil.randomIntInRange(1,4);
				mob.damage = new Range(1, 3);
				mob.xpValue = 10;
				if (mob.type == KOBOLD_SPEAR) {
					mob.damage = new Range(2, 4);
				}
				if (mob.type == KOBOLD_MAGE) {
					mob.spirit = 12;
					mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, CqSpellType.TELEPORT));
					mob.name = "Kobold Trickster";
				}
			case SUCCUBUS, SUCCUBUS_STAFF, SUCCUBUS_WHIP, SUCCUBUS_SCEPTER:
				mob.name = "Succubus";
				mob.attack = 3;
				mob.defense = 4;
				mob.speed = 4;
				mob.spirit = 4;
				mob.vitality = HxlUtil.randomIntInRange(2,8);
				mob.damage = new Range(2, 4);
				mob.xpValue = 25;
				mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, CqSpellType.ENFEEBLE_MONSTER));
				
				if (mob.type == SUCCUBUS_WHIP) {
					mob.speed += 2;
					mob.spirit -= 2;
					mob.name = "Dominatrix";
				}
				if (mob.type == SUCCUBUS_SCEPTER) {
					mob.spirit *= 2;
					mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, CqSpellType.SHADOW_WALK));
					mob.name = "Enchantress";
				}
			case SPIDER_YELLOW, SPIDER_RED, SPIDER_GRAY, SPIDER_GREEN:
				mob.name = "Spider";
				mob.attack = 5;
				mob.defense = 3;
				mob.speed = 3;
				mob.spirit = 4;
				mob.vitality = HxlUtil.randomIntInRange(3,12);
				mob.damage = new Range(2, 6);
				mob.xpValue = 50;
				mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, CqSpellType.FREEZE));
				if (mob.type == SPIDER_RED) {
					mob.name = "Black Widow";
					mob.vitality += 7;
					mob.spirit += 3;
					mob.speed++;
					mob.defense = 1;
				}
				if (mob.type == SPIDER_GRAY) {
					mob.name = "Wolf Spider";
					mob.speed *= 2;
					mob.spirit = 1;
				}
			case APE_BLUE, APE_BLACK, APE_RED, APE_WHITE:
				mob.name = "Ape";
				mob.attack = 6;
				mob.defense = 6;
				mob.speed = 6;
				mob.spirit = 3;
				mob.vitality = HxlUtil.randomIntInRange(4,16);
				mob.damage = new Range(4, 6);
				mob.xpValue = 125;
			case ELEMENTAL_GREEN, ELEMENTAL_WHITE, ELEMENTAL_RED, ELEMENTAL_BLUE:
				mob.name = "Elemental";
				mob.attack = 4;
				mob.defense = 4;
				mob.speed = 4;
				mob.spirit = 6;
				mob.vitality = HxlUtil.randomIntInRange(8,26);
				mob.damage = new Range(4, 8);
				mob.xpValue = 275;
				mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, CqSpellType.FIREBALL));
				
				if (mob.type == ELEMENTAL_WHITE) { // really green
					mob.name = "Nature " + mob.name;
					mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, CqSpellType.STONE_SKIN));
					mob.vitality += 6;
				}
				if (mob.type == ELEMENTAL_GREEN) { // really purple or something
					mob.name = "Sorcery " + mob.name;
					mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, CqSpellType.MAGIC_MIRROR));
					mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, CqSpellType.TELEPORT));
				}
				if (mob.type == ELEMENTAL_BLUE) { // really red
					mob.name = "Chaos " + mob.name;
					mob.spirit *= 2; // cast xball much more often
				}
				if (mob.type == ELEMENTAL_RED) { // really blue or something?
					mob.name = "Air " + mob.name;
					mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, CqSpellType.SHADOW_WALK));
					mob.speed *= 2; // faster
				}
			case WEREWOLF_GRAY, WEREWOLF_BLUE, WEREWOLF_PURPLE:
				mob.name = "Werewolf";
				mob.attack = 5;
				mob.defense = 5;
				mob.speed = 8;
				mob.spirit = 4;
				mob.vitality = HxlUtil.randomIntInRange(8,32);
				mob.damage = new Range(4,8);
				mob.xpValue = 500;
				mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, CqSpellType.HASTE));
			case MINOTAUER, MINOTAUER_AXE, MINOTAUER_SWORD:
				mob.name = "Minotaur";
				mob.attack = 7;
				mob.defense = 4;
				mob.speed = 7;
				mob.spirit = 4;
				mob.vitality = HxlUtil.randomIntInRange(24,48);
				mob.damage = new Range(12, 32);
				mob.xpValue = 950;
				mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, CqSpellType.BERSERK));
		}
		
		mob.hp = mob.maxHp = mob.vitality;
		
		if (specialname != null) mob.name = specialname;
		
		return mob;
	}
}

enum CqMobType {
	BANDIT_LONG_SWORDS; BANDIT_SHORT_SWORDS; BANDIT_SINGLE_LONG_SWORD; BANDIT_KNIVES;
	KOBOLD_SPEAR; KOBOLD_KNIVES; KOBOLD_MAGE;
	SUCCUBUS; SUCCUBUS_STAFF; SUCCUBUS_WHIP; SUCCUBUS_SCEPTER;
	SPIDER_YELLOW; SPIDER_RED; SPIDER_GRAY; SPIDER_GREEN;
	APE_BLUE; APE_BLACK; APE_RED; APE_WHITE;
	ELEMENTAL_GREEN; ELEMENTAL_WHITE; ELEMENTAL_RED; ELEMENTAL_BLUE;
	WEREWOLF_GRAY; WEREWOLF_BLUE; WEREWOLF_PURPLE;
	MINOTAUER; MINOTAUER_AXE; MINOTAUER_SWORD;	
}
