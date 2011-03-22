package cq;
import haxel.HxlState;
import haxel.HxlGraphics;

import data.Registery;

class GameState extends HxlState
{
	public override function create():Void {
		super.create();		
		
		HxlGraphics.fade.start(false, 0x00000000, 0.25);
		//loadingBox = new HxlLoadingBox();
		//add(loadingBox);
	}
	
	public override function update():Void {
		super.update();	
	
		if ( initialized == 0 ) {
			// populating the registry = might need to move this somewhere else
			var world = new CqWorld();
			var player = new CqPlayer();
			Registery.world = world;
			Registery.player = player;
			
			
			add(world.currentLevel);
			world.currentLevel.follow();
			
			//world.addAllActors();
			//world.addAllLoots();
			HxlGraphics.follow(player, 10);
			
			//updateFieldOfView(true);

			initialized = 1;
			
			//loadingBox.visible = false;
		}
		
	}
}
