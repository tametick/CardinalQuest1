package playtomic;

import cq.CqActor;
import data.Resources;
import data.StatsFile;

import data.Registery;

import playtomic.Playtomic;
import playtomic.base.Log;

class PtPlayer {
	static var attacksDodged:Int;
	static var attacksMissed:Int;
	static var attacksSuccessful:Int;
	static var beenHit:Int;
	static var enemiesKilled:Int;
	
	static var classSelectedID:String;
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
			
		Log.LevelRangedMetric(classSelectedStr.charAt(0) + " Attacks Dodged", Registery.level.index, attacksDodged);
		Log.LevelRangedMetric(classSelectedStr.charAt(0) + " Attacks Missed", Registery.level.index, attacksMissed);
		Log.LevelRangedMetric(classSelectedStr.charAt(0) + " Attacks Successful", Registery.level.index, attacksSuccessful);
		Log.LevelRangedMetric(classSelectedStr.charAt(0) + " Player Hit", Registery.level.index, beenHit);
		Log.LevelRangedMetric(classSelectedStr.charAt(0) + " Kills", Registery.level.index, enemiesKilled);

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
	public static function ClassSelected(SelectedClass:String) {
		if (!Playtomic.isEnabled())
			return;
			
		var classes:StatsFile = Resources.statsFiles.get( "classes.txt" );
		var classEntry:StatsFileEntry = classes.getEntry( "ID", SelectedClass );
			
		classSelectedID = SelectedClass;
		classSelectedStr = classEntry.getField( "Name" );
		Log.CustomMetric(classSelectedStr, "Class Selected");
	}
}

