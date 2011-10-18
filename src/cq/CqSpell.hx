package cq;

import cq.ui.CqSpellButton;
import data.StatsFile;
import haxel.HxlUtil;
import playtomic.base.Data;

import cq.CqItem;
import cq.CqResources;

import data.Resources;

class CqSpellFactory {
	public static var remainingSpells:Array<String>;
	
	public static function resetRemainingSpells()
	{
		if (CqSpellFactory.remainingSpells != null)
			CqSpellFactory.remainingSpells.splice(0, CqSpellFactory.remainingSpells.length);
		else 
			CqSpellFactory.remainingSpells = new Array();
			
		var spellsFile:StatsFile = Resources.statsFiles.get( "spells.txt" );
		for ( s in spellsFile ) {
			remainingSpells.push( s.getField( "ID" ) );
		}
	}
	
	public static function newRandomSpell(X:Float, Y:Float) {
		if (remainingSpells.length < 1)
			resetRemainingSpells();
		
		var newSpellID:String = HxlUtil.getRandomElement(remainingSpells);
		
		// uncomment if you want every spell to only be given once
		remainingSpells.remove(newSpellID);
		
		return newSpell(X, Y, newSpellID);
	}
	
	public static function getSpellDamageByLevel(_id:String, _level:Int):Range {
		var spellDamageFile:StatsFile = Resources.statsFiles.get( "spellDamage.txt" );
		var dmg:Range = new Range(0, 0);
		var bestLevel:Int = 0;
		
		for ( sd in spellDamageFile ) {
			if ( sd.getField( "ID" ) == _id ) {
				var level:Int = sd.getField( "Level" );
				if ( level > bestLevel && level <= _level ) {
					dmg.start = sd.getField( "DamageMin" );
					dmg.end = sd.getField( "DamageMax" );
					bestLevel = level;
				}
			}
		}
		
		return dmg;
	}
	
	public static function newSpell(X:Float, Y:Float, id:String):CqSpell {
		var spell:CqSpell = null;
		
		var spellsFile:StatsFile = Resources.statsFiles.get( "spells.txt" );
		var entry:StatsFileEntry = spellsFile.getEntry( "ID", id );
		
		if ( entry != null ) {
			spell = new CqSpell(X, Y, id, entry.getField( "Sprite" ) );
			
			spell.name = entry.getField( "Name" );

			switch ( entry.getField( "Target" ) ) {
			case 1: spell.targetsOther = true;
			case 2: spell.targetsEmptyTile = true;
			default:
			}
			
			spell.duration = entry.getField( "Duration" );
			spell.stat = entry.getField( "Stat" );
			spell.statPointsRequired = entry.getField( "StatPoints" );
			
			if ( entry.getField( "Buff1" ) != "" ) {
				spell.buffs.set( entry.getField( "Buff1" ), entry.getField( "Buff1Val" ) );
			}
			
			if ( entry.getField( "Buff2" ) != "" ) {
				spell.buffs.set( entry.getField( "Buff2" ), entry.getField( "Buff2Val" ) );
			}

			if ( entry.getField( "Effect" ) != "" ) {
				spell.specialEffects.add(new CqSpecialEffectValue( entry.getField( "Effect" ), entry.getField( "EffectVal" ) ));
			}
		}
/*
		switch(type) {
			case FREEZE:
				spell.targetsOther = true;
				spell.duration = 120;
				spell.buffs.set("speed", -3);
				spell.spiritPointsRequired = 1440;
			case FIREBALL:
				spell.targetsOther = true;
				//gets modified to character level when spell is casted
				spell.damage = new Range(1, 6);
				spell.spiritPointsRequired = 720;
			case BERSERK:
				spell.duration = 60;
				spell.buffs.set("attack", 3);
				spell.buffs.set("speed", 3);
				spell.spiritPointsRequired = 720;
			case ENFEEBLE_MONSTER:
				spell.targetsOther = true;
				spell.duration = 120;
				spell.buffs.set("attack", -3);
				spell.spiritPointsRequired = 720;
			case BLESS_WEAPON:
				spell.duration = 120;
				spell.buffs.set("attack", 3);
				spell.spiritPointsRequired = 720;
			case HASTE:
				spell.duration = 120;
				spell.buffs.set("speed", 3);
				spell.spiritPointsRequired = 720;
			case SHADOW_WALK:
				spell.duration = 120;
				spell.specialEffects.add(new CqSpecialEffectValue("invisible"));
				spell.spiritPointsRequired = 720;
			case CHARM_MONSTER:
				spell.duration = 120;
				spell.targetsOther = true;
				spell.specialEffects.add(new CqSpecialEffectValue("charm"));
				spell.spiritPointsRequired = 1440;
			case POLYMORPH:
				spell.duration = 180;
				spell.targetsOther = true;
				spell.specialEffects.add(new CqSpecialEffectValue("polymorph", "true"));
				spell.spiritPointsRequired = 2160;
			case SLEEP:
				spell.duration = 90;
				spell.targetsOther = true;
				spell.specialEffects.add(new CqSpecialEffectValue("sleep", 0));
				spell.spiritPointsRequired = 1440;
			case FEAR:
				spell.duration = 180;
				spell.targetsOther = true;
				spell.specialEffects.add(new CqSpecialEffectValue("fear"));
				spell.spiritPointsRequired = 960;
			case MAGIC_MIRROR: 
				spell.duration = 180; // used to last 360
				spell.targetsEmptyTile = true;
				spell.specialEffects.add(new CqSpecialEffectValue("magic_mirror"));
				spell.spiritPointsRequired = 720*2;
			case STONE_SKIN: 
				spell.duration = 120;
				spell.buffs.set("defense", 5);
				spell.buffs.set("speed", -1);
				spell.spiritPointsRequired = 720;			
			case BLINK:
				spell.specialEffects.add(new CqSpecialEffectValue("blink"));
				spell.spiritPointsRequired = 720;
			case MAGIC_ARMOR: 
				spell.duration = 120;
				spell.buffs.set("defense", 3);
				spell.spiritPointsRequired = 720;
			case TELEPORT:
				spell.targetsEmptyTile = true;
				spell.specialEffects.add(new CqSpecialEffectValue("teleport"));
				spell.spiritPointsRequired = 720*2;
			case REVEAL_MAP:
				spell.specialEffects.add(new CqSpecialEffectValue("reveal"));
				spell.spiritPointsRequired = 7200;
			case HEAL:
				spell.specialEffects.add(new CqSpecialEffectValue("heal","full"));
				spell.spiritPointsRequired = 720*4;
		}
		*/
		return spell;
	}
}

class CqSpell extends CqItem {
	public var targetsOther:Bool;
	public var targetsEmptyTile:Bool;
	public var id:String;
	public var stat:String;
	public var statPoints:Int;
	public var statPointsRequired:Int;
	public function new(X:Float, Y:Float, _id:String, _sprite:String) {
		super(X, Y, _sprite);
		id = _id;
		equipSlot = SPELL;
		visible = false;
		stat = "spirit";
		statPoints = 0;
	}
}
