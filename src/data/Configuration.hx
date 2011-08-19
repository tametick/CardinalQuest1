package data;
import cq.CqActor;
import cq.states.MainMenuState;

class Configuration {
	public static var air = false;
	//public static var air = true;
	
	//public static var debug = true;
	public static var debug = false;
	public static var standAlone = true;
	public static var useProductionPlaytomic:Bool = true;
	//public static var standAlone = false;
	

	public static var debugStartingLevel:Int = 1;
	public static var debugStartingClass:CqClass = WIZARD;
	static public var debugMoveThroughWalls:Bool = false;
	
	public static var app_width:Int = 0;
	public static var app_height:Int = 0;
	public static var tileSize:Int;
	public static var zoom:Float;
	public static function zoomedTileSize():Int { 
		return Std.int(tileSize * zoom); 
	}
}