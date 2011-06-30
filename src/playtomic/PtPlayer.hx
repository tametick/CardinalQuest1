package playtomic;

import cq.CqActor;
import cq.CqRegistery;

import playtomic.Playtomic;
import playtomic.base.Log;

class PtPlayer {
	static var attacksDodged:Int;
	static var attacksMissed:Int;
	static var attacksSuccessful:Int;
	static var beenHit:Int;
	static var enemiesKilled:Int;
	
	static var classSelected:CqClass;
	static var classSelectedStr:String;
	
	public static function startLevel() {
		if (!Playtomic.isEnabled())
			return;
		beenHit = enemiesKilled = 0;
		attacksDodged = attacksMissed = attacksSuccessful = 0;
	}
	
	public static function finishLevel() {
		if (!Playtomic.isEnabled())
			return;
			
		Log.LevelRangedMetric(classSelectedStr.charAt(0) + " Attacks Dodged", CqRegistery.level.index, attacksDodged);
		Log.LevelRangedMetric(classSelectedStr.charAt(0) + " Attacks Missed", CqRegistery.level.index, attacksMissed);
		Log.LevelRangedMetric(classSelectedStr.charAt(0) + " Attacks Successful", CqRegistery.level.index, attacksSuccessful);
		Log.LevelRangedMetric(classSelectedStr.charAt(0) + " Player Hit", CqRegistery.level.index, beenHit);
		Log.LevelRangedMetric(classSelectedStr.charAt(0) + " Kills", CqRegistery.level.index, enemiesKilled);

	}
	
	public static function isHit() {
		if (!Playtomic.isEnabled())
			return;
		beenHit++;
	}
	
	public static function hits() {
		if (!Playtomic.isEnabled())
			return;
		attacksSuccessful++;
	}
	
	public static function dodges() {
		if (!Playtomic.isEnabled())
			return;
		attacksDodged++;
	}
	
	public static function kills() {
		if (!Playtomic.isEnabled())
			return;
		enemiesKilled++;
	}
	
	public static function misses() {
		if (!Playtomic.isEnabled())
			return;
		attacksMissed++;
	}
	/*
	public static function dies() {
		if (!Playtomic.isEnabled())
			return;
		Log.LevelCounterMetric("Player Died", Registery.level.index);
		Log.LevelCounterMetric("Player Died U", Registery.level.index, true);
	}
*/
	public static function ClassSelected(SelectedClass:CqClass) {
		if (!Playtomic.isEnabled())
			return;
		classSelectedStr = Type.enumConstructor(SelectedClass).toLowerCase();
		classSelectedStr = classSelectedStr.charAt(0).toUpperCase() + classSelectedStr.substr(1);
		Log.CustomMetric(classSelectedStr, "Class Selected");
		classSelected = SelectedClass;
	}
}

