package cq.states;

import data.Registery;
import cq.CqResources;
import cq.CqWorld;
import cq.GameUI;
import cq.Main;
import data.SoundEffectsManager;
import data.Configuration;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.geom.Rectangle;
import flash.Lib;
import flash.ui.Mouse;
import flash.display.StageScaleMode;
import flash.display.StageAlign;
import flash.display.StageDisplayState;
import haxel.HxlButton;
import haxel.HxlGraphics;
import haxel.HxlMenu;
import haxel.HxlMenuItem;
import haxel.HxlSprite;
import haxel.HxlSpriteSheet;
import haxel.HxlState;
import haxel.HxlText;
import haxel.HxlTimer;
import data.MusicManager;
import flash.ui.Mouse;
import flash.Lib;
import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Cubic;

import haxel.GraphicCache;
	
#if flash
	import flash.ui.MouseCursor;
	import flash.desktop.NativeApplication;
	import flash.system.Capabilities;
	import flash.ui.ContextMenu;
#end

class MainMenuState extends CqState {
	// from the splash state:
	var waitTime:Float;
	var stateNum:Int;
	
	// from the main menu:
	//public static var instance(getInstance, null):MainMenuState;
	public static var message:String = "";
	private static var _intance:MainMenuState;
	private static var sfxOn:Bool;
	var fadeTimer:HxlTimer;
	// var fadeTime:Float;
	var titleText:HxlSprite;

	var menu:HxlMenu;
	var btnResumeGame:HxlMenuItem;
	var btnNewGame:HxlMenuItem;
	var btnCredits:HxlMenuItem;
	var btnClicked:Bool;

	var btnToggleMusic:HxlButton;
	var btnToggleSFX:HxlButton;
	var musicText:HxlText;
	var sfxText:HxlText;
	var tglMusicIcon:HxlSprite;
	var tglSFXIcon:HxlSprite;
	
	var copyrightLink:HxlText;
	var gamePageLink:HxlText;
	
	var stillSplashing:Bool;
	var buttonsAreUp:Bool;

	public function new()
	{
		super();
		HxlState.musicOn = true;
		sfxOn = true;
		stillSplashing = false;
		buttonsAreUp = false;
	}
	
	override public function destroy() {		
		super.destroy();
		
		//instance = null;
		// todo
	}
	
	private function finishSplashing() {
		if (!stillSplashing) 
			return;
		stillSplashing = false;
		
		MusicManager.play(MenuTheme);
		fadeTimer = new HxlTimer();
		var fadeTime = 0.5;

		var menu = makeMenu();
		Actuate.tween(menu, 1.00, { targetY: 220 } )
			.ease(Cubic.easeOut)
			.onComplete(showAdditionalButtons);		
	}
	
	private function resumeGame() {
		CqLevel.playMusicByIndex(Registery.level.index);
		HxlGraphics.popState();
	}
	
