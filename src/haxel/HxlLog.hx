package haxel;

interface HxlLogViewer {
	function append(message:String):Void;
}

class HxlLog {
	public static var logViewer:HxlLogViewer;
	
	public static function append(message:String, ?style:Dynamic) {
		// todo - apply style?
		logViewer.append(message);
	}
}