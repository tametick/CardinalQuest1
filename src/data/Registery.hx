package data;

import cq.CqLevel;
import cq.CqWorld;
import cq.CqActor;
import kongregate.CKongregate;

class Registery {
	public static var world:CqWorld;
	public static var player:CqPlayer;
	public static var level(getLevel, null):CqLevel;
	public static var kong:CKongregate;
	
	public static var KONG_MAXLEVEL:String     = "Deepest dungeon level"; //Define as MAX stat
	public static var KONG_MAXGOLD:String      = "Most gold";             //Define as MAX stat
	
	public static var KONG_STARTFIGHTER:String = 'Start Fighter';         //Define as ADD stat
	public static var KONG_STARTTHIEF:String   = 'Start Thief';           //Define as ADD stat
	public static var KONG_STARTWIZARD:String  = 'Start Wizard';          //Define as ADD stat
	public static var KONG_FULLHEALAT1:String  = "Full heal at 1hp";      //Define as ADD stat ( I guess.. )

	
	public static function getKong():CKongregate {
		//Initialize kong if that wasnt done yet
		if (kong == null) 
		  kong = new CKongregate(); 
		return kong;
	}	
		
	static function getLevel():CqLevel {
		if (world == null || world.currentLevel == null)
			return null;
		return cast(world.currentLevel,CqLevel);
	}
}