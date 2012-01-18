package cq.states;

import data.Registery;
import cq.CqResources;
import cq.CqWorld;
import cq.GameUI;
import cq.Main;
import data.Resources;
import data.SoundEffectsManager;
import data.Configuration;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
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
	var btnToggleFullscreen:HxlButton;
	var musicText:HxlText;
	var sfxText:HxlText;
	var fullscreenText:HxlText;
	var tglMusicIcon:HxlSprite;
	var tglSFXIcon:HxlSprite;
	var tglFullscreenIcon:HxlSprite;

	var copyrightLink:HxlText;
	var gamePageLink:HxlText;

	var stillSplashing:Bool;
	var buttonsAreUp:Bool;
	var finishedAddingGuiElements:Bool;

	var updateLoader:URLLoader;
	var updateVersion:String;
	var updateUrl:String;
	var showingUpdate:Bool;

	public function new()
	{
		super();
		
		stillSplashing = false;
		buttonsAreUp = false;
		finishedAddingGuiElements = false;
		
		updateVersion = Configuration.version;
		updateUrl = null;
		showingUpdate = false;
		if ( Configuration.standAlone ) {
			updateLoader = new URLLoader();  
			updateLoader.dataFormat = URLLoaderDataFormat.VARIABLES;  
			updateLoader.addEventListener( Event.COMPLETE, loadedUpdateInfo );  
			updateLoader.addEventListener( IOErrorEvent.IO_ERROR, failedUpdateInfo );
			updateLoader.load(new URLRequest("http://cardinalquest.com/cq_update/cq.txt"));  
		}
	}

	function loadedUpdateInfo( event:Event ) {  
		updateVersion = updateLoader.data.version;
		updateUrl = updateLoader.data.url;
		
		updateLoader.removeEventListener( Event.COMPLETE, loadedUpdateInfo );
		updateLoader.removeEventListener( IOErrorEvent.IO_ERROR, failedUpdateInfo );
	}
	
	function failedUpdateInfo( event:Event ) {
		updateLoader.removeEventListener( Event.COMPLETE, loadedUpdateInfo );
		updateLoader.removeEventListener( IOErrorEvent.IO_ERROR, failedUpdateInfo );
	}

	override public function destroy() {
		super.destroy();

		if ( updateLoader != null ) {
			updateLoader.removeEventListener( Event.COMPLETE, loadedUpdateInfo );
			updateLoader.removeEventListener( IOErrorEvent.IO_ERROR, failedUpdateInfo );
		}
		
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
		Actuate.tween(menu, 1.00, { targetY: HxlGraphics.smallScreen ? 140 : 220 } )
			.ease(Cubic.easeOut)
			.onComplete(showAdditionalButtons);
	}

	private function resumeGame() {
		if(finishedAddingGuiElements) {
			CqLevel.playMusicByIndex(Registery.level.index);
			HxlGraphics.popState();
		}
	}

	private function gotoCharState( ) {
		if(finishedAddingGuiElements)
			changeState(CreateCharState);
	}
	private function gotoCreditState( ) {
		if(finishedAddingGuiElements)
			changeState(CreditsState);
	}


	private function makeMenu():HxlMenu {
		menu = new HxlMenu((HxlGraphics.width - 240) / 2, Configuration.app_width, 240, 200);
		add(menu);

		var buttonY:Int = 0;
		var spacing = HxlGraphics.smallScreen ? 40 : 50;

		var textColor = 0x000000;
		var textHighlight = 0x670000;
		if ( stackId != 0 ) {
			textColor = 0xffffff;
			textHighlight = 0xffff00;

			var btnResumeGame:HxlMenuItem = new HxlMenuItem(0, buttonY, 240, Resources.getString( "MENU_RESUME_GAME" ) );
			btnResumeGame.setNormalFormat(null, 35, textColor, "center");
			btnResumeGame.setHoverFormat(null, 35, textHighlight, "center");
			menu.addItem(btnResumeGame);
			btnResumeGame.setCallback(resumeGame);
			buttonY += spacing;
		}

		var mouseOver= function() {
			SoundEffectsManager.play(MenuItemMouseOver);
		};

		var btnNewGame:HxlMenuItem = new HxlMenuItem(0, buttonY, 240, Resources.getString( "MENU_NEW_GAME" ), true, null);
		btnNewGame.setNormalFormat(null, 35, textColor, "center");
		btnNewGame.setHoverFormat(null, 35, textHighlight, "center");
		menu.addItem(btnNewGame);
		btnNewGame.setCallback(gotoCharState);
		buttonY += spacing;


		if ( stackId == 0 ) {
			var sFadeTime = .5;
			var btnCredits:HxlMenuItem = new HxlMenuItem(0, buttonY, 240, Resources.getString( "MENU_CREDITS" ), true, null);
			btnCredits.setNormalFormat(null, 35, textColor, "center");
			btnCredits.setHoverFormat(null, 35, textHighlight, "center");
			menu.addItem(btnCredits);
			btnCredits.setCallback(gotoCreditState);
			buttonY += spacing;

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
				buttonY += spacing;
			} */
		}
		if (Configuration.standAlone) {
			var btnQuit:HxlMenuItem = new HxlMenuItem(0, buttonY, 240, Resources.getString( "MENU_QUIT" ), true, null);
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

			buttonY += spacing;
		}

		menu.setScrollSound(MenuItemMouseOver);
		menu.setSelectSound(MenuItemClick);

		return menu;
	}

	private function showAdditionalButtons() {
		if (buttonsAreUp)
			return;
		buttonsAreUp = true;
		finishedAddingGuiElements = false;

		tglMusicIcon = new HxlSprite(125,0);
		tglMusicIcon.loadGraphic(SpriteSoundToggle, true, false, 48, 48,false,0.5,0.5);
		tglMusicIcon.setFrame(1);

		var buttonsWidth = 150;
		var textWidth = 123;
		var textYOffset = 4;
		
		btnToggleMusic = new HxlButton(Configuration.app_width-buttonsWidth, 0, buttonsWidth, 20, toggleMusic, 0, 0);
		btnToggleMusic.add(tglMusicIcon);
		musicText = new HxlText(btnToggleMusic.x, btnToggleMusic.y+textYOffset, textWidth, Resources.getString( "MENU_MUSIC" ), true, FontAnonymousPro.instance.fontName, 14, 0xffffff, "right" );
		add(musicText);
		setMusic(HxlState.musicOn);
		add(btnToggleMusic);

		tglSFXIcon = new HxlSprite(125,0);
		tglSFXIcon.loadGraphic(SpriteSoundToggle, true, false, 48, 48,false,0.5,0.5);
		tglSFXIcon.setFrame(1);

		btnToggleSFX = new HxlButton(Std.int(btnToggleMusic.x), Std.int(btnToggleMusic.y+btnToggleMusic.height), buttonsWidth, 24, toggleSFX, 0, 0);
		btnToggleSFX.add(tglSFXIcon);
		sfxText = new HxlText(btnToggleSFX.x, btnToggleSFX.y+textYOffset, textWidth, Resources.getString( "MENU_SOUND" ), true, FontAnonymousPro.instance.fontName, 14, 0xffffff, "right" );
		add(sfxText);
		setSFX(HxlState.sfxOn);
		add(btnToggleSFX);

		if ( Configuration.standAlone ) {
			tglFullscreenIcon = new HxlSprite(125,0);
			tglFullscreenIcon.loadGraphic(SpriteFullscreenToggle, true, false, 48, 48,false,0.5,0.5);
			tglFullscreenIcon.setFrame(1);
			
			var fullscreenWidth = 100;
			btnToggleFullscreen = new HxlButton(Std.int(btnToggleMusic.x), Std.int(btnToggleSFX.y + btnToggleSFX.height) + 6, buttonsWidth, 24, toggleFullscreen, 0, 0);
			btnToggleFullscreen.add(tglFullscreenIcon);
			fullscreenText = new HxlText(btnToggleFullscreen.x, btnToggleFullscreen.y+textYOffset, textWidth, Resources.getString( "MENU_FULLSCREEN" ), true, FontAnonymousPro.instance.fontName, 14, 0xffffff, "right" );
			add(fullscreenText);
			add(btnToggleFullscreen);
			updateFullscreen();
		}
		
		var copyright = new HxlText(HxlGraphics.width - 265, 459 + (HxlGraphics.height - 480), 142, Resources.getString( "MENU_COPYRIGHT" ), true, FontAnonymousPro.instance.fontName, 18);
		add(copyright);

		//Adding porter for ios, I guess android will want to do the same
		//removing link for iOS, it wont work plus it does not seem to work in air either
		if( Configuration.iOS ) {

			copyrightLink = new HxlText(copyright.x+copyright.width, 459, 123, "Ido Yehieli", true, FontAnonymousPro.instance.fontName, 18);
			add(copyrightLink);

			var portedBy = new HxlText(430, copyright.y-copyright.height, 260, Resources.getString( "MENU_PORTEDBY" ) + " Tom Demuyt", true, FontAnonymousPro.instance.fontName, 18);
			add(portedBy);

			var version = new HxlText(Configuration.app_width-150-10, portedBy.y-portedBy.height, 150, Resources.getString( "MENU_VERSION" ) + " " + Configuration.version, true, FontAnonymousPro.instance.fontName, 18, 0xffffff, "right" );
			add(version);

		} else {

			copyrightLink = new HxlText(copyright.x+copyright.width, 459, 123, "Ido Yehieli", true, FontAnonymousPro.instance.fontName, 18,0x77D2FF);
			copyrightLink.setUnderlined();
			add(copyrightLink);

			var version = new HxlText(Configuration.app_width-150-10, copyright.y-copyright.height, 150, Resources.getString( "MENU_VERSION" ) + " " + Configuration.version, true, FontAnonymousPro.instance.fontName, 18, 0xffffff, "right" );
			add(version);
		}

		if(!Configuration.standAlone && !Configuration.mobile){
			var findOut = new HxlText(0, 0, 260 , Resources.getString( "MENU_STANDALONE" ) + " ", true, FontAnonymousPro.instance.fontName, 18);
			add(findOut);
			gamePageLink = new HxlText(findOut.x + findOut.width, 0, 172, "CardinalQuest.com", true, FontAnonymousPro.instance.fontName, 18, 0x77D2FF);
			gamePageLink.setUnderlined();
			add(gamePageLink);
		}

		update();

		if (message != null)
			HxlGraphics.state.add(new HxlText(0, 0, 500, message, true, FontAnonymousProB.instance.fontName, 16));

		finishedAddingGuiElements = true;
	}

	private function startSplashing() {
		stillSplashing = true;

		Mouse.hide();

		var bg = new HxlSprite(0, 0, SpriteMainmenuBg);
		add(bg);
		bg.scaleFullscreen();

		SoundEffectsManager.play(FortressGate);

		fadeTimer = new HxlTimer();
		var fadeTime = 1;
		waitTime = 0;

		HxlGraphics.fade.start(false, 0xff000000, fadeTime);
		
		
		Actuate.tween(titleText, fadeTime, { y: titlePosition} ).ease(Cubic.easeOut);

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
			bg.scaleFullscreen();
			bg.zIndex--;

			titleText = new LogoSprite((Configuration.app_width - 345) / 2, -55);
			add(titleText);

			startSplashing();
		} else {
			//blur gamestate
			super.create();
			titleText = new LogoSprite((Configuration.app_width - 345) / 2, titlePosition);
			add(titleText);

			stillSplashing = true;
			finishSplashing();
			showAdditionalButtons();
		}
	}
	
	private var titlePosition(getTitlePosition, never):Float;
	
	private function getTitlePosition() {
		return (480 - 50) / 2 - 55 - (HxlGraphics.smallScreen ? 80 : 0);
	}

	override private function onMouseDown(event:MouseEvent) {
		super.onMouseDown(event);

		nextScreen();

		var homePageRequest:URLRequest = new URLRequest("http://www.tametick.com/");
		var gamePageRequest:URLRequest = new URLRequest("http://www.cardinalquest.com/");
		
		if (buttonsAreUp) {
			if (copyrightLink!=null && copyrightLink.overlapsPoint(HxlGraphics.mouse.x, HxlGraphics.mouse.y)) {
				Lib.getURL(homePageRequest);
			}

			if (gamePageLink != null && gamePageLink.overlapsPoint(HxlGraphics.mouse.x, HxlGraphics.mouse.y)) {
				if ( Configuration.standAlone ) {
					Lib.getURL(new URLRequest( updateUrl ));
				} else {
					Lib.getURL(gamePageRequest);
				}
			}
		} else {
			showAdditionalButtons();
		}
	}

	private function setMusic(_on:Bool):Void
	{
		btnToggleMusic.setOn(_on);
		HxlState.musicOn = _on;
		if (_on)	{
			MusicManager.resume();
			tglMusicIcon.setFrame(1);
		} else {
			MusicManager.pause();
			tglMusicIcon.setFrame(0);
		}
	}
	
	private function setSFX(_on:Bool):Void
	{
		btnToggleSFX.setOn(_on);
		HxlState.sfxOn = _on;
		SoundEffectsManager.enabled = _on;
		tglSFXIcon.setFrame((_on?1:0));
	}

	private function updateFullscreen():Void
	{
		var isFullscreen:Bool = (Lib.current.stage.displayState != StageDisplayState.NORMAL);
		
		btnToggleFullscreen.setOn(isFullscreen);
		tglFullscreenIcon.setFrame(isFullscreen?1:0);
		
		if ( isFullscreen ) {
			fullscreenText.setText( Resources.getString( "MENU_WINDOWED" ) );
		} else {
			fullscreenText.setText( Resources.getString( "MENU_FULLSCREEN" ) );
		}
	}
	
	private function toggleMusic():Void
	{
		setMusic(!btnToggleMusic.getOn());
	}

	private function toggleSFX():Void
	{
		setSFX(!btnToggleSFX.getOn());
	}

	private function toggleFullscreen():Void
	{
		if(Lib.current.stage.displayState==StageDisplayState.NORMAL){
			Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			Lib.current.stage.fullScreenSourceRect = new Rectangle(0, 0, Configuration.app_width, Configuration.app_height);
		} else{
			Lib.current.stage.displayState = StageDisplayState.NORMAL;
			Lib.current.stage.fullScreenSourceRect = null;
		}
		updateFullscreen();
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
		var newState = Type.createInstance(TargetState, new Array());
		HxlGraphics.state = newState;
		newState = null;
	}

	public override function update() {
		super.update();
		setDiagonalCursor();
		
		if (Configuration.standAlone) {
			if ( !showingUpdate && updateVersion != Configuration.version && updateVersion != null ) {
//				var findOut = new HxlText(0, 0, 260 , "Version " + updateVersion + " available!", true, FontAnonymousPro.instance.fontName, 18);
//				add(findOut);
				gamePageLink = new HxlText(10, 0, 260, Resources.getString( "MENU_UPGRADE1" ) + updateVersion + Resources.getString( "MENU_UPGRADE2" ), true, FontAnonymousPro.instance.fontName, 18, 0x77D2FF);
				gamePageLink.setUnderlined();
				add(gamePageLink);
				
				showingUpdate = true;
			}
		}
	}

	override function onKeyUp(event:KeyboardEvent) {
		nextScreen();

		if ( stackId != 0 && event.keyCode==27) {
			resumeGame();
		}
	}

	private function nextScreen() {
		if (stillSplashing) {
			finishSplashing();
		}
	}
}
