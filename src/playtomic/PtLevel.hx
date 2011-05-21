package playtomic;

import world.Level;

import playtomic.Playtomic;
import playtomic.base.Log;

class PtLevel {
	var startTime:Date;
	var level:Level;
	
	public function new(level:Level) {
		if (!Playtomic.isEnabled())
			return;
		this.level = level;
	}
	
	//Use this when level starts
	public function start():Void {
		if (!Playtomic.isEnabled())
			return;
		PtPlayer.startLevel();
		startTime = Date.now();
	}
	
	//when level finnishes
	public function finish():Void {
		if (!Playtomic.isEnabled())
			return;
		var timeDifferenceSeconds:Float = (Date.now().getTime() - startTime.getTime()) / 1000;
		Log.LevelAverageMetric("Time Spent (sec)", level.index, Std.int(timeDifferenceSeconds));
		Log.LevelAverageMetric("Time Spent (mins)", level.index, Std.int(timeDifferenceSeconds / 60));
		Log.LevelAverageMetric("Time Spent (sec) U", level.index, Std.int(timeDifferenceSeconds), true);
		Log.LevelAverageMetric("Time Spent (mins) U", level.index, Std.int(timeDifferenceSeconds / 60), true);
		PtPlayer.finishLevel();
		Log.ForceSend();
	}
}