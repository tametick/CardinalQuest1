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
	public static function newMobFromLevel(X:Float, Y:Float, level:Int, ?cloneOf:CqActor = null):CqMob {
		var mob;
		var typeName:String = "";
		
		if (cloneOf != null) {
			if (Std.is(cloneOf, CqPlayer)) {
				// pretend the player is a bandit, just for mirror bookkeeping
				mob = new CqMob(X, Y, "bandit_long_swords", true);
			} else {
				mob = new CqMob(X, Y, cast(cloneOf, CqMob).typeName, false);
			}
			mob.attack = Math.ceil(cloneOf.attack * .4 * (1 + Math.random())); // between 40% and 80% of your attack
			mob.defense = cloneOf.defense;
			mob.speed = Math.ceil(cloneOf.speed * .75 * (1 + Math.random())); // between 75% and 150% of your speed
			mob.spirit = cloneOf.spirit;
			mob.hp = mob.maxHp = mob.vitality = Math.ceil(cloneOf.maxHp * .3 * (1 + Math.random())); // between 30% and 60% of your health
			mob.damage = cloneOf.damage;
			mob.xpValue = 0;
			mob.name = "Mirror";
			return mob;
		}
		
		var specialname:String = null;
		var weaktype, strongtype;
		
		if (Math.random() < Configuration.weakEnemyChance) {
			level = 1 + Std.int( Math.random() * (level-1) );
		}
		
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
		
		var entry:StatsFileEntry = null;
		var weightSoFar:Int = 0;
		for ( m in mobsFile ) {
			if ( m.getField( "Class" ) == typeName ) {
				var weight = m.getField( "Weight" );
				if ( Math.random() > (weightSoFar / (weightSoFar + weight)) ) {
					entry = m;
				}
				weightSoFar += weight;
			}
		}
		
		if ( entry != null ) {
			mob = newMobFromEntry( X, Y, entry );
		}
		else
		{
			throw "Mob type \"" + typeName + "\" not found in mobs.txt.";
		}
		
		mob.hp = mob.maxHp = mob.vitality;
		
		if (specialname != null) mob.name = specialname;
		
		return mob;
	}
	
	private static function newMobFromEntry( X:Float, Y:Float, entry:StatsFileEntry ) : CqMob {
		var mob:CqMob = new CqMob(X, Y, entry.getField( "Sprite" ) );
		
		mob.name = Resources.getString( entry.getField( "NameID" ) );
		mob.attack = entry.getField( "Attack" );
		mob.defense = entry.getField( "Defense" );
		mob.speed = entry.getField( "Speed" );
		mob.spirit = entry.getField( "Spirit" );
		mob.vitality = HxlUtil.randomIntInRange( entry.getField( "VitalityMin" ),
												 entry.getField( "VitalityMax" ) );
		
		mob.damage = new Range(
			entry.getField("DamageMin"),
			entry.getField("DamageMax")
		);
					
		mob.xpValue = entry.getField( "XP" );
		
		var spell1:String = entry.getField( "Spell1" );
		if ( spell1 != "" ) {
			mob.bag.grantIntrinsic(CqSpellFactory.newSpell( -1, -1, spell1 ) );
		}
		
		var spell2:String = entry.getField( "Spell2" );
		if ( spell2 != "" ) {
			mob.bag.grantIntrinsic(CqSpellFactory.newSpell( -1, -1, spell2 ) );
		}
		
		return mob;
	}
	
	public static function newMobFromTypename( X:Float, Y:Float, Sprite:String ) : CqMob {
		var mobsFile:StatsFile = Resources.statsFiles.get( "mobs.txt" );
		
		var entry:StatsFileEntry = null;
		var weightSoFar:Int = 0;
		for ( m in mobsFile ) {
			if ( m.getField( "Sprite" ) == Sprite ) {
				entry = m;
			}
		}
		
		if ( entry == null ) {
			return null;
		}
		
		return newMobFromEntry( X, Y, entry );
	}
}