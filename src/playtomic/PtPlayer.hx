package playtomic;

import cq.CqActor;

import data.Registery;

import playtomic.base.Log;

class PtPlayer 
{
		
	static var attacksDodged:Int;
	static var attacksMissed:Int;
	static var attacksSuccessful:Int;
	static var beenHit:Int;
	static var enemiesKilled:Int;
	
	public static function startLevel():Void {
		beenHit = enemiesKilled = 0;
		attacksDodged = attacksMissed = attacksSuccessful = 0;
	}
	
	public static function finishLevel():Void {
		Log.LevelRangedMetric("Attacks Dodged", Registery.level.index, attacksDodged);
		Log.LevelRangedMetric("Attacks Missed", Registery.level.index, attacksMissed);
		Log.LevelRangedMetric("Attacks Successful", Registery.level.index, attacksSuccessful);
		Log.LevelRangedMetric("Player Hit", Registery.level.index, beenHit);
		Log.LevelRangedMetric("Kills", Registery.level.index, enemiesKilled);
	}
	
	public static function isHit():Void {
		beenHit++;
	}
	public static function hits():Void {
		attacksSuccessful++;
	}
	public static function dodges():Void {
		attacksDodged++;
	}
	public static function kills():Void {
		enemiesKilled++;
	}
	public static function misses():Void {
		attacksMissed++;
	}
	
	public static function dies():Void {
		Log.LevelCounterMetric("Player Died", Registery.level.index);
		Log.LevelCounterMetric("Player Died U", Registery.level.index, true);	
	}
	public static function ClassSelected(Class:CqClass):Void {
		Log.CustomMetric(Type.enumConstructor(Class).toLowerCase(), "Class Selected");
	}
}

