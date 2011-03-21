package cq;
import haxel.HxlState;

import data.Registery;

class GameState extends HxlState
{
	public override function create():Void {
		super.create();
		
		// populating the registry = might need to move this somewhere else
		Registery.world = new CqWorld();
		Registery.player = new CqPlayer();
	
	}
}
