package cq;

import haxel.HxlPoint;
import haxel.HxlState;
import haxel.HxlGraphics;
import haxel.HxlUtil;
import haxel.HxlSprite;

import data.Registery;

import world.World;
import world.Player;

import cq.CqActor;
import cq.CqWorld;
import cq.CqItem;
import cq.CqResources;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

class GameState extends HxlState {
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
	
	function passTurn() {
		var player = cast(Registery.player, CqPlayer);
		var level = cast(Registery.world.currentLevel, CqLevel);
		
		level.updateFieldOfView();
		player.actionPoints = 0;

		while (player.actionPoints < 60) {
			level.tick(this);
		}
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
		gameUI.initChests();
		gameUI.initHealthBars();
		gameUI.addHealthBar(player);
		player.addOnPickup(gameUI.itemPickup);
		player.addOnInjure(gameUI.doPlayerInjureEffect);
		player.addOnKill(gameUI.doPlayerInjureEffect);
		player.addOnGainXP(gameUI.doPlayerGainXP);

		var self = this;
		world.addOnNewLevel(function() {
			self.gameUI.initHealthBars();
			self.gameUI.addHealthBar(player);
		});
	}
	
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
		if (targetTile != null) {
			var tile = cast(world.currentLevel.getTile(Std.int(Registery.player.tilePos.x + targetTile.x), Std.int(Registery.player.tilePos.y + targetTile.y)),CqTile);
			if ( !world.currentLevel.isBlockingMovement(Std.int(player.tilePos.x+targetTile.x), Std.int(player.tilePos.y+targetTile.y)) ) {
				// move or attack
				Registery.player.actInDirection(this, targetTile);
			} else if(HxlUtil.contains(SpriteTiles.instance.doors,tile.dataNum)){
				// open door
				openDoor(tile);
			}
		} else {
			// other keyboard actions?
			return;
		}
	
		passTurn();
	}

	override function onMouseDown(event:MouseEvent) {
		var level = Registery.world.currentLevel;
		if (Registery.player.isMoving)
			return;
		
		var dx = HxlGraphics.mouse.x - Registery.player.x;
		var dy = HxlGraphics.mouse.y - Registery.player.y;		
		var targetTile:HxlPoint = level.getTargetAccordingToMousePosition(dx, dy);
		var tile = cast(level.getTile(Std.int(Registery.player.tilePos.x + targetTile.x), Std.int(Registery.player.tilePos.y + targetTile.y)),CqTile);
		
		if ( !level.isBlockingMovement(Std.int(Registery.player.tilePos.x+targetTile.x), Std.int(Registery.player.tilePos.y+targetTile.y)) ) {
			// move or attack in chosen tile
			Registery.player.actInDirection(this,targetTile);
		} else if(HxlUtil.contains(SpriteTiles.instance.doors,tile.dataNum)){
			// open door
			openDoor(tile);
		}
		
		passTurn();
	}
	
	function openDoor(tile:CqTile) {
		// fix me 
		Registery.world.currentLevel.updateTileGraphic(tile.mapX, tile.mapY, SpriteTiles.instance.openDoors[0]);
	}
}
