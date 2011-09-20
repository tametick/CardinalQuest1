package cq.states;

import data.Registery;
import cq.CqResources;
import cq.CqWorld;
import cq.GameUI;
import cq.Main;
import data.SoundEffectsManager;
import data.Configuration;
import data.SaveLoad;
import flash.events.MouseEvent;
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
#end

class MainMenuState extends CqState {
	public static var instance(getInstance, null):MainMenuState;
	public static var message:String = "";
	private static var _intance:MainMenuState;
	private static var sfxOn:Bool;
	var fadeTimer:HxlTimer;
	var fadeTime:Float;
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

	public function new()
	{
		super();
		HxlState.musicOn = true;
		sfxOn = true;
	}
	public override function create() {
		btnClicked = false;
		super.create();

		MusicManager.play(MenuTheme);
		fadeTimer = new HxlTimer();
		fadeTime = 0.5;


		if (stackId == 0) {
			var bg = new HxlSprite(0, 0, SpriteMainmenuBg);
			add(bg);
			bg.zIndex--;
		}else
		{
			//blur gamestate
		}

		titleText = new LogoSprite((Configuration.app_width - 345) / 2, (480 - 50) / 2 - 55);
		add(titleText);

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

		if ( !Configuration.startWithMusic )
			toggleMusic();

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

		var copyright = new HxlText(370, 459, Configuration.app_width-370, "Copyright 2011 Ido Yehieli.", true, FontAnonymousPro.instance.fontName, 18);
		add(copyright);

		/*
		var sponsored= new HxlText(10, 10, 135, "Sponsored by",true,FontAnonymousPro.instance.fontName,18);
		add(sponsored);
		var kongLogo = KongLogoSprite.instance;
		kongLogo.x = 25;
		kongLogo.y = sponsored.y + sponsored.height+5;
		add(kongLogo);
		// only add event listener once!
		/*if(!kongLogo.isAdded){
			kongLogo.addEventListener(MouseEvent.CLICK, clickOnKong);
			kongLogo.isAdded = true;
		}*/


		menu = new HxlMenu(200, Configuration.app_width, 240, 200);
		add(menu);
		var self = this;

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
			btnResumeGame.setCallback(function() {
				CqLevel.playMusicByIndex(Registery.level.index);
				self.changeState(null);
			});
			buttonY += 50;
		}

		var mouseOver= function() {
			SoundEffectsManager.play(MenuItemMouseOver);
		};

		var btnNewGame:HxlMenuItem = new HxlMenuItem(0, buttonY, 240, "New Game", true, null);
		btnNewGame.setNormalFormat(null, 35, textColor, "center");
		btnNewGame.setHoverFormat(null, 35, textHighlight, "center");
		menu.addItem(btnNewGame);
		btnNewGame.setCallback(function() {
			SaveLoad.deleteSaveGame();
			if (GameUI.instance != null){
				GameUI.instance.kill();
			}
			self.changeState(CreateCharState);
			});
		buttonY += 50;


		if ( stackId == 0 ) {
			var sFadeTime = fadeTime;
			var btnCredits:HxlMenuItem = new HxlMenuItem(0, buttonY, 240, "Credits", true, null);
			btnCredits.setNormalFormat(null, 35, textColor, "center");
			btnCredits.setHoverFormat(null, 35, textHighlight, "center");
			menu.addItem(btnCredits);
			btnCredits.setCallback(function() { HxlGraphics.fade.start(true, 0xff000000, sFadeTime, function() { HxlGraphics.pushState(new CreditsState()); } ); } );
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

			if( SaveLoad.hasSaveGame() )
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
			}
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

		Actuate.tween(menu, 1, { targetY: 220 } ).ease(Cubic.easeOut);

		menu.setScrollSound(MenuItemMouseOver);
		menu.setSelectSound(MenuItemClick);
		update();

		if (message != null)
			HxlGraphics.state.add(new HxlText(0, 0, 500, message, true, FontAnonymousProB.instance.fontName, 16));
	}

	public override function update() {
		super.update();
		setDiagonalCursor();
	}
	private function toggleMusic():Void
	{
		btnToggleMusic.setOn(!btnToggleMusic.getOn());
		var on:Bool = btnToggleMusic.getOn();
		HxlState.musicOn = on;
		if (on)
		{
			MusicManager.resume();
			tglMusicIcon.setFrame(1);
		}else
		{
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
		var self = this;
		if ( TargetState == null ) {
			HxlGraphics.popState();
			return;
		}
		HxlGraphics.fade.start(true, 0xff000000, fadeTime, fadeStateCallBack, true);
	}

	function fadeStateCallBack():Void
	{
		//flash.ui.Mouse.cursor = MouseCursor.AUTO;
		var newState = Type.createInstance(TargetState, new Array());
		if ( stackId == 0 ) {
			HxlGraphics.state = newState;
		} else {
			if ( TargetState == CreditsState ) {
				HxlGraphics.pushState(new CreditsState());
			} else {
				HxlGraphics.state = newState;
			}
		}
	}
	private static function getInstance():MainMenuState
	{
		if (_intance == null)
		 _intance = new MainMenuState();
		return _intance;
	}

}
