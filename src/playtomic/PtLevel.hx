package playtomic;

import world.Level;

import playtomic.base.Log;

class PtLevel 
{
	var startTime:Date;
	var level:Level;
	
	public function new(level:Level) {
		this.level = level;
	}
	
	//Use this when level starts
	public function Start():Void {
		PtPlayer.startLevel();
		startTime = Date.now();
	}
	
	//when level finnishes
	public function Finish():Void {
		var timeDifferenceSeconds:Float = (Date.now().getTime() - startTime.getTime()) / 1000;
		Log.LevelAverageMetric("Time Spent (sec)", level.index, Std.int(timeDifferenceSeconds));
		Log.LevelAverageMetric("Time Spent (mins)", level.index, Std.int(timeDifferenceSeconds / 60));
		Log.LevelAverageMetric("Time Spent (sec) U", level.index, Std.int(timeDifferenceSeconds), true);
		Log.LevelAverageMetric("Time Spent (mins) U", level.index, Std.int(timeDifferenceSeconds / 60), true);
		PtPlayer.finishLevel();
		Log.ForceSend();
	}
}