package cq;

import world.World;
import world.Level;
import world.Actor;

class CqRegistery {
	public static var world:World;
	public static var player:Actor;
	public static var level(getLevel, null):Level;
	
	static function getLevel():Level {
		return world.currentLevel;
	}
}