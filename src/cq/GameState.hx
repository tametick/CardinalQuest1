package cq;
import haxel.HxlState;
import haxel.HxlGraphics;

import data.Registery;

class GameState extends HxlState
{

	var gameUI:GameUI;

	public override function create():Void {
		super.create();		
		
		HxlGraphics.fade.start(false, 0x00000000, 0.25);
		//loadingBox = new HxlLoadingBox();
		//add(loadingBox);
	}
	
	public override function update():Void {
		super.update();	
	
		if ( initialized == 0 ) {
			// create and init the game gui
			gameUI = new GameUI();
			gameUI.zIndex = 50;
			add(gameUI);

			// populating the registry
			var world = new CqWorld();
			var player = new CqPlayer();
			Registery.world = world;
			Registery.player = player;
			
			
			add(world.currentLevel);
			world.currentLevel.follow();
			
			//HxlGraphics.follow(player, 10);
			
			//updateFieldOfView(true);

			initialized = 1;
			
			//loadingBox.visible = false;
		}
		
	}
}
