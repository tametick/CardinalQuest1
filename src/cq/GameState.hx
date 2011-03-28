package cq;
import haxel.HxlPoint;
import haxel.HxlState;
import haxel.HxlGraphics;

import data.Registery;

import flash.events.KeyboardEvent;

class GameState extends HxlState
{
	var gameUI:GameUI;

	public override function create():Void {
		super.create();		
		
		HxlGraphics.fade.start(false, 0x00000000, 0.25);
		//loadingBox = new HxlLoadingBox();
		//add(loadingBox);
	}
	
	public override function update() {
		super.update();	
		if ( initialized < 1 ) 
			return;
			
		
	}
	
	override function init() {
		// create and init the game gui
		gameUI = new GameUI();
		gameUI.zIndex = 50;
		add(gameUI);

		// populating the registry = might need to move this somewhere else
		var world = new CqWorld();
		var player = new CqPlayer();
		Registery.world = world;
		Registery.player = player;
		
		add(world.currentLevel);
		
		//updateFieldOfView(true);
	}
	
	override function onKeyUp(event:KeyboardEvent):Void {
		
	}
	override function onKeyDown(event:KeyboardEvent):Void {
		var player = Registery.player;
		var world = Registery.world;
		
		if (player.isMoving)
			return;
		
		player.isMoving = true;
		var targetTile = getTargetAccordingToKeyPress();		
		player.setTilePos(new HxlPoint(player.tilePos.x + targetTile.x, player.tilePos.y + targetTile.y));
		var positionOfTile:HxlPoint = world.currentLevel.getPixelPositionOfTile(Math.round(player.tilePos.x), Math.round(player.tilePos.y));
		player.moveToPixel(positionOfTile.x, positionOfTile.y);
		//updateFieldOfView();
	}
}
