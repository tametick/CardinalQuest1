package data;
import cq.CqActor;

/*
 *  Please put in comments what the value should be during in release time
 *  A quick visual check should confirm that all is well
 *
 * */

class Configuration {
	public static inline var version = "1.2";

	public static inline var debug = false;
	public static inline var air = false;
	public static inline var standAlone = false;
	public static inline var useProductionPlaytomic = true;

	//I am not going to go off air, we will assume air is Desktop air
	//for iOS we are now assuming not NME but air
	//A copy of this Configuration.hx will be stored in air ios
	//A switcheroo will be performed when compiling out of air ios
	//That seems to be best way to not mess the main developers
	//I use the air ios comments as a check in my build script
	public static inline var iOS = false; //air-ios
	public static inline var android = false;
	public static inline var mobile = false; //air-ios
	public static inline var noCache = false;

	public static inline var debugStartingLevel:Int = 0;
	public static inline var debugStartingClass:String = "WIZARD";
	static public inline var debugMoveThroughWalls:Bool = false;

	public static var app_width:Int = 0;
	public static var app_height:Int = 0;

	public static var tileSize:Int;
	public static var zoom:Float;
	public static function zoomedTileSize():Int {
		return Std.int(tileSize * zoom);
	}

	public static var playerLives = 1;
	public static var spellsPerLevel = 2;

	public static inline var startWithMusic:Bool = true;
	public static inline var startWithSound:Bool = true;

	public static inline var chestsPerLevel = 12;

	public static inline var mobsPerLevel = 18;
	public static inline var lastLevel = 7;
	public static inline var demoLastLevel = 2;

	public static inline var dropPotionChance:Float = 0.4;
	public static inline var betterItemChance:Float = 0.1;
	public static inline var EnchantItemChance:Float = 0.1;
	public static inline var BetterEnchantItemChance:Float = 0.01;

	public static inline var strongerEnemyChance:Float = 0.7;

	public static function getLevelWidth(?level:Int=0) {
		return 32;
	}
	public static function getLevelHeight(?level:Int=0) {
		return 32;
	}

	public static var bindings = {
		compasses: [["W", "A", "S", "D"], ["K", "H", "J", "L"], ["UP", "LEFT", "DOWN", "RIGHT"]],
		waitkeys: ["PERIOD", "NONUMLOCK_5", "ENTER", "SPACE"],
		potions: ["SIX", "SEVEN", "EIGHT", "NINE", "ZERO"],
		spells: ["ONE", "TWO", "THREE", "FOUR", "FIVE"],
		nexttarget: ["TAB", "PLUS"]
	}
}
