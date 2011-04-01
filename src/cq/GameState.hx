package cq;

import haxel.HxlPoint;
import haxel.HxlState;
import haxel.HxlGraphics;

import data.Registery;

import world.World;
import world.Player;

import cq.CqActor;
import cq.CqWorld;
import cq.CqItem;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

class GameState extends HxlState
{
	var gameUI:GameUI;

	public override function create():Void {
		super.create();		
		
		HxlGraphics.fade.start(false, 0x00000000, 0.25);
		//loadingBox = new HxlLoadingBox();
		//add(loadingBox);

		//HxlGraphics.pushState(new MainMenuState());
	}
	
	public override function update() {
		super.update();	
		if ( initialized < 1 ) 
			return;
			
		
	}

	override function init() {
		// populating the registry = might need to move this somewhere else
		var world = new CqWorld();
		var player = new CqPlayer(CqClass.FIGHTER);
		Registery.world = world;
		Registery.player = player;
		
		add(world.currentLevel);
		
		world.currentLevel.updateFieldOfView(true);

		// create and init the game gui
		gameUI = new GameUI();
		gameUI.zIndex = 50;
		add(gameUI);
	}
	
	override function onKeyUp(event:KeyboardEvent) { }
	override function onKeyDown(event:KeyboardEvent) {		
		if ( HxlGraphics.keys.ESCAPE ) {
			HxlGraphics.pushState(new MainMenuState());
			return;
		}
		
		var player = Registery.player;
		var world = Registery.world;
		
		if (player.isMoving)
			return;
		
		var targetTile = world.currentLevel.getTargetAccordingToKeyPress();
		if ( targetTile != null ) {
			// move or attack
			playerAct(world, player, targetTile);
		} else {
			// other actions?
		}		
	}
	override function onMouseOver(event:MouseEvent) { }
	override function onMouseUp(event:MouseEvent) { }
	override function onMouseDown(event:MouseEvent) {
		var tileX = Std.int(HxlGraphics.mouse.x / (CqConfiguration.tileSize*2));
		var tileY = Std.int(HxlGraphics.mouse.y / (CqConfiguration.tileSize*2));

		var dx = HxlGraphics.mouse.x - Registery.player.x;
		var dy = HxlGraphics.mouse.y - Registery.player.y;
		var level = Registery.world.currentLevel;
		if (Math.abs(dx) > Math.abs(dy)){
			if (dx < 0) {
				if (!level.isBlockingMovement(Std.int(Registery.player.tilePos.x - 1), Std.int(Registery.player.tilePos.y)))
					playerAct(Registery.world, Registery.player, new HxlPoint( -1, 0));					
			} else {
				if (!level.isBlockingMovement(Std.int(Registery.player.tilePos.x + 1), Std.int(Registery.player.tilePos.y)))
					playerAct(Registery.world, Registery.player, new HxlPoint( 1, 0));
			}
		} else {
			if (dy < 0) {
				if (!level.isBlockingMovement(Std.int(Registery.player.tilePos.x), Std.int(Registery.player.tilePos.y-1)))
					playerAct(Registery.world, Registery.player, new HxlPoint( 0, -1));
			} else {
				if (!level.isBlockingMovement(Std.int(Registery.player.tilePos.x), Std.int(Registery.player.tilePos.y+1)))
					playerAct(Registery.world, Registery.player, new HxlPoint( 0, 1));
			}
		}
		
	}
	

	
	function playerAct(world:World, player:Player, targetTile:HxlPoint) {
		var tile = cast(world.currentLevel.getTile(player.tilePos.x + targetTile.x,  player.tilePos.y + targetTile.y),CqTile);
		
		if (tile.actors.length>0) {
			// attack actor
		} else if (tile.loots.length > 0) {
			var loot = tile.loots[tile.loots.length - 1];
			if (Std.is(loot, CqChest)) {
				// bust chest
				var chest = cast(loot, CqChest);
				chest.bust(this);
			} else {
				// pickup item(?)
			}
			
		} else {
			player.isMoving = true;
			player.setTilePos(new HxlPoint(player.tilePos.x + targetTile.x, player.tilePos.y + targetTile.y));
			var positionOfTile:HxlPoint = world.currentLevel.getPixelPositionOfTile(Math.round(player.tilePos.x), Math.round(player.tilePos.y));
			player.moveToPixel(positionOfTile.x, positionOfTile.y);		
			world.currentLevel.updateFieldOfView();
		}
	}
}
