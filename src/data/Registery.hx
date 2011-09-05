package data;

import cq.CqWorld;
import cq.CqActor;

class Registery {
	public static var world:CqWorld;
	public static var player:CqPlayer;
	public static var level(getLevel, null):CqLevel;
	
	static function getLevel():CqLevel {
		if (world == null || world.currentLevel == null)
			return null;
		return cast(world.currentLevel,CqLevel);
	}
}