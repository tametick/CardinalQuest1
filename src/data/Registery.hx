package data;

import world.World;
import world.Level;
import world.Player;

class Registery {
	public static var world:World;
	public static var player:Player;
	public static var level(getLevel, null):Level;
	
	static function getLevel():Level {
		return world.currentLevel;
	}
}