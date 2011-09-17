package playtomic;

import data.Configuration;
import flash.Lib;
import playtomic.base.Log;

class Playtomic {
	static var swfid:Int = 2781;
	static var guid:String = "abad7983339e41ac";
	static var enabled:Bool;
	public static var localhost(default, null):Bool;
	
	public static function create() {
		enabled = true;
		localhost = false;
		var loadUrl = "";
        
        #if flash
            loadUrl = Lib.current.root.loaderInfo.loaderURL;
        #end
		
		if (StringTools.startsWith(loadUrl, "file://"))
			localhost = true;
		
		//probably a dev build or flash demo
		if (!Configuration.useProductionPlaytomic || !Configuration.standAlone || Configuration.debug) { 
			swfid = 2781;
			guid = "abad7983339e41ac";
		} else {
			swfid = 3045;
			guid = "759bd3b960a94124";
		}

		Log.View(swfid, guid, loadUrl);
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