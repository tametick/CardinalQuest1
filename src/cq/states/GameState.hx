package cq.states;

import com.eclecticdesignstudio.motion.Actuate;
import flash.system.System;
import haxel.HxlGame;

import data.Configuration;
import data.Registery;

import cq.ui.CqPopup;
import cq.ui.CqPotionButton;
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
	static private var msHideDelay:Float = 3;
	var gameUI:GameUI;
	public var chosenClass:CqClass;
	public var isPlayerActing:Bool;
	public var resumeActingTime:Float;//time till when acting is blocked
	public var started:Bool;
	var lastMouse:Bool;
	var endingAnim:Bool;
	
	
	public function clearGameUi() {
		gameUI = null;
	}
	
	public function new() {
		super();
	}
	
	public override function create()
	{
		super.create();
		lastMouse = started = endingAnim = false;
		chosenClass = FIGHTER;
		HxlGraphics.keys.onJustPressed = onKeyJustPressed;
		HxlGraphics.fade.start(false, 0x00000000, 0.25);
		
		//loadingBox = new HxlLoadingBox();
		//add(loadingBox);
		resumeActingTime = msMoveStamp = Timer.stamp();
	}
	public override function destroy() {
		var oldGameUI = gameUI;
		gameUI = null;
		oldGameUI.kill();
		remove(oldGameUI);
		oldGameUI = null;
		
		
		Registery.world.destroy();
		Registery.world = null;

		Registery.player.kill();
		Registery.player = null;

		super.destroy();
		HxlGraphics.keys.onJustPressed = null;
		//remove(Registery.world.currentLevel);
		
		Actuate.reset();
	}
		
	public override function render() {
		if (gameUI != null){
			gameUI.updateCentralBarsPosition();
			
			var currentTile = cast(Registery.level.getTile(Std.int(Registery.player.tilePos.x), Std.int(Registery.player.tilePos.y)), CqTile);
			//stairs popup
			if (HxlUtil.contains(SpriteTiles.stairsDown.iterator(), currentTile.dataNum)) {
				Registery.player.popup.mouseBound = false;
				Registery.player.popup.setText("Click to go downstairs\n[hotkey enter]");
			} else {
				Registery.player.popup.setText("");
			}
			currentTile = null;
		}
			
		super.render();
	}

	
	// This is very odd reduplication -- compare this with my compasses
	static var keys = ["LEFT", "A", "RIGHT", "D", "UP" ,"W" ,"DOWN" ,"S", "ENTER"];
	function justPressedTargetingKey() {
		for (k in keys) {
			if (HxlGraphics.keys.justPressed(k))
				return true;
		}
		return false;
	}
	
	static var keyPressCounter = 0;
	public override function update() {
		super.update();
		
		System.gc();
		System.gc();
		
		if (endingAnim) {
			gameUI.popups.setChildrenVisibility(false);
			cursor.visible = false;
			doEndingAnimation();
			return;
		}
		
		// make sure the game has started
		if (!started) return;
		
		// make sure initialization is complete
		if ( initialized < 1 ) {
			return;
		} else if ( initialized == 1 ) {
			initialized = 2;
			gameUI.updateCharges();
		}
		
		//hide mouse after idle some time	
		if (endingAnim || Timer.stamp() - msMoveStamp > msHideDelay) {
			cursor.visible = false;
		}
		
		// this is not clear to me yet:
		checkInvKeys();
		if ( GameUI.isTargeting) {
			if (Registery.level.getTargetAccordingToKeyPress()!=Registery.player.tilePos && Registery.level.getTargetAccordingToKeyPress()!=null)
				lastMouse = false;
			
			if (!lastMouse) {
				keyPressCounter++;
				if(keyPressCounter>=3 || justPressedTargetingKey()){
					gameUI.updateTargeting(false);
					keyPressCounter = 0;
				}
			} else
				gameUI.updateTargeting(true);
			setDiagonalCursor();
		} else {
			if (isPlayerActing) {
				if ( HxlGraphics.keys.F1 || HxlGraphics.keys.ESCAPE){
					return;
				}
				if (GameUI.instance.panels.currentPanel == null || !GameUI.instance.panels.currentPanel.isBlockingInput) {
					act();
				}
			}
		}
		
		
		//set the actual graphical indicator of the cursor direction
		var target:HxlPoint = Registery.level.getTargetAccordingToMousePosition();
		
		if (gameUI.overlapsPoint( HxlGraphics.mouse.x, HxlGraphics.mouse.y) || target == null || (target.x == 0 && target.y == 0)) {
			setDiagonalCursor();
		} else {
			if (GameUI.isTargeting) {
				setDiagonalCursor();
			} else {
				setDiagonalCursor(target);
			}
		}
		
		target = null;
	}
	
	private function checkResetKeys():Void {
		if (HxlGraphics.keys.justReleased("R")) {
			//SaveLoad.deleteSaveGame();
			HxlGraphics.state = new CreateCharState();
		}
	}
	
	private function checkJumpKeys():Void {
		if (HxlGraphics.keys.justReleased("COMMA") && Registery.world.currentLevelIndex>0) {
			Registery.world.goToNextLevel(Registery.world.currentLevelIndex-1);
		} else if (HxlGraphics.keys.justReleased("PERIOD") && Registery.world.currentLevelIndex<Configuration.lastLevel) {
			Registery.world.goToNextLevel(Registery.world.currentLevelIndex+1);
		}
	}
	private function checkInvKeys():Void
	{
		if (HxlGraphics.keys.justPressed("M")) {
			gameUI.showMapDlg();
		} else if (HxlGraphics.keys.justPressed("I")) {
			gameUI.showInvDlg();
		} else if (HxlGraphics.keys.justPressed("C")) {
			gameUI.showCharDlg();
		}
	}
	private function checkGamePassTurnKeys():Bool {
		// this is the cause of several bugs
		
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
		var player = Registery.player;
		var level = Registery.level;
		
		level.updateFieldOfView(this);
		
		player.actionPoints = 0;

		while (player.actionPoints < 60) {
			level.tick(this);
		}
		
		level.tryToSpawnEncouragingMonster();
		
		gameUI.updateCharges();
		
		// now redraw the map -- but only after all monsters have moved!
		if (Std.is(GameUI.instance.panels.currentPanel,CqMapDialog)) {
			GameUI.instance.panels.currentPanel.updateDialog();
		}
		
		player = null;
		level = null;
	}

	override function init() {
		
		classEntry();
		if(Configuration.debug){
			//Configuration.chestsPerLevel = 100;
			Configuration.spellsPerLevel = 5;
		}
	}
	
	function classEntry() {
		if (scroller != null){
			remove(scroller);
			scroller = null;
		}
		if(Configuration.debug)
			chosenClass = Configuration.debugStartingClass;	
			
		var classBG:Class<Bitmap>;
		var introText:String;
		switch(chosenClass){
			case CqClass.FIGHTER:
				classBG = SpriteKnightEntry;
				//"You enter the dark domicile of the evil minotaur.\n\nIn the distance, you can hear the chatter of the vile creatures that inhabit the depths.\n\nYour adventure begins...";
				introText = "You descend with shining sword into the dismal dwelling of the maleficent minotaur.  The haughty chatter of his servants, twisted and evil, fills the air.\n\nYou smile, for today you will shed much blood.";
			case CqClass.THIEF:
				introText = "You slink silently down unlit stairs.  The minotaur's wicked servants suspect nothing.\n\nYou cannot help but grin at the thought of the bounteous treasure they will soon relinquish.";
				classBG = SpriteThiefEntry;
			case CqClass.WIZARD:
				classBG = SpriteWizardEntry;
				introText = "The unsettled souls of the anguished dead whisper of the minotaur's misdeeds.  On bended knee you swear to them that they will be avenged.\n\nArcane flames dance between your hands.  The minotaur's wretched minions will be the most delightful playthings.";
			default:
				return;
		}
		
		cursor.visible = false;
		scroller = new CqTextScroller(classBG, 1);
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
		var world = Registery.world;
		var player = Registery.player;
		Playtomic.play();

		// create and init the game gui
		// todo: do not recreate if already exists from previous games?
		if (gameUI == null) {
			gameUI = new GameUI();	
			gameUI.zIndex = 50;
			add(gameUI);
			gameUI.initChests();
			gameUI.initHealthBars();
			gameUI.initPopups();
			world.addOnNewLevel(gameUI.panels.panelMap.updateDialog);
			world.addOnNewLevel(gameUI.initPopups);
			
			var player:CqPlayer = Registery.player;
			var pop:CqPopup = new CqPopup(180, "", gameUI.popups);
			gameUI.popups.add(pop);
			player.setPopup(pop);
			
			player = null;
			pop = null;
		}
		
		add(world.currentLevel);
		world.currentLevel.updateFieldOfView(this, true);

		
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
		
		world.addOnNewLevel(onNewLevelCallBack);
		update();
		if (Configuration.debug) {
			player.give(CqSpellType.REVEAL_MAP);
			if(Configuration.debugStartingLevel>0)
				Registery.world.goToNextLevel(Configuration.debugStartingLevel);
		}
		else
			gameUI.dlgPotionGrid.pressHelp(false);
			
			
		world = null;
		player = null;
	}
	function onNewLevelCallBack()
	{
		GameUI.instance.initHealthBars();
	}
	public function initRegistry() {
		if (Registery.world != null)
			Registery.world.destroy();
		
		if (Registery.player != null)
			Registery.player.destroy();
		
		
/*		// populating the registry
		if ( SaveLoad.hasSaveGame() )
		{
			//This does not work, darnation..
			//Registery.world  = SaveLoad.loadWorld();
			//Registery.player = SaveLoad.loadPlayer();
		}
		else
		{*/
			Registery.world = new CqWorld();
			Registery.player = new CqPlayer(chosenClass);
		/*}*/
	}
	
	override function onKeyUp(event:KeyboardEvent) {	
		if (!started || endingAnim) return;
		
		// another direct query of keys -- we'll want to offload most of these checks
		if ( HxlGraphics.keys.justReleased("F1") || HxlGraphics.keys.justReleased("ESCAPE")) {
			// If user was in targeting mode, cancel it
			if ( GameUI.isTargeting ) {
				GameUI.setTargeting(false);
			}
			if (HxlGraphics.keys.justReleased("F1")){
				gameUI.setActive();
				gameUI.dlgPotionGrid.pressHelp(false);
			}else {
				if (GameUI.instance.panels.currentPanel != null)
				{
					gameUI.panels.hideCurrentPanel();
				}else{
					gameUI.setActive();
					gameUI.dlgPotionGrid.pressMenu(false);
				}
			}
		}

		isPlayerActing = false;
		if (Configuration.debug){
			checkJumpKeys();
			checkResetKeys();
			if (HxlGraphics.keys.justReleased("F5")) {
				HxlGraphics.pushState(WhiteState.instance);
			}
		}
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
		if(Registery.level != null && Timer.stamp() > resumeActingTime)
			isPlayerActing = true;
	}
	
	private var scroller:CqTextScroller;
	
	private function tryToActInDirection(facing:HxlPoint):Bool {
		var player = Registery.player;
		var tile = getPlayerTile(facing);
		
		if (tile == null) {
			return false;
		} else if ( !isBlockingMovement(facing) || (Configuration.debugMoveThroughWalls && Configuration.debug)) {
			// move or attack in chosen tile
			player.actInDirection(this, facing);
			
			// if player just attacked don't continue moving
			if (player.justAttacked) {
				resumeActingTime = Timer.stamp() + player.moveSpeed;
				isPlayerActing = false;
			}
			return true;
		} else if (HxlUtil.contains(SpriteTiles.doors.iterator(), tile.dataNum)) {
			// would be great to tell player to open the door, wouldn't it just?
			openDoor(tile);
			return true;
		} else {
			return false;
		}
	}
	
	private function pickBestSlide(facing:HxlPoint):HxlPoint {
		// treating 'facing' as forward, we hold a little competition between 'left' and 'right'
		// -- we want to find which of those two directions gets us in place to move forward soonest.
		// -- and if they tie on that test, we want to pick the one that lets us move forward furthest.
		
		// on your marks
		var player = Registery.player;
					
		var left_ok:Bool = true, right_ok:Bool = true;
		var left_wins:Bool = false, right_wins:Bool = false;
		
		var left = new HxlPoint(-facing.y, -facing.x);
		var right = new HxlPoint(facing.y, facing.x);
		
		
		// get set
		var left_total:HxlPoint = new HxlPoint(0, 0);
		var right_total:HxlPoint = new HxlPoint(0, 0);
		var left_ahead:HxlPoint = new HxlPoint(0, 0);
		var right_ahead:HxlPoint = new HxlPoint(0, 0);
		
		// go!
		while ((left_ok || right_ok) && !(left_wins || right_wins)) {
			if (left_ok) {
				left_total.x = left_total.x + left.x;
				left_total.y = left_total.y + left.y;
				
				var tile = getPlayerTile(left_total);
				if (tile == null || tile.isBlockingMovement()) {
					left_ok = false;
				} else {
					// and can we get somewhere from here?
					left_ahead.x = left_total.x + facing.x;
					left_ahead.y = left_total.y + facing.y;
					
					tile = getPlayerTile(left_ahead);
					
					if (tile != null && (!tile.isBlockingMovement() || (HxlUtil.contains(SpriteTiles.doors.iterator(), tile.dataNum)))) {
						left_wins = true;
					}
				}
			}
			
			if (right_ok) {
				right_total.x = right_total.x + right.x;
				right_total.y = right_total.y + right.y;
				
				var tile = getPlayerTile(right_total);
				if (tile == null || tile.isBlockingMovement()) {
					right_ok = false;
				} else {
					// and can we get somewhere from here?
					right_ahead.x = right_total.x + facing.x;
					right_ahead.y = right_total.y + facing.y;
					
					tile = getPlayerTile(right_ahead);
					
					if (tile != null && (!tile.isBlockingMovement() || (HxlUtil.contains(SpriteTiles.doors.iterator(), tile.dataNum)))) {
						right_wins = true;
					}
				}
			}
		}
		
		if (left_wins && right_wins) {
			// they both turn a corner at the same time, so we'll run them both ahead to see which one hits a wall first
			while (left_ok && right_ok) {
				left_ahead.x = left_ahead.x + facing.x;
				left_ahead.y = left_ahead.y + facing.y;
				
				right_ahead.x = right_ahead.x + facing.x;
				right_ahead.y = right_ahead.y + facing.y;
									
				var tile = getPlayerTile(left_ahead);
				
				if (tile == null || (tile.isBlockingMovement() && !(HxlUtil.contains(SpriteTiles.doors.iterator(), tile.dataNum)))) {
					left_ok = false;
				}
				
				tile = getPlayerTile(right_ahead);
				
				if (tile == null || (tile.isBlockingMovement() && !(HxlUtil.contains(SpriteTiles.doors.iterator(), tile.dataNum)))) {
					right_ok = false;
				}
			}
			
			if (right_ok || left_ok) {
				left_wins = left_wins && left_ok;
				right_wins = right_wins && right_ok;
			}
		}
		
		if (left_wins) return left;
		if (right_wins) return right;
		return null;
	}
	
	private function act() {
		var level = Registery.level, player = Registery.player;
		
		if ( GameUI.isTargeting || !started || endingAnim) {
			isPlayerActing = false;
			return;
		}
		
		if (player.isMoving) {
			// if the player is being animated presently, we can't take key commands
			return;
		}
		
		if (checkGamePassTurnKeys())
		{
			// we check game keys on your turn -- 
			// is this why so many keys waste extra turns?
			// passTurn();
			return;
		}
		
		var isMouseControl:Bool;
		var facing:HxlPoint, tile:CqTile;
		var keyFacing:HxlPoint = level.getTargetAccordingToKeyPress();
		
		if (keyFacing != null ) {
			facing = keyFacing;
			lastMouse = false; //for targeting
			isMouseControl = false;
		} else {
			if (!HxlGraphics.mouse.pressed()) {
				isPlayerActing = false;
				return;
			}
			
			facing = level.getTargetAccordingToMousePosition();
			isMouseControl = true;
		}
		
		if (facing == null) {
			// a facing of null means that neither the mouse nor the keyboard supplied a valid motion
			return;
		}
		
		if (facing.x == 0 && facing.y == 0) {
			// perform actions that happen when the PLAYER SELECTS HIMSELF
			// (this could easily be factored out)
			tile = getPlayerTile(new HxlPoint(0, 0));
			
			if (tile.loots.length > 0) {
				// there is an item here, so let's pick it up
				var item = cast(tile.loots[tile.loots.length - 1], CqItem);
				player.pickup(this, item);
				item = null;
			} else if (HxlUtil.contains(SpriteTiles.stairsDown.iterator(), tile.dataNum)) {
				// these are stairs!  time to descend.
				Registery.world.goToNextLevel();
				player.popup.setText("");
				
				#if demo
				if (Configuration.demoLastLevel == Registery.world.currentLevelIndex-1) {
					MusicManager.stop();
					SoundEffectsManager.play(Win);
					HxlGraphics.pushState(new DemoOverState());
				} 
				#end				
			}
			
			// pass a turn
			isPlayerActing = false;
			passTurn();
			return;
		} else {
			// motion has been requested.  try first, second, and possibly third choices for movement
			// (this is pretty ok sliding -- there's still room to improve it by considering previous motion)
			var moved:Bool = false;
			if (facing.x == 0 || facing.y == 0) {
				if (isMouseControl) {
					moved = tryToActInDirection(facing) || tryToActInDirection(level.getTargetAccordingToMousePosition(true));
				} else {
					moved = tryToActInDirection(facing) || tryToActInDirection(pickBestSlide(facing));
				}
			} else {
				// we need a way to indicate whether facing.x or facing.y should be tried first (maybe something like what the mouse case does)
				moved = tryToActInDirection(new HxlPoint(facing.x, 0)) || tryToActInDirection(new HxlPoint(0, facing.y));
			}
			
			isPlayerActing = moved;
			if (moved) {
				passTurn();
			}
		}
	}
	
	
	private function isBlockingMovement(target:HxlPoint):Bool{
		return Registery.level.isBlockingMovement(Std.int(Registery.player.tilePos.x + target.x), Std.int(Registery.player.tilePos.y + target.y));
	}
	
	
	function getPlayerTile(target:HxlPoint):CqTile {
		if (target == null || Registery.level.getTile(Std.int(Registery.player.tilePos.x + target.x), Std.int(Registery.player.tilePos.y + target.y) ) == null) 
			return null;
		return cast(Registery.level.getTile(Std.int(Registery.player.tilePos.x + target.x), Std.int(Registery.player.tilePos.y + target.y)), CqTile);
	}
	
	
	function openDoor(tile:CqTile) {
		SoundEffectsManager.play(DoorOpen);
		var col = Registery.level.getColor();
		Registery.level.updateTileGraphic(tile.mapX, tile.mapY, SpriteTiles.instance.getSpriteIndex(col + "_door_open"));
	}
	private function startMovingBoss():Void {
		Actuate.timer(1.8).onComplete(gotoWinState);
		//Registery.level.updateFieldOfView(HxlGraphics.state, boss);
		HxlGraphics.follow(boss);		
		//HxlGraphics.follow(boss);
		startedMoving = true;
	}
	private function doEndingAnimation():Void {
		portalSprite.angle -= 0.5;
		if (!startedMoving)
			return;
		HxlGraphics.quake.stop();
		HxlGraphics.follow(boss);
		boss.x = boss.x + BossTargetDir.x*0.4;
		boss.y = boss.y + BossTargetDir.y*0.4;
	}
	private function RemoveGameUI():Void {
		HxlGraphics.quake.start();
		cursor.visible = false;
		gameUI.popups.setChildrenVisibility(false);
		gameUI.destroy();
	}
	private var startedMoving:Bool;
	private var boss:CqMob;
	private var BossTargetDir:HxlPoint;
	private var portalSprite:HxlSprite;
	private var acts:Bool;
	private var bossgroup:HxlGroup;
	public function startBossAnim()	{
		//state vars
		endingAnim = true;
		startedMoving = false;
		bossgroup = new HxlGroup();
		bossgroup.zIndex = 1001;
		add(bossgroup);
		//create minotaur on location
		var bosstilePos:HxlPoint = HxlUtil.getRandomWalkableTileWithDistance(Configuration.getLevelWidth(), Configuration.getLevelHeight(), Registery.level.mapData, Registery.player.tilePos,20);
		
		var bosstilePosX:Int = Math.floor(bosstilePos.x);
		var bosstilePosY:Int = Math.floor(bosstilePos.y);
		var pixelTilePos:HxlPoint = Registery.level.getTilePos(bosstilePosX, bosstilePosY, false);
		
		bossgroup.x = pixelTilePos.x;
		bossgroup.y = pixelTilePos.y;
		boss = CqMobFactory.newMobFromLevel(0, 0, 99);
		bossgroup.add(boss);
		
		Registery.level.updateFieldOfViewByPoint(HxlGraphics.state, bosstilePos, 20, 1);
		boss.visible = true;
		
		//find an empty tile for portal
		BossTargetDir = new HxlPoint(0, 0);
		if (!Registery.level.isBlockingMovement(bosstilePosX, bosstilePosY - 1,false))
		{// y -1 
			BossTargetDir.y = -1;
		}else if (!Registery.level.isBlockingMovement(bosstilePosX, bosstilePosY + 1,false))
		{// y +1 
			BossTargetDir.y = 1;
		}else if (!Registery.level.isBlockingMovement(bosstilePosX-1, bosstilePosY,false))
		{// x -1 
			BossTargetDir.x = -1;
		}else if (!Registery.level.isBlockingMovement(bosstilePosX+1, bosstilePosY,false))
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
			HxlGraphics.state = new WinState();
		}, true);
	}
}
