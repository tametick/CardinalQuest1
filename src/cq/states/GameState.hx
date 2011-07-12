package cq.states;

import com.eclecticdesignstudio.motion.Actuate;
import cq.CqRegistery;
import cq.ui.CqTextScroller;
import flash.display.Bitmap;
import haxel.HxlPoint;
import haxel.HxlSound;
import haxel.HxlState;
import haxel.HxlGraphics;
import haxel.HxlUtil;
import haxel.HxlSprite;

import playtomic.Playtomic;
import playtomic.PtPlayer;

import data.Configuration;
import data.Registery;
import data.SoundEffectsManager;

import world.World;
import world.Player;

import cq.CqActor;
import cq.CqWorld;
import cq.CqItem;
import cq.CqSpell;
import cq.CqResources;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

class GameState extends CqState {	
	var gameUI:GameUI;
	public var chosenClass:CqClass;
	var isPlayerActing:Bool;
	private var started:Bool;
	public override function create() {
		super.create();
		started = false;
		chosenClass = FIGHTER;
		HxlGraphics.fade.start(false, 0x00000000, 0.25);
		
		cursor.setFrame(SpriteCursor.instance.getSpriteIndex("up"));
		cursor.scrollFactor.y = cursor.scrollFactor.x = 0;
		//loadingBox = new HxlLoadingBox();
		//add(loadingBox);
	}
	
	public override function update() {
		super.update();
		if (!started) return;
		var up = SpriteCursor.instance.getSpriteIndex("up");
		if ( initialized < 1 ) 
			return;
			
		if ( GameUI.isTargeting ) {
			gameUI.updateTargeting();
			setDiagonalCursor();
		} else {
			if (isPlayerActing) {
				if (GameUI.currentPanel == null || !GameUI.currentPanel.isBlockingInput ) {
					act();
				}
			}
		}
		
		var dx = HxlGraphics.mouse.x - (Registery.player.x+Configuration.zoomedTileSize()/2);
		var dy = HxlGraphics.mouse.y - (Registery.player.y+Configuration.zoomedTileSize()/2);
		var target:HxlPoint = Registery.level.getTargetAccordingToMousePosition(dx, dy);
		
		if ( gameUI.overlapsPoint( HxlGraphics.mouse.x, HxlGraphics.mouse.y)||
		     Math.abs(dx) < Configuration.zoomedTileSize() && Math.abs(dy) < Configuration.zoomedTileSize()/2 
		   ) {
			setDiagonalCursor();
		} else {
			if(cursor.getFrame()!=up)
				cursor.setFrame(up);
			
			if(target.x==0 && target.y==1){
				if (cursor.angle != 180)
					cursor.angle = 180;
			} else if(target.x==0 && target.y==-1){
				if (cursor.angle != 0)
					cursor.angle = 0;
			} else if(target.x==1 && target.y==0){
				if (cursor.angle != 90)
					cursor.angle = 90;
			} else if(target.x==-1 && target.y==0){
				if (cursor.angle != 270)
					cursor.angle = 270;
			}
		}
	}
	
	function passTurn() {
		var player = CqRegistery.player;
		var level = CqRegistery.level;
		
		level.updateFieldOfView(this);
		if (Std.is(GameUI.currentPanel,CqMapDialog))
			GameUI.currentPanel.updateDialog();
		
		player.actionPoints = 0;

		while (player.actionPoints < 60) {
			level.tick(this);
		}
		gameUI.updateCharges();
	}

	override function init() {
		scroller = new CqTextScroller(IntroScreen, 1, "Intro screen");
		var introText:String = "Hi this is intro text\n a new line \n the end.";
		scroller.addColumn(100, 400, introText, false, FontAnonymousPro.instance.fontName);
		add(scroller);
		scroller.startScroll();
		scroller.onComplete(realInit);
	}
	function realInit() {
		remove(scroller);
		started = true;
		
		initRegistry();
		Playtomic.play();
		var world = CqRegistery.world;
		var player = CqRegistery.player;
		
		add(world.currentLevel);
		world.currentLevel.updateFieldOfView(this, true);
		

		// create and init the game gui
		// todo: do not recreate if already exists from previous games?
		if(gameUI == null){
			gameUI = new GameUI();
			gameUI.zIndex = 50;
			add(gameUI);
			gameUI.initChests();
			gameUI.initHealthBars();
			
			gameUI.addHealthBar(player);
			gameUI.addXpBar(player);
		}
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
		Registery.world = new CqWorld();
		Registery.player = new CqPlayer(chosenClass);
	}
	
	override function onKeyUp(event:KeyboardEvent) {		
		if ( HxlGraphics.keys.justReleased("ESCAPE") ) {
			// If user was in targeting mode, cancel it
			if ( GameUI.isTargeting ) {
				GameUI.setTargeting(false);
			}
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
	private var scroller:CqTextScroller;
	private function act() {
		if ( GameUI.isTargeting ) {
			return;
		}
		
		var level = Registery.level;
		if (Registery.player.isMoving)
			return;
		
		var dx = HxlGraphics.mouse.x - (Registery.player.x+Configuration.zoomedTileSize()/2);
		var dy = HxlGraphics.mouse.y - (Registery.player.y+Configuration.zoomedTileSize()/2);
		var target:HxlPoint = level.getTargetAccordingToMousePosition(dx, dy);
		var tile = getPlayerTile(target);
		
		if (Math.abs(dx) < Configuration.zoomedTileSize() && Math.abs(dy) < Configuration.zoomedTileSize() ) {
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
				CqRegistery.player.pickup(this, item);
			} else if (HxlUtil.contains(SpriteTiles.instance.stairsDown.iterator(), tile.dataNum)) {
				// descend
				Registery.world.goToNextLevel(this);
			}
			//clicking on ones-self should only do one turn
			isPlayerActing = false;
			// wait
		} else if ( !isBlockingMovement(target) ) {
			// move or attack in chosen tile
			Registery.player.actInDirection(this, target);
			
			// if player just attacked don't continue moving
			if (CqRegistery.player.justAttacked)
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
			if ( !isBlockingMovement(target) ) {
				CqRegistery.player.actInDirection(this,target);
			} else if (HxlUtil.contains(SpriteTiles.instance.doors.iterator(), tile.dataNum)){
				openDoor(tile);
			}
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
		SoundEffectsManager.play(DoorOpen);
		var col = CqRegistery.level.getColor();
		Registery.level.updateTileGraphic(tile.mapX, tile.mapY, SpriteTiles.instance.getSpriteIndex(col + "_door_open"));
	}
}