	private function gotoCharState( ) {
		changeState(CreateCharState);
	}
	private function gotoCreditState( ) {
		changeState(CreditsState);
	}

	
	private function makeMenu():HxlMenu {
		menu = new HxlMenu(200, Configuration.app_width, 240, 200);
		add(menu);

		var buttonY:Int = 0;

		var textColor = 0x000000;
		var textHighlight = 0x670000;
		if ( stackId != 0 ) {
			textColor = 0xffffff;
			textHighlight = 0xffff00;

			var btnResumeGame:HxlMenuItem = new HxlMenuItem(0, buttonY, 240, "Resume Game");
			btnResumeGame.setNormalFormat(null, 35, textColor, "center");
			btnResumeGame.setHoverFormat(null, 35, textHighlight, "center");
			menu.addItem(btnResumeGame);
			btnResumeGame.setCallback(resumeGame);
			buttonY += 50;
		}

		var mouseOver= function() {
			SoundEffectsManager.play(MenuItemMouseOver);
		};

		var btnNewGame:HxlMenuItem = new HxlMenuItem(0, buttonY, 240, "New Game", true, null);
		btnNewGame.setNormalFormat(null, 35, textColor, "center");
		btnNewGame.setHoverFormat(null, 35, textHighlight, "center");
		menu.addItem(btnNewGame);
		btnNewGame.setCallback(gotoCharState);
		buttonY += 50;


		if ( stackId == 0 ) {
			var sFadeTime = .5;
			var btnCredits:HxlMenuItem = new HxlMenuItem(0, buttonY, 240, "Credits", true, null);
			btnCredits.setNormalFormat(null, 35, textColor, "center");
			btnCredits.setHoverFormat(null, 35, textHighlight, "center");
			menu.addItem(btnCredits);
			btnCredits.setCallback(gotoCreditState);
			buttonY += 50;

/*			var btnHiscores:HxlMenuItem = new HxlMenuItem(0, buttonY, 240, "Highscores", true, null);
			btnHiscores.setNormalFormat(null, 35, textColor, "center");
			btnHiscores.setHoverFormat(null, 35, textHighlight, "center");
			menu.addItem(btnHiscores);
			btnHiscores.setCallback(function() { HxlGraphics.fade.start(true, 0xff000000, sFadeTime, function() { HxlGraphics.pushState(new HighScoreState()); } ); } );
			buttonY += 50;*/

			//For now we only check for flash
			//At a later point we should have a generic layer that abstracts the tech away
			//Will do this for iOS..

/*			if( SaveLoad.hasSaveGame() )
			{
				// fixme-	should use resume game from above instead
				var btnLoadGame:HxlMenuItem = new HxlMenuItem(0, buttonY, 240, "Load saved game", true, null);
				btnLoadGame.setNormalFormat(null, 35, textColor, "center");
				btnLoadGame.setHoverFormat(null, 35, textHighlight, "center");
				menu.addItem(btnLoadGame);
				btnLoadGame.setCallback(function() {
					if (GameUI.instance != null)
						GameUI.instance.kill();
					self.changeState(GameState);
				});
				buttonY += 50;
			} */
		}
		if (Configuration.standAlone) {
			var btnQuit:HxlMenuItem = new HxlMenuItem(0, buttonY, 240, "Quit", true, null);
			btnQuit.setNormalFormat(null, 35, textColor, "center");
			btnQuit.setHoverFormat(null, 35, textHighlight, "center");
			menu.addItem(btnQuit);

			if (Configuration.air) {
				btnQuit.setCallback(function() {
					NativeApplication.nativeApplication.exit();
				} );
			} else {
				btnQuit.setCallback(function() { Lib.fscommand("quit"); } );
			}

			buttonY += 50;
		}

		menu.setScrollSound(MenuItemMouseOver);
		menu.setSelectSound(MenuItemClick);
		
		return menu;
	}
	
	private function showAdditionalButtons() {
		if (buttonsAreUp) return;
		buttonsAreUp = true;
		
		if ( !Configuration.startWithMusic )
			toggleMusic();

		tglMusicIcon = new HxlSprite(45,0);
		tglMusicIcon.loadGraphic(SpriteSoundToggle, true, false, 48, 48,false,0.5,0.5);
		tglMusicIcon.setFrame(1);

		var musicWidth = 70;
		btnToggleMusic = new HxlButton(Configuration.app_width-musicWidth, 0,musicWidth, 20, toggleMusic, 0, 0);
		btnToggleMusic.add(tglMusicIcon);
		musicText = new HxlText(0, 3, 100, "Music", true, FontAnonymousPro.instance.fontName, 14);
		btnToggleMusic.loadText(musicText);
		btnToggleMusic.setOn(true);
		if (!HxlState.musicOn)
			toggleMusic();
		add(btnToggleMusic);			

		tglSFXIcon = new HxlSprite(45,0);
		tglSFXIcon.loadGraphic(SpriteSoundToggle, true, false, 48, 48,false,0.5,0.5);
		tglSFXIcon.setFrame(1);

		btnToggleSFX = new HxlButton(Std.int(btnToggleMusic.x), Std.int(btnToggleMusic.y+btnToggleMusic.height), musicWidth, 20, toggleSFX, 0, 0);
		btnToggleSFX.add(tglSFXIcon);
		sfxText = new HxlText(0, 3, 100, "Sound", true, FontAnonymousPro.instance.fontName, 14);
		btnToggleSFX.loadText(sfxText);
		btnToggleSFX.setOn(true);
		if (!sfxOn)
			toggleSFX();
		add(btnToggleSFX);

		if ( !Configuration.startWithSound )
			toggleSFX();

			
		var copyright = new HxlText(375, 459, Configuration.app_width - 375 - 123, "Copyright 2011", true, FontAnonymousPro.instance.fontName, 18);
		copyrightLink = new HxlText(copyright.x+copyright.width, 459, 123, "Ido Yehieli", true, FontAnonymousPro.instance.fontName, 18,0x77D2FF);
		copyrightLink.setUnderlined();
		add(copyright);
		add(copyrightLink);
		
		var version = new HxlText(Configuration.app_width-130-2, copyright.y-copyright.height, 130, "Version " + Configuration.version, true, FontAnonymousPro.instance.fontName, 18);
		add(version);
		
		if(!Configuration.standAlone){
			var findOut = new HxlText(0, 0, 260 , "Get stand-alone version at ", true, FontAnonymousPro.instance.fontName, 18);
			add(findOut);
			gamePageLink = new HxlText(findOut.x + findOut.width, 0, 172, "CardinalQuest.com", true, FontAnonymousPro.instance.fontName, 18, 0x77D2FF);
			gamePageLink.setUnderlined();
			add(gamePageLink);
		}

		update();

		if (message != null)
			HxlGraphics.state.add(new HxlText(0, 0, 500, message, true, FontAnonymousProB.instance.fontName, 16));
	}
	
