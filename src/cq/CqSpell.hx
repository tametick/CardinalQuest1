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
