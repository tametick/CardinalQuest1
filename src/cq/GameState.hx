package cq;

import haxel.HxlPoint;
import haxel.HxlState;
import haxel.HxlGraphics;
import haxel.HxlUtil;
import haxel.HxlSprite;

import data.Configuration;
import data.Registery;

import world.World;
import world.Player;

import cq.CqActor;
import cq.CqWorld;
import cq.CqItem;
import cq.CqSpell;
import cq.CqResources;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

class GameState extends HxlState {
	var gameUI:GameUI;
	public var chosenClass:CqClass;

	public override function create():Void {
		super.create();		
		
		chosenClass = FIGHTER;

		HxlGraphics.fade.start(false, 0x00000000, 0.25);
		//loadingBox = new HxlLoadingBox();
		//add(loadingBox);
	}
	
	public override function update() {
		super.update();
		if ( initialized < 1 ) 
			return;
		if ( GameUI.isTargeting ) {
			gameUI.updateTargeting();
		} else if(isPlayerActing){
			act();
		}
		
	}
	
	function passTurn() {
		var player = cast(Registery.player, CqPlayer);
		var level = cast(Registery.level, CqLevel);
		
		level.updateFieldOfView();
		player.actionPoints = 0;

		while (player.actionPoints < 60) {
			level.tick(this);
		}
		gameUI.updateCharge();
	}

	override function init() {
		initRegistry();
		var world = cast(Registery.world,CqWorld);
		var player = cast(Registery.player,CqPlayer);
		
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
		player.addOnMove(gameUI.checkTileItems);
		
		switch(chosenClass) {
			case FIGHTER:
				player.give(null, CqItemType.SHORT_SWORD);
				player.give(null, CqItemType.RED_POTION);
				player.give(null, CqItemType.RED_POTION);
				player.give(null, CqItemType.PURPLE_POTION);
				player.give(null, CqSpellType.BERSERK);
				
			case WIZARD:
				player.give(null, CqItemType.STAFF);
				player.give(null, CqItemType.RED_POTION);
				player.give(null, CqItemType.RED_POTION);
				player.give(null, CqItemType.BLUE_POTION);
				player.give(null, CqSpellType.FIREBALL);
			case THIEF:
				player.give(null, CqItemType.DAGGER);
				player.give(null, CqItemType.RED_POTION);
				player.give(null, CqItemType.RED_POTION);
				player.give(null, CqItemType.YELLOW_POTION);
				player.give(null, CqItemType.GREEN_POTION);
				player.give(null, CqSpellType.SHADOW_WALK);
		}

		var self = this;
		world.addOnNewLevel(function() {
			self.gameUI.initHealthBars();
			self.gameUI.addHealthBar(player);
		});
	}
	
	public function initRegistry(){
		// populating the registry
		Registery.world = new CqWorld();
		Registery.player = new CqPlayer(chosenClass);
	}
	
	override function onKeyDown(event:KeyboardEvent) {		
		if ( HxlGraphics.keys.ESCAPE ) {
			// If user was in targeting mode, cancel it
			if ( GameUI.isTargeting ) GameUI.setTargeting(false);
			HxlGraphics.pushState(new MainMenuState());
		}
	}

	var isPlayerActing:Bool;
	override function onMouseDown(event:MouseEvent) {
		if ( GameUI.isTargeting ) {
			gameUI.targetingMouseDown();
			return;
		}
		
		isPlayerActing = true;

	}
	
	override function onMouseUp(event:MouseEvent) {
		isPlayerActing = false;
	}
	
	private function act():Void 
	{
		if ( GameUI.isTargeting ) {
			//gameUI.targetingMouseDown();
			return;
		}
		
		var level = Registery.level;
		if (Registery.player.isMoving)
			return;
		
		var dx = HxlGraphics.mouse.x - (Registery.player.x+Configuration.zoomedTileSize()/2);
		var dy = HxlGraphics.mouse.y - (Registery.player.y+Configuration.zoomedTileSize()/2);
		var target:HxlPoint = level.getTargetAccordingToMousePosition(dx, dy);
		var tile = getPlayerTile(target);
		
		if (Math.abs(dx) < Configuration.zoomedTileSize() / 2 && Math.abs(dy) < Configuration.zoomedTileSize() / 2) {
			tile = getPlayerTile(new HxlPoint(0, 0));
			 if (tile.loots.length > 0) {
				 // pickup item
				var item = cast(tile.loots[tile.loots.length - 1], CqItem);
				cast(Registery.player, CqPlayer).pickup(this, item);
			} else if (HxlUtil.contains(SpriteTiles.instance.stairsDown.iterator(), tile.dataNum)) {
				// descend
				Registery.world.goToNextLevel(this);
			}
			
			// wait
		} else if ( !isBlockingMovement(target) ) {
			// move or attack in chosen tile
			Registery.player.actInDirection(this, target);
			
			// if player just attacked don't continue moving
			if (cast(Registery.player, CqPlayer).justAttacked)
				isPlayerActing = false;
				
		} else if(HxlUtil.contains(SpriteTiles.instance.doors.iterator(),tile.dataNum)){
			// open door
			openDoor(tile);
		} else if(!(dx==0 && dy==0)){
			// slide
			if (Math.abs(dx) > Math.abs(dy))
				dx = 0;
			else
				dy = 0;
			
			target = level.getTargetAccordingToMousePosition(dx, dy);
			tile = getPlayerTile(target);
			if ( !isBlockingMovement(target) )
				Registery.player.actInDirection(this,target);
			else if (HxlUtil.contains(SpriteTiles.instance.doors.iterator(), tile.dataNum))
				openDoor(tile);
				
		}
		
		
		passTurn();
	}
	
	
	private function isBlockingMovement(target:HxlPoint):Bool{
		return Registery.level.isBlockingMovement(Std.int(Registery.player.tilePos.x + target.x), Std.int(Registery.player.tilePos.y + target.y));
	}
	
	
	function getPlayerTile(target:HxlPoint):CqTile {
		return cast(Registery.level.getTile(Std.int(Registery.player.tilePos.x + target.x), Std.int(Registery.player.tilePos.y + target.y)), CqTile);
	}
	
	
	function openDoor(tile:CqTile) {
		var col = cast(Registery.level, CqLevel).getColor();
		Registery.level.updateTileGraphic(tile.mapX, tile.mapY, SpriteTiles.instance.getSpriteIndex(col+"_door_open"));
	}
}
