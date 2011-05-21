package playtomic;

import flash.Lib;
import playtomic.base.Log;
import CqPreloader;

class Playtomic {
	static inline var swfid:Int = 2781;
	static inline var guid:String = "abad7983339e41ac";
	static var enabled:Bool;
	
	public static function create() {
		enabled = true;
		Log.View(swfid, guid, CqPreloader.url);
	}
	
	// pausing still collects the data, it only pauses sending
	// the collected data
	public static function pause() {
		if (!isEnabled())
			return;
		Log.Freeze();
	}
	
	public static function unpause() {
		if (!isEnabled())
			return;
		Log.UnFreeze();
	}
	
	public static function play() {
		if (!isEnabled())
			return;
		Log.Play();
	}
	
	public static function isEnabled():Bool {
		return enabled;
	}
}