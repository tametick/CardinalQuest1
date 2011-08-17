package cq.states;

import com.eclecticdesignstudio.motion.Actuate;
import cq.CqConfiguration;
import cq.ui.CqPopup;
import cq.ui.CqPotionButton;
import cq.CqRegistery;
import cq.ui.CqSpellButton;
import cq.GameUI;
import cq.ui.CqMapDialog;
import cq.ui.CqTextScroller;
import data.MusicManager;
import flash.display.Bitmap;
import haxe.Stack;
import haxe.Timer;
import haxel.HxlGroup;
import haxel.HxlPoint;
import haxel.HxlSound;
import haxel.HxlState;
import haxel.HxlGraphics;
import haxel.HxlTextInput;
import haxel.HxlTilemap;
import haxel.HxlUtil;
import haxel.HxlSprite;
import world.Actor;

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
	static private var msHideDelay:Float = 3;
	var gameUI:GameUI;
	public var chosenClass:CqClass;
	public var isPlayerActing:Bool;
	public var resumeActingTime:Float;//time till when acting is blocked
	public var started:Bool;
	var lastMouse:Bool;
	var endingAnim:Bool;
	public override function create() {
		inst = this;
		super.create();
		lastMouse = started = endingAnim = false;
		chosenClass = FIGHTER;
		HxlGraphics.keys.onJustPressed = onKeyJustPressed;
		HxlGraphics.fade.start(false, 0x00000000, 0.25);
		cursor.setFrame(SpriteCursor.instance.getSpriteIndex("diagonal"));
		cursor.scrollFactor.y = cursor.scrollFactor.x = 0;
		//loadingBox = new HxlLoadingBox();
		//add(loadingBox);
		resumeActingTime = msMoveStamp = Timer.stamp();
	}
	public override function destroy() {
		inst = null;
		HxlGraphics.keys.onJustPressed = null;
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

	static var keyPressCounter = 0;
	public override function update() {
		super.update();
		if (endingAnim)
		{
			gameUI.hideAllPopups();
			cursor.visible = false;
			doEndingAnimation();
			return;
		}
			
		if (!started) return;
		var up = SpriteCursor.instance.getSpriteIndex("up");
		if ( initialized < 1 ) {
			return;
		} else if ( initialized == 1 ) {
			initialized = 2;
			gameUI.updateCharges();
		}
		//hide mouse after idle some time	
		if (Timer.stamp() - msMoveStamp > msHideDelay || endingAnim) {
			gameUI.hideAllPopups();
			cursor.visible = false;
		}
		
		checkInvKeys();
		if ( GameUI.isTargeting) {
			if (CqRegistery.level.getTargetAccordingToKeyPress()!=CqRegistery.player.tilePos && CqRegistery.level.getTargetAccordingToKeyPress()!=null)
				lastMouse = false;
			
			if (!lastMouse) {
				keyPressCounter++;
				if(keyPressCounter>=5){
					gameUI.updateTargeting(false);
					keyPressCounter = 0;
				}
			} else
				gameUI.updateTargeting(true);
			setDiagonalCursor();
		} else {
			if (isPlayerActing) {
				if ( HxlGraphics.keys.F1 || HxlGraphics.keys.ESCAPE)
					return;
				if (GameUI.currentPanel == null || !GameUI.currentPanel.isBlockingInput) {
					act();
				}
			}
		}
		//set cursor direction
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
	
	private function checkJumpKeys():Void {
		if (HxlGraphics.keys.justReleased("COMMA") && CqRegistery.world.currentLevelIndex>0) {
			CqRegistery.world.goToNextLevel(this, CqRegistery.world.currentLevelIndex-1);
		} else if (HxlGraphics.keys.justReleased("PERIOD") && CqRegistery.world.currentLevelIndex<CqConfiguration.lastLevel) {
			CqRegistery.world.goToNextLevel(this, CqRegistery.world.currentLevelIndex+1);
		}
	}
	private function checkInvKeys():Void
	{
		//open ui
		if (HxlGraphics.keys.justPressed("M"))
		{
			gameUI.showMapDlg();
		}else if (HxlGraphics.keys.justPressed("I"))
		{
			gameUI.showInvDlg();
		}else if (HxlGraphics.keys.justPressed("C"))
		{
			gameUI.showCharDlg();
		}
	}
	private function checkGamePassTurnKeys():Bool {
		var item = null;
		//potions
		if (HxlGraphics.keys.justPressed("SIX"))
		{
			item = gameUI.dlgPotionGrid.cells[0];
		}else if (HxlGraphics.keys.justPressed("SEVEN"))
		{
			item = gameUI.dlgPotionGrid.cells[1];
		}else if (HxlGraphics.keys.justPressed("EIGHT"))
		{
			item = gameUI.dlgPotionGrid.cells[2];
		}else if (HxlGraphics.keys.justPressed("NINE"))
		{
			item = gameUI.dlgPotionGrid.cells[3];
		}else if (HxlGraphics.keys.justPressed("ZERO"))
		{
			item = gameUI.dlgPotionGrid.cells[4];
		}
		if (item != null)
		{
			cast(item, CqPotionCell).potBtn.usePotion();
			return true;
		}
		item = null;
		//spells
		if (HxlGraphics.keys.justPressed("ONE"))
		{
			item = gameUI.dlgSpellGrid.cells[0];
		}else if (HxlGraphics.keys.justPressed("TWO"))
		{
			item = gameUI.dlgSpellGrid.cells[1];
		}else if (HxlGraphics.keys.justPressed("THREE"))
		{
			item = gameUI.dlgSpellGrid.cells[2];
		}else if (HxlGraphics.keys.justPressed("FOUR"))
		{
			item = gameUI.dlgSpellGrid.cells[3];
		}else if (HxlGraphics.keys.justPressed("FIVE"))
		{
			item = gameUI.dlgSpellGrid.cells[4];
		}
		if (item != null)
		{
			cast(item, CqSpellCell).btn.useSpell();
			return true;
		}
		return false;
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
			//CqConfiguration.chestsPerLevel = 100;
			CqConfiguration.spellsPerLevel = 5;
		}
	}
	
	function classEntry() {
		if (scroller != null){
			remove(scroller);
			scroller = null;
		}
		if(Configuration.debug)
			chosenClass = Configuration.debugStartingClass;	
		var classBG:Class<Bitmap> = null;
		switch(chosenClass){
			case CqClass.FIGHTER:
				classBG = SpriteKnightEntry;
			case CqClass.THIEF:
				classBG = SpriteThiefEntry;
			case CqClass.WIZARD:
				classBG = SpriteWizardEntry;
		}
		
		cursor.visible = false;
		scroller = new CqTextScroller(classBG, 1);
		var introText:String = " You enter the dark domicile of the evil minotaur.\n\n In the distance, you can hear the chatter of the vile creatures that inhabit the depths.\n\n Your adventure begins...";
		scroller.addColumn(80, 480, introText, false, FontAnonymousPro.instance.fontName,30);
		add(scroller);
		scroller.startScroll();
		scroller.onComplete(realInit);
	}
	
	function realInit() {
		cursor.visible = true;
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
		if (gameUI == null) {
			gameUI = new GameUI();		
			gameUI.zIndex = 50;
			add(gameUI);
			gameUI.initChests();
			gameUI.initHealthBars();
			gameUI.initPopups();
			world.addOnNewLevel(gameUI.panelMap.updateDialog);
			world.addOnNewLevel(gameUI.initPopups);
			
			var player:CqPlayer = CqRegistery.player;
			var pop:CqPopup = new CqPopup(180, "", gameUI.doodads);
			gameUI.doodads.add(pop);
			player.setPopup(pop);
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
		update();
		if (Configuration.debug) {
			player.give(CqSpellType.REVEAL_MAP);
			CqRegistery.world.goToNextLevel(this, Configuration.debugStartingLevel);
		}
		else
			gameUI.pressHelp(false);
	}
	
	public function initRegistry(){
		// populating the registry
		Registery.world = new CqWorld();
		Registery.player = new CqPlayer(chosenClass);
	}
	
	override function onKeyUp(event:KeyboardEvent) {	
		if (!started || endingAnim) return;
		if ( HxlGraphics.keys.justReleased("F1") || HxlGraphics.keys.justReleased("ESCAPE")) {
			// If user was in targeting mode, cancel it
			if ( GameUI.isTargeting ) {
				GameUI.setTargeting(false);
			}
			if (HxlGraphics.keys.justReleased("F1")){
				gameUI.setActive();
				gameUI.pressHelp(false);
			}else {
				if (GameUI.currentPanel != null)
				{
					gameUI.hideCurrentPanel();
				}else{
					gameUI.setActive();
					gameUI.pressMenu(false);
				}
			}
		}
		isPlayerActing = false;
		if (Configuration.debug)
			checkJumpKeys();
	}
	var msMoveStamp:Float;
	override function onMouseMove(event:MouseEvent)
	{
		msMoveStamp = Timer.stamp();
		cursor.visible = true;
		lastMouse = true;
	}
	override function onMouseDown(event:MouseEvent) {
		if (HxlGraphics.justUnpaused) {
			HxlGraphics.justUnpaused = false;
			return;
		}		
		
		if (!started || endingAnim || Timer.stamp() < resumeActingTime) 
			return;
		if ( GameUI.isTargeting ) {
			gameUI.targetingExecute(true);
			return;
		}

		isPlayerActing = true;
	}
	
	override function onMouseUp(event:MouseEvent) {
		if (!started || endingAnim)
			return;
			
		isPlayerActing = false;
	}
	function onKeyJustPressed(event:KeyboardEvent) {
		if (!started || endingAnim || Timer.stamp() < resumeActingTime) 
			return;
		if(CqRegistery.level != null && Timer.stamp() > resumeActingTime)
			isPlayerActing = true;
	}
	var tmpPoint:HxlPoint;
	private var scroller:CqTextScroller;
	private function act() {
		if ( GameUI.isTargeting || !started || endingAnim) {
			isPlayerActing = false;
			return;
		}
		var level = Registery.level;
		var player = CqRegistery.player;
		if (Registery.player.isMoving)
			return;
		//check game keys on your turn
		if (checkGamePassTurnKeys())
		{
			passTurn();
			return;
		}
		var target:HxlPoint;
		var dx;
		var dy;
		var tile:CqTile;
		var ktg:HxlPoint = level.getTargetAccordingToKeyPress();
		if (ktg != null ) {
			dx =  (player.x + Configuration.zoomedTileSize() / 2);
			dy =  (player.y + Configuration.zoomedTileSize() / 2);
			target = ktg;
			lastMouse = false;//for targeting
		}else {
			if (!HxlGraphics.mouse.pressed()) {
				isPlayerActing = false;
				return;
			}
			dx = HxlGraphics.mouse.x - (player.x+Configuration.zoomedTileSize()/2);
			dy = HxlGraphics.mouse.y - (player.y + Configuration.zoomedTileSize() / 2);
			target = level.getTargetAccordingToMousePosition(dx, dy);
		}
		
		var tile = getPlayerTile(target);
		if (tile == null) {
			if ( !HxlGraphics.keys.justPressed("ENTER") && !HxlGraphics.keys.justPressed("NONUMLOCK_5") && target.x == player.tilePos.x && target.y == player.tilePos.y) {
				isPlayerActing = false;
				return;
			}
			passTurn();
			return;
		}
		//stairs popup
		if (HxlUtil.contains(SpriteTiles.instance.stairsDown.iterator(), tile.dataNum)) {
			player.popup.setText("Click go downstairs\n[hotkey enter]");
		} else {
			player.popup.setText("");
		}
		
		if (Math.abs(dx) < Configuration.zoomedTileSize() && Math.abs(dy) < Configuration.zoomedTileSize() || HxlGraphics.keys.justPressed("ENTER") || HxlGraphics.keys.justPressed("NONUMLOCK_5") ) {
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
				player.pickup(this, item);
			} else if (HxlUtil.contains(SpriteTiles.instance.stairsDown.iterator(), tile.dataNum)) {
				// descend
				Registery.world.goToNextLevel(this);
				player.popup.setText("");
				
				#if demo
				if (CqConfiguration.demoLastLevel == Registery.world.currentLevelIndex-1) {
					MusicManager.stop();
					SoundEffectsManager.play(Win);
					HxlGraphics.pushState(new DemoOverState());
				} 
				#end				
			}
			//clicking on ones-self should only do one turn
			isPlayerActing = false;
			// wait
		} else if ( !isBlockingMovement(target) || (Configuration.debugMoveThroughWalls && Configuration.debug)) {
			// move or attack in chosen tile
			player.actInDirection(this, target);
			// if player just attacked don't continue moving
			if (player.justAttacked) {
				resumeActingTime = Timer.stamp() + player.moveSpeed;
				isPlayerActing = false;
			}
				
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
			if(level.getTargetAccordingToKeyPress()!=null&&level.getTargetAccordingToKeyPress()!=player.tilePos)
				target = level.getTargetAccordingToKeyPress();
			else
				target = level.getTargetAccordingToMousePosition(dx, dy);
				
			tile = getPlayerTile(target);
			if ( !isBlockingMovement(target) ) {
				player.actInDirection(this,target);
			} else if (HxlUtil.contains(SpriteTiles.instance.doors.iterator(), tile.dataNum)){
				openDoor(tile);
			}else
			{
				return;
			}
		}
		
		passTurn();
	}
	
	
	private function isBlockingMovement(target:HxlPoint):Bool{
		return Registery.level.isBlockingMovement(Std.int(Registery.player.tilePos.x + target.x), Std.int(Registery.player.tilePos.y + target.y));
	}
	
	
	function getPlayerTile(target:HxlPoint):CqTile {
		if (target == null ||Registery.level.getTile(Std.int(Registery.player.tilePos.x + target.x), Std.int(Registery.player.tilePos.y + target.y) ) == null) return null;
		return cast(Registery.level.getTile(Std.int(Registery.player.tilePos.x + target.x), Std.int(Registery.player.tilePos.y + target.y)), CqTile);
	}
	
	
	function openDoor(tile:CqTile) {
		SoundEffectsManager.play(DoorOpen);
		var col = CqRegistery.level.getColor();
		Registery.level.updateTileGraphic(tile.mapX, tile.mapY, SpriteTiles.instance.getSpriteIndex(col + "_door_open"));
	}
	private function startMovingBoss():Void
	{
		Actuate.timer(1.8).onComplete(gotoWinState);
		//CqRegistery.level.updateFieldOfView(HxlGraphics.state, boss);
		HxlGraphics.follow(boss);		
		//HxlGraphics.follow(boss);
		startedMoving = true;
	}
	private function doEndingAnimation():Void
	{
		portalSprite.angle -= 0.5;
		if (!startedMoving)
			return;
		HxlGraphics.quake.stop();
		HxlGraphics.follow(boss);
		boss.x = boss.x + BossTargetDir.x*0.4;
		boss.y = boss.y + BossTargetDir.y*0.4;
	}
	private function RemoveGameUI():Void
	{
		HxlGraphics.quake.start();
		cursor.visible = false;
		gameUI.hideAllPopups();
		gameUI.destroy();
	}
	private var startedMoving:Bool;
	private var boss:CqMob;
	private var BossTargetDir:HxlPoint;
	private var portalSprite:HxlSprite;
	private var acts:Bool;
	private var bossgroup:HxlGroup;
	public function startBossAnim()
	{
		//state vars
		endingAnim = true;
		startedMoving = false;
		bossgroup = new HxlGroup();
		bossgroup.zIndex = 1001;
		add(bossgroup);
		//create minotaur on location
		var bosstilePos:HxlPoint = HxlUtil.getRandomWalkableTileWithDistance(CqConfiguration.getLevelWidth(), CqConfiguration.getLevelHeight(), Registery.level.mapData, CqRegistery.player.tilePos,20);
		
		var bosstilePosX:Int = Math.floor(bosstilePos.x);
		var bosstilePosY:Int = Math.floor(bosstilePos.y);
		var pixelTilePos:HxlPoint = CqRegistery.level.getTilePos(bosstilePosX, bosstilePosY, false);
		
		bossgroup.x = pixelTilePos.x;
		bossgroup.y = pixelTilePos.y;
		boss = CqMobFactory.newMobFromLevel(0, 0, 99);
		bossgroup.add(boss);
		
		CqRegistery.level.updateFieldOfViewByPoint(HxlGraphics.state, bosstilePos, 20, 1);
		boss.visible = true;
		
		//find an empty tile for portal
		BossTargetDir = new HxlPoint(0, 0);
		if (!CqRegistery.level.isBlockingMovement(bosstilePosX, bosstilePosY - 1,false))
		{// y -1 
			BossTargetDir.y = -1;
		}else if (!CqRegistery.level.isBlockingMovement(bosstilePosX, bosstilePosY + 1,false))
		{// y +1 
			BossTargetDir.y = 1;
		}else if (!CqRegistery.level.isBlockingMovement(bosstilePosX-1, bosstilePosY,false))
		{// x -1 
			BossTargetDir.x = -1;
		}else if (!CqRegistery.level.isBlockingMovement(bosstilePosX+1, bosstilePosY,false))
		{// x +1 
			BossTargetDir.x = 1;
		}
		//create portal
		
		var ts:Int = Configuration.tileSize;
		var portalPos:HxlPoint = new HxlPoint(boss.x + (ts *2* BossTargetDir.x), boss.y + (ts *2* BossTargetDir.y));
		portalPos.x   -= ts / 2;
		portalPos.y   -= ts / 2;
		portalSprite = new HxlSprite(portalPos.x, portalPos.y, VortexScreen, 0.10, 0.10);
		portalSprite.scrollFactor = boss.scrollFactor;
		bossgroup.add(portalSprite);

		//gameui and start boss anim timer
		Actuate.timer(3).onComplete(startMovingBoss);
		Actuate.timer(2).onComplete(playWinSound);
		Actuate.timer(0.5).onComplete(RemoveGameUI);
	}
	
	private function playWinSound():Void 
	{
		MusicManager.stop();
		SoundEffectsManager.play(Win);
	}
	private function gotoWinState():Void
	{
		HxlGraphics.fade.start(true, 0xff000000, 1, function() {
			var newState = new WinState();
			HxlGraphics.state = newState;
		}, true);
	}
}
