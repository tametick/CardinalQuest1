package playtomic;

import flash.Lib;
import playtomic.base.Log;

class Playtomic {
	static inline var SWFID:Int = 2781;
	static inline var GUID:String = "abad7983339e41ac";
	
	public static function begin() {
		Log.View(SWFID, GUID, "ereptoric.com");
	}
	
	// pausing collects ques up the data, it only pauses sending
	// the collected data
	public static function pause() {
		Log.Freeze();
	}
	
	public static function unpause() {
		Log.UnFreeze();
	}
	
	public static function play() {
		Log.Play();
	}
}