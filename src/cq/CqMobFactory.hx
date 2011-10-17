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
				weaktype = "Bandit";
				strongtype = "Bandit";
			case 2:
				weaktype = "Bandit";
				strongtype = "Kobold";
			case 3:
				weaktype = "Kobold";
				strongtype = "Succubus";
			case 4:
				weaktype = "Succubus";
				strongtype = "Spider";
			case 5:
				weaktype = "Spider";
				strongtype = "Ape";
			case 6:
				weaktype = "Ape";
				strongtype = "Elemental";
			case 7:
				weaktype = "Elemental";
				strongtype = "Werewolf";
			case 8, 9:// for "out of depth" enemies in the 8th level 
				weaktype = "Werewolf";
				strongtype = "Minotaur";
			case 99,100,101:
				//ending boss
				weaktype = "Minotaur";
				strongtype = "Minotaur";
				specialname = "Asterion";
			default:
				weaktype = "Kobold";
				strongtype = "Kobold";
		}

		typeName = if (Math.random() < Configuration.strongerEnemyChance) weaktype else strongtype;
		
		// Search through mobs.txt for mobs of the right type and pick one.
		var mobsFile:StatsFile = Resources.statsFiles.get( "mobs.txt" );
		
		var idealMob:StatsFileEntry = null;
		var weightSoFar:Int = 0;
		for ( m in mobsFile ) {
			if ( m.getField( "Class" ) == typeName ) {
				var weight = m.getField( "Weight" );
				if ( Math.random() > (weightSoFar / (weightSoFar + weight)) ) {
					idealMob = m;
				}
				weightSoFar += weight;
			}
		}
		
		var entry:StatsFileEntry = idealMob;
		
		if ( entry != null ) {
			mob = new CqMob(X, Y, entry.getField( "Sprite" ) );
			
			mob.name = entry.getField( "Name" );
			mob.attack = entry.getField( "Attack" );
			mob.defense = entry.getField( "Defense" );
			mob.speed = entry.getField( "Speed" );
			mob.spirit = entry.getField( "Spirit" );
			mob.vitality = HxlUtil.randomIntInRange( entry.getField( "VitalityMin" ),
													 entry.getField( "VitalityMax" ) );
			mob.damage = new Range( entry.getField( "DamageMin" ),
									entry.getField( "DamageMax" ) );
			mob.xpValue = entry.getField( "XP" );
			
			var spell1:String = entry.getField( "Spell1" );
			if ( spell1 != "" ) {
				mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, Type.createEnum( CqSpellType, spell1 ) ) );
			}
			
			var spell2:String = entry.getField( "Spell2" );
			if ( spell2 != "" ) {
				mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, Type.createEnum( CqSpellType, spell2 ) ) );
			}
		}
		else
		{
			throw "Mob type \"" + typeName + "\" not found in mobs.txt.";
		}
		
		mob.hp = mob.maxHp = mob.vitality;
		
		if (specialname != null) mob.name = specialname;
		
		return mob;
	}
}