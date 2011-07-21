package data;

class Configuration {
	//public static var debug = true;
	public static var debug = false;
	public static var standAlone = true;
	//public static var standAlone = false;
	
	public static var app_width:Int = 640;
	public static var app_height:Int = 480;
	public static var tileSize:Int;
	public static var zoom:Float;
	public static function zoomedTileSize():Int { 
		return Std.int(tileSize * zoom); 
	}
}