package data;
import cq.CqActor;
import cq.states.MainMenuState;

/*
 *  Please put in comments what the value should be during in release time
 *  A quick visual check should confirm that all is well
 * 
 * */

class Configuration {
	public static var debug = false;
	public static var air = false;
	public static var standAlone = false;
	public static var useProductionPlaytomic = false;
	
	public static var debugStartingLevel:Int = 0;
	public static var debugStartingClass:CqClass = FIGHTER;
	static public var debugMoveThroughWalls:Bool = false;
	
	public static var app_width:Int = 0;
	public static var app_height:Int = 0;
	public static var tileSize:Int;
	public static var zoom:Float;
	public static function zoomedTileSize():Int { 
		return Std.int(tileSize * zoom); 
	}
	
	public static var startWithMusic:Bool = false; //true
	public static var startWithSound:Bool = false; //true

	public static var chestsPerLevel = 12;
	public static var spellsPerLevel = 2;
	public static var mobsPerLevel = 18;
	public static var lastLevel = 7;
	public static var demoLastLevel = 2;	
	
	public static var playerLives = 1;
	
	public static var dropPotionChance:Float = 0.4;
	public static var betterItemChance:Float = 0.1;
	public static var EnchantItemChance:Float = 0.1;
	public static var BetterEnchantItemChance:Float = 0.01;
	
	public static var strongerEnemyChance:Float = 0.7;
	
	public static function getLevelWidth(?level:Int=0) { 
		return 32; 
	}
	public static function getLevelHeight(?level:Int=0) {
		return 32; 
	}
}