	private function startSplashing() {
		stillSplashing = true;
		
		Mouse.hide();

		if (Configuration.standAlone) {
			Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;

		  #if flash
			if (!StringTools.startsWith(Capabilities.os, "Mac")) {
				// for windows
				//Lib.fscommand("trapallkeys", "true");
				Lib.current.stage.showDefaultContextMenu = false;
			}
		  #end
		}
		var bg = new HxlSprite(0, 0, SpriteMainmenuBg);
		add(bg);

		SoundEffectsManager.play(FortressGate);

		fadeTimer = new HxlTimer();
		var fadeTime = 1;
		waitTime = 0;

		HxlGraphics.fade.start(false, 0xff000000, fadeTime);
		Actuate.tween(titleText, fadeTime, { y: (480 - 50) / 2 - 55 } ).ease(Cubic.easeOut);
			
		Actuate.timer(.30).onComplete(finishSplashing);
	}
	
	public override function create() {
		btnClicked = false;


		if (stackId == 0) {
			Lib.current.stage.scaleMode = StageScaleMode.SHOW_ALL;
			if (Configuration.debug)
				Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
			
			super.create();
			
			Lib.current.stage.align = StageAlign.TOP;
			Lib.current.stage.fullScreenSourceRect = new Rectangle(0, 0, Configuration.app_width, Configuration.app_height);
			
			var bg = new HxlSprite(0, 0, SpriteMainmenuBg);
			add(bg);
			bg.zIndex--;
			
			titleText = new LogoSprite((Configuration.app_width - 345) / 2, - 55);
			add(titleText);
			
			startSplashing();
		} else {
			//blur gamestate
			super.create();
			titleText = new LogoSprite((Configuration.app_width - 345) / 2, (480 - 50) / 2 - 55);
			add(titleText);
			
			stillSplashing = true;
			finishSplashing();
			showAdditionalButtons();
		}
	}
	
	static var homePageRequest:URLRequest = new URLRequest("http://www.tametick.com/");
	static var gamePageRequest:URLRequest = new URLRequest("http://www.cardinalquest.com/");
	override private function onMouseDown(event:MouseEvent) {
		super.onMouseDown(event);
		
		nextScreen();
		
		if (buttonsAreUp) {
			if (copyrightLink!=null && copyrightLink.overlapsPoint(HxlGraphics.mouse.x, HxlGraphics.mouse.y)) {
				Lib.getURL(homePageRequest);
			}
			
			if (gamePageLink != null && gamePageLink.overlapsPoint(HxlGraphics.mouse.x, HxlGraphics.mouse.y)) {
				Lib.getURL(gamePageRequest);
			}
		} else {
			showAdditionalButtons();
		}
	}
	
	private function toggleMusic():Void
	{
		btnToggleMusic.setOn(!btnToggleMusic.getOn());
		var on:Bool = btnToggleMusic.getOn();
		HxlState.musicOn = on;
		if (on)	{
			MusicManager.resume();
			tglMusicIcon.setFrame(1);
		} else {
			MusicManager.pause();
			tglMusicIcon.setFrame(0);
		}
	}
	private function toggleSFX():Void
	{
		btnToggleSFX.setOn(!btnToggleSFX.getOn());
		SoundEffectsManager.enabled = sfxOn = btnToggleSFX.getOn();
		tglSFXIcon.setFrame((sfxOn?1:0));

	}
	
	var TargetState:Class<HxlState>;
	function changeState(TargetState:Class<HxlState>) {
		if (btnClicked)
			return;
		this.TargetState = TargetState;
		btnClicked = true;
		if ( TargetState == null ) {
			HxlGraphics.popState();
			return;
		}
		HxlGraphics.fade.start(true, 0xff000000, .5, fadeStateCallBack, true);
	}

	function fadeStateCallBack():Void{
		//flash.ui.Mouse.cursor = MouseCursor.AUTO;
		var newState = Type.createInstance(TargetState, new Array());
		if ( stackId == 0 ) {
			HxlGraphics.state = newState;
		}
		newState = null;
	}
/*	private static function getInstance():MainMenuState
	{
		if (_intance == null)
		 _intance = new MainMenuState();
		return _intance;
	}*/

	public override function update() {
		super.update();
		setDiagonalCursor();
	}
	
	override function onKeyUp(event:KeyboardEvent) {
		nextScreen();
	}
	
	private function nextScreen() {
		if (stillSplashing) {
			finishSplashing();
		}
	}
}
