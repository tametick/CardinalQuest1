package cq.states;

import haxel.HxlPoint;
import haxel.HxlSound;
import haxel.HxlState;
import haxel.HxlGraphics;
import haxel.HxlUtil;
import haxel.HxlSprite;

import playtomic.Playtomic;
import playtomic.PtPlayer;

import data.Configuration;


import world.World;

import cq.CqActor;
import cq.CqWorld;
import cq.CqItem;
import cq.CqSpell;
import cq.CqResources;
import cq.CqRegistery;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;


class GameState extends HxlState {	
	var gameUI:GameUI;
	public var chosenClass:CqClass;
	var isPlayerActing:Bool;

	public override function create() {
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
		var player = cast(CqRegistery.player, CqPlayer);
		var level = cast(CqRegistery.level, CqLevel);
		
		level.updateFieldOfView();
		player.actionPoints = 0;

		while (player.actionPoints < 60) {
			level.tick(this);
		}
		gameUI.updateCharges();
	}

	override function init() {
		initRegistry();
		Playtomic.play();
		var world = cast(CqRegistery.world,CqWorld);
		var player = cast(CqRegistery.player,CqPlayer);
		
		add(world.currentLevel);
		
		world.currentLevel.updateFieldOfView(true);

		// create and init the game gui
		// todo: do not recreate if already exists from previous games?
		gameUI = new GameUI();
		gameUI.zIndex = 50;
		add(gameUI);
		gameUI.initChests();
		gameUI.initHealthBars();
		
		gameUI.addHealthBar(player);
		gameUI.addXpBar(player);
		
		player.addOnPickup(gameUI.itemPickup);
		player.addOnInjure(gameUI.doPlayerInjureEffect);
		player.addOnKill(gameUI.doPlayerInjureEffect);
		player.addOnGainXP(gameUI.doPlayerGainXP);
		player.addOnMove(gameUI.checkTileItems);
		
		switch(chosenClass) {
			case FIGHTER:
				player.give(CqItemType.SHORT_SWORD);
				player.give(CqItemType.RED_POTION);
				player.give(CqItemType.RED_POTION);
				player.give(CqItemType.PURPLE_POTION);
				player.give(CqSpellType.BERSERK);
			case WIZARD:
				player.give(CqItemType.STAFF);
				player.give(CqItemType.RED_POTION);
				player.give(CqItemType.RED_POTION);
				player.give(CqItemType.BLUE_POTION);
				player.give(CqSpellType.FIREBALL);
			case THIEF:
				player.give(CqItemType.DAGGER);
				player.give(CqItemType.RED_POTION);
				player.give(CqItemType.RED_POTION);
				player.give(CqItemType.YELLOW_POTION);
				player.give(CqItemType.GREEN_POTION);
				player.give(CqSpellType.SHADOW_WALK);
		}

		PtPlayer.ClassSelected(chosenClass);
		
		var self = this;
		world.addOnNewLevel(function() {
			self.gameUI.initHealthBars();
			self.gameUI.addHealthBar(player);
		});
	}
	
	public function initRegistry(){
		// populating the registry
		CqRegistery.world = new CqWorld();
		CqRegistery.player = new CqPlayer(chosenClass);
	}
	
	override function onKeyDown(event:KeyboardEvent) {		
		if ( HxlGraphics.keys.ESCAPE ) {
			// If user was in targeting mode, cancel it
			if ( GameUI.isTargeting ) GameUI.setTargeting(false);
			HxlGraphics.pushState(new MainMenuState());
		}
	}

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
	
	var tmpPoint:HxlPoint;
	private function act() {
		if (GameUI.currentPanel != null)
			return;
		if ( GameUI.isTargeting ) {
			//gameUI.targetingMouseDown();
			return;
		}
		
		var level = CqRegistery.level;
		if (CqRegistery.player.isMoving)
			return;
		
		var dx = HxlGraphics.mouse.x - (CqRegistery.player.x+Configuration.zoomedTileSize()/2);
		var dy = HxlGraphics.mouse.y - (CqRegistery.player.y+Configuration.zoomedTileSize()/2);
		var target:HxlPoint = level.getTargetAccordingToMousePosition(dx, dy);
		var tile = getPlayerTile(target);
		
		if (Math.abs(dx) < Configuration.zoomedTileSize() / 2 && Math.abs(dy) < Configuration.zoomedTileSize() / 2) {
			if (tmpPoint == null)
				tmpPoint = new HxlPoint(0, 0);
			else {
				tmpPoint.x = 0;
				tmpPoint.y = 0;
			}
				
			tile = getPlayerTile(tmpPoint);
			 if (tile.loots.length > 0) {
				 // pickup item
				var item = cast(tile.loots[tile.loots.length - 1], CqItem);
				cast(CqRegistery.player, CqPlayer).pickup(this, item);
			} else if (HxlUtil.contains(SpriteTiles.instance.stairsDown.iterator(), tile.dataNum)) {
				// descend
				CqRegistery.world.goToNextLevel(this);
			}
			//clicking on ones-self should only do one turn
			isPlayerActing = false;
			// wait
		} else if ( !isBlockingMovement(target) ) {
			// move or attack in chosen tile
			CqRegistery.player.actInDirection(this, target);
			
			// if player just attacked don't continue moving
			if (cast(CqRegistery.player, CqPlayer).justAttacked)
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
				CqRegistery.player.actInDirection(this,target);
			else if (HxlUtil.contains(SpriteTiles.instance.doors.iterator(), tile.dataNum))
				openDoor(tile);
				
		}
		
		
		passTurn();
	}
	
	
	private function isBlockingMovement(target:HxlPoint):Bool{
		return CqRegistery.level.isBlockingMovement(Std.int(CqRegistery.player.tilePos.x + target.x), Std.int(CqRegistery.player.tilePos.y + target.y));
	}
	
	
	function getPlayerTile(target:HxlPoint):CqTile {
		return cast(CqRegistery.level.getTile(Std.int(CqRegistery.player.tilePos.x + target.x), Std.int(CqRegistery.player.tilePos.y + target.y)), CqTile);
	}
	
	
	function openDoor(tile:CqTile) {
		var col = cast(CqRegistery.level, CqLevel).getColor();
		CqRegistery.level.updateTileGraphic(tile.mapX, tile.mapY, SpriteTiles.instance.getSpriteIndex(col+"_door_open"));
	}
}
