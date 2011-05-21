package playtomic;

import cq.CqActor;

import data.Registery;

import playtomic.Playtomic;
import playtomic.base.Log;

class PtPlayer 
{
		
	static var attacksDodged:Int;
	static var attacksMissed:Int;
	static var attacksSuccessful:Int;
	static var beenHit:Int;
	static var enemiesKilled:Int;
	
	public static function startLevel():Void {
		if (!Playtomic.isEnabled())
			return;
		beenHit = enemiesKilled = 0;
		attacksDodged = attacksMissed = attacksSuccessful = 0;
	}
	
	public static function finishLevel():Void {
		if (!Playtomic.isEnabled())
			return;
		Log.LevelRangedMetric("Attacks Dodged", Registery.level.index, attacksDodged);
		Log.LevelRangedMetric("Attacks Missed", Registery.level.index, attacksMissed);
		Log.LevelRangedMetric("Attacks Successful", Registery.level.index, attacksSuccessful);
		Log.LevelRangedMetric("Player Hit", Registery.level.index, beenHit);
		Log.LevelRangedMetric("Kills", Registery.level.index, enemiesKilled);
	}
	
	public static function isHit():Void {
		if (!Playtomic.isEnabled())
			return;
		beenHit++;
	}
	public static function hits():Void {
		if (!Playtomic.isEnabled())
			return;
		attacksSuccessful++;
	}
	public static function dodges():Void {
		if (!Playtomic.isEnabled())
			return;
		attacksDodged++;
	}
	public static function kills():Void {
		if (!Playtomic.isEnabled())
			return;
		enemiesKilled++;
	}
	public static function misses():Void {
		if (!Playtomic.isEnabled())
			return;
		attacksMissed++;
	}
	
	public static function dies():Void {
		if (!Playtomic.isEnabled())
			return;
		Log.LevelCounterMetric("Player Died", Registery.level.index);
		Log.LevelCounterMetric("Player Died U", Registery.level.index, true);	
	}
	public static function ClassSelected(Class:CqClass):Void {
		if (!Playtomic.isEnabled())
			return;
		Log.CustomMetric(Type.enumConstructor(Class).toLowerCase(), "Class Selected");
	}
}

