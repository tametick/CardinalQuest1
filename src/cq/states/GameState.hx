package cq.states;

import com.eclecticdesignstudio.motion.Actuate;
import cq.CqConfiguration;
import cq.ui.CqPotionButton;
import cq.CqRegistery;
import cq.ui.CqSpellButton;
import cq.GameUI;
import cq.ui.CqMapDialog;
import cq.ui.CqTextScroller;
import flash.display.Bitmap;
import haxel.HxlPoint;
import haxel.HxlSound;
import haxel.HxlState;
import haxel.HxlGraphics;
import haxel.HxlTextInput;
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
	static public var inst:GameState;
	var gameUI:GameUI;
	public var chosenClass:CqClass;
	public var isPlayerActing:Bool;
	public var started:Bool;
	var endingAnim:Bool;
	public override function create() {
		inst = this;
		super.create();
		started = endingAnim = false;
		chosenClass = FIGHTER;
		HxlGraphics.fade.start(false, 0x00000000, 0.25);
		cursor.setFrame(SpriteCursor.instance.getSpriteIndex("diagonal"));
		cursor.scrollFactor.y = cursor.scrollFactor.x = 0;
		//loadingBox = new HxlLoadingBox();
		//add(loadingBox);
	}
	public override function destroy() {
		inst = null;
		gameUI.kill();
		remove(gameUI);
		gameUI = null;
		add(CqRegistery.world.currentLevel);
	}
	
	public override function render() {
		if (gameUI != null)
			gameUI.updateCentralBarsPosition();
		super.render();
	}

	public override function update() {
		super.update();
		if (!started || endingAnim) return;
		var up = SpriteCursor.instance.getSpriteIndex("up");
		if ( initialized < 1 ) 
			return;
			
		if ( GameUI.isTargeting) {
			gameUI.updateTargeting();
			setDiagonalCursor();
		} else {
			actKeys();
			if (isPlayerActing) {
				if (GameUI.currentPanel == null || !GameUI.currentPanel.isBlockingInput) {
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
			if (GameUI.isTargeting) {
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
	}
	
	private function actKeys():Void 
	{
		act(true);
	}
	
	private function checkJumpKeys():Void {
		if (HxlGraphics.keys.justReleased("K") && CqRegistery.world.currentLevelIndex>0)
		{
			CqRegistery.world.goToNextLevel(this, CqRegistery.world.currentLevelIndex-1);
		}else if (HxlGraphics.keys.justReleased("L") && CqRegistery.world.currentLevelIndex<CqConfiguration.lastLevel)
		{
			CqRegistery.world.goToNextLevel(this, CqRegistery.world.currentLevelIndex+1);
		}
	}
	private function checkGameKeys():Void {
		var item = null;
		//potions
		if (HxlGraphics.keys.justReleased("SIX"))
		{
			item = gameUI.dlgPotionGrid.cells[0];
		}else if (HxlGraphics.keys.justReleased("SEVEN"))
		{
			item = gameUI.dlgPotionGrid.cells[1];
		}else if (HxlGraphics.keys.justReleased("EIGHT"))
		{
			item = gameUI.dlgPotionGrid.cells[2];
		}else if (HxlGraphics.keys.justReleased("NINE"))
		{
			item = gameUI.dlgPotionGrid.cells[3];
		}else if (HxlGraphics.keys.justReleased("ZERO"))
		{
			item = gameUI.dlgPotionGrid.cells[4];
		}
		if (item != null)
		{
			cast(item, CqPotionCell).potBtn.usePotion();
		}
		item = null;
		//spells
		if (HxlGraphics.keys.justReleased("ONE"))
		{
			item = gameUI.dlgSpellGrid.cells[0];
		}else if (HxlGraphics.keys.justReleased("TWO"))
		{
			item = gameUI.dlgSpellGrid.cells[1];
		}else if (HxlGraphics.keys.justReleased("THREE"))
		{
			item = gameUI.dlgSpellGrid.cells[2];
		}else if (HxlGraphics.keys.justReleased("FOUR"))
		{
			item = gameUI.dlgSpellGrid.cells[3];
		}else if (HxlGraphics.keys.justReleased("FIVE"))
		{
			item = gameUI.dlgSpellGrid.cells[4];
		}
		if (item != null)
		{
			cast(item, CqSpellCell).btn.useSpell();
		}
		//open ui
		if (HxlGraphics.keys.justReleased("M"))
		{
			gameUI.showMapDlg();
		}else if (HxlGraphics.keys.justReleased("I"))
		{
			gameUI.showInvDlg();
		}else if (HxlGraphics.keys.justReleased("C"))
		{
			gameUI.showCharDlg();
		}
	}
	public function passTurn() {
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
		classEntry();
		if(Configuration.debug){
			CqConfiguration.chestsPerLevel = 100;
			CqConfiguration.spellsPerLevel = 50;
		}
	}
	
	function classEntry() {
		if (scroller != null){
			remove(scroller);
			scroller = null;
		}
			
		var classBG:Class<Bitmap> = null;
		switch(chosenClass){
			case CqClass.FIGHTER:
				classBG = SpriteKnightEntry;
			case CqClass.THIEF:
				classBG = SpriteThiefEntry;
			case CqClass.WIZARD:
				classBG = SpriteWizardEntry;
		}
		scroller = new CqTextScroller(classBG, 1);
		var introText:String = "You enter the dark dungeon...\n\nYou feel this text is a placeholder and needs replacement.";
		scroller.addColumn(100, 400, introText, false, FontAnonymousPro.instance.fontName);
		add(scroller);
		scroller.startScroll();
		scroller.onComplete(realInit);
	}
	
	function realInit() {
		if (scroller != null) {
			remove(scroller);
			scroller = null;
		}
				
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
			
			world.addOnNewLevel(gameUI.panelMap.updateDialog);
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
		});
	}
	
	public function initRegistry(){
		// populating the registry
		Registery.world = new CqWorld();
		Registery.player = new CqPlayer(chosenClass);
	}
	
	override function onKeyUp(event:KeyboardEvent) {	
		if (!started || endingAnim) return;
		if ( HxlGraphics.keys.justReleased("ESCAPE") ) {
			// If user was in targeting mode, cancel it
			if ( GameUI.isTargeting ) {
				GameUI.setTargeting(false);
			}
			if (gameUI._dialog)
			{
				gameUI.hideCurrentPanel();
			}
			HxlGraphics.pushState(new MainMenuState());
		}
		if (Configuration.debug)
			checkJumpKeys();
	}

	override function onMouseDown(event:MouseEvent) {
		if (HxlGraphics.justUnpaused) {
			HxlGraphics.justUnpaused = false;
			return;
		}		
		
		if (!started || endingAnim) 
			return;
		if ( GameUI.isTargeting ) {
			gameUI.targetingMouseDown();
			return;
		}

		isPlayerActing = true;
	}
	
	override function onMouseUp(event:MouseEvent) {
		if (!started || endingAnim)
			return;
			
		isPlayerActing = false;
	}
	
	var tmpPoint:HxlPoint;
	private var scroller:CqTextScroller;
	private function act(?byKey:Bool = false) {
		if ( GameUI.isTargeting ||!started || endingAnim) {
			return;
		}
		
		var level = Registery.level;
		if (Registery.player.isMoving)
			return;
		//check game keys on your turn
		checkGameKeys();
		var target:HxlPoint;
		var dx;
		var dy;
		var tile:CqTile;
		if (byKey)
		{
			dx =  (Registery.player.x + Configuration.zoomedTileSize()/2);
			dy =  (Registery.player.y + Configuration.zoomedTileSize() / 2);
			var acts:Bool = false;
			if (HxlGraphics.keys.pressed("UP") || HxlGraphics.keys.pressed("W"))
			{
				acts = true;
			}else if (HxlGraphics.keys.pressed("DOWN") || HxlGraphics.keys.pressed("S"))
			{
				acts = true;
			}else if (HxlGraphics.keys.pressed("LEFT") || HxlGraphics.keys.pressed("A"))
			{
				acts = true;
			}else if (HxlGraphics.keys.pressed("RIGHT") || HxlGraphics.keys.pressed("D"))
			{
				acts = true;
			}else if (HxlGraphics.keys.justPressed("ENTER"))
			{
				acts = true;
			}
			if (!acts ) return;
			if (GameUI.currentPanel != null)
				if(GameUI.currentPanel != gameUI.panelMap) return;
			target = level.getTargetAccordingToKeyPress();
		}else {
			dx = HxlGraphics.mouse.x - (Registery.player.x+Configuration.zoomedTileSize()/2);
			dy = HxlGraphics.mouse.y - (Registery.player.y + Configuration.zoomedTileSize() / 2);
			target = level.getTargetAccordingToMousePosition(dx, dy);
		}
		
		var tile = getPlayerTile(target);
		
		if (Math.abs(dx) < Configuration.zoomedTileSize() && Math.abs(dy) < Configuration.zoomedTileSize() || HxlGraphics.keys.justPressed("ENTER") ) {
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
			//we already have target, but this smoothes out movement
			if(byKey)
				target = level.getTargetAccordingToKeyPress();
			else
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
	public function startBossAnim()
	{
		endingAnim = true;
		var tileLocation:HxlPoint = HxlUtil.getRandomTileWithDistance(CqConfiguration.getLevelWidth(), CqConfiguration.getLevelHeight(), Registery.level.mapData, SpriteTiles.instance.walkableAndSeeThroughTiles,CqRegistery.player.tilePos,20);
		var pixelLocation = Registery.level.getPixelPositionOfTile(tileLocation.x,tileLocation.y);
		var boss:CqMob = CqRegistery.level.createAndaddMob(tileLocation, 99, true);
		boss.visionRadius = 20;
		HxlGraphics.follow(boss, 200);
		CqRegistery.level.updateFieldOfView(HxlGraphics.state,boss);
		//find an empty tile for portal
		var targetLocation:HxlPoint = tileLocation;
		targetLocation.x--;
		HxlGraphics.pushState(new WinState());
		//var boss2:CqMob = CqRegistery.level.createAndaddMob(targetLocation, 99, true);
		//boss.actInDirection(this, targetLocation);
		//CqRegistery.level.updateFieldOfView(HxlGraphics.state,boss);
	}
}
