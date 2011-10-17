package cq;
import cq.CqActor;
import cq.CqResources;
import cq.CqItem;
import cq.CqSpell;
import cq.CqWorld;
import cq.GameUI;
import cq.ui.CqVitalBar;
import cq.effects.CqEffectSpell;
import data.StatsFile;

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
		
		var mobsFile:StatsFile = Resources.statsFiles.get( "mobs.txt" );
		var entry:StatsFileEntry = mobsFile.getEntry( "ID", mob.type + "" );
		
		if ( entry != null ) {
			mob.name = mobsFile.getEntryField( entry, "Name" );
			mob.attack = mobsFile.getEntryField( entry, "Attack" );
			mob.defense = mobsFile.getEntryField( entry, "Defense" );
			mob.speed = mobsFile.getEntryField( entry, "Speed" );
			mob.spirit = mobsFile.getEntryField( entry, "Spirit" );
			mob.vitality = HxlUtil.randomIntInRange( mobsFile.getEntryField( entry, "VitalityMin" ),
													 mobsFile.getEntryField( entry, "VitalityMax" ) );
			mob.damage = new Range( mobsFile.getEntryField( entry, "DamageMin" ),
									mobsFile.getEntryField( entry, "DamageMax" ) );
			mob.xpValue = mobsFile.getEntryField( entry, "XP" );
			
			var spell1:String = mobsFile.getEntryField( entry, "Spell1" );
			if ( spell1 != "" ) {
				mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, Type.createEnum( CqSpellType, spell1 ) ) );
			}
			
			var spell2:String = mobsFile.getEntryField( entry, "Spell2" );
			if ( spell2 != "" ) {
				mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, Type.createEnum( CqSpellType, spell2 ) ) );
			}
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
