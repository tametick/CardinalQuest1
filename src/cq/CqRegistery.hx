package cq;

import world.Level;
import data.Registery;
import cq.CqActor;
class CqRegistery {
	public static var world(getWorld,setWorld):CqWorld;
	public static var player(getPlayer, setPlayer):CqPlayer;
	//todo: make it to CqLevel
	public static var level(getLevel, null):Level;
	
	static private function getWorld():CqWorld {
		return cast(Registery.world, CqWorld);
	}
	static private function setWorld(value:CqWorld):CqWorld {
		Registery.world = value;
		return value;
	}
	
	static private function getPlayer():CqPlayer 
	{
		return cast(Registery.player, CqPlayer);
	}
	
	static private function setPlayer(value:CqPlayer):CqPlayer 
	{
		Registery.player = cast(value,world.Player);
		return value;
	}
	
	static function getLevel():Level {
		return world.currentLevel;
	}
}