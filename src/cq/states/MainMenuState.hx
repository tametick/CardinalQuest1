package cq.states;

import cq.CqResources;
import cq.GameUI;
import data.SoundEffectsManager;
import data.Configuration;
import haxel.HxlGraphics;
import haxel.HxlMenu;
import haxel.HxlMenuItem;
import haxel.HxlSprite;
import haxel.HxlState;
import haxel.HxlText;
import haxel.HxlTimer;
import data.MusicManager;
import flash.ui.Mouse;
import flash.ui.MouseCursor;
import flash.Lib;
import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Cubic;


class MainMenuState extends CqState {
	var fadeTimer:HxlTimer;
	var fadeTime:Float;
	var titleText:HxlSprite;

	var menu:HxlMenu;
	var btnResumeGame:HxlMenuItem;
	var btnNewGame:HxlMenuItem;
	var btnCredits:HxlMenuItem;
	var btnClicked:Bool;

	public override function create() {
		btnClicked = false;
		super.create();
		MusicManager.play(MenuTheme);
		fadeTimer = new HxlTimer();
		fadeTime = 0.5;

		titleText = new LogoSprite((640-345)/2, (480-50)/2 - 55);
		add(titleText);

		var copyright = new HxlText(0, 459, 640, "Copyright 2011 Ido Yehieli.",true,FontAnonymousPro.instance.fontName,18);
		add(copyright);
		
		menu = new HxlMenu(200, 640, 240, 200);
		add(menu);

		var self = this;

		var buttonY:Int = 0;

		if ( stackId != 0 ) {
			var btnResumeGame:HxlMenuItem = new HxlMenuItem(0, buttonY, 240, "Resume Game");
			btnResumeGame.setNormalFormat(null, 40, 0xffffff, "center");
			btnResumeGame.setHoverFormat(null, 40, 0xffff00, "center");
			menu.addItem(btnResumeGame);
			btnResumeGame.setCallback(function() { self.changeState(null);});
			buttonY += 50;
		}

		var mouseOver= function() { 
			SoundEffectsManager.play(MenuItemMouseOver);
		};
		
		var btnNewGame:HxlMenuItem = new HxlMenuItem(0, buttonY, 240, "New Game", true, null);
		btnNewGame.setNormalFormat(null, 40, 0xffffff, "center");
		btnNewGame.setHoverFormat(null, 40, 0xffff00, "center");
		menu.addItem(btnNewGame);
		btnNewGame.setCallback(function() { if(GameUI.instance!=null)GameUI.instance.kill();self.changeState(CreateCharState);});
		buttonY += 50;

		var btnCredits:HxlMenuItem = new HxlMenuItem(0, buttonY, 240, "Credits", true, null);
		btnCredits.setNormalFormat(null, 40, 0xffffff, "center");
		btnCredits.setHoverFormat(null, 40, 0xffff00, "center");
		menu.addItem(btnCredits);
		btnCredits.setCallback(function() { self.changeState(CreditsState); });
		buttonY += 50;
		if (Configuration.standAlone) {
			var btnQuit:HxlMenuItem = new HxlMenuItem(0, buttonY, 240, "Quit", true, null);
			btnQuit.setNormalFormat(null, 40, 0xffffff, "center");
			btnQuit.setHoverFormat(null, 40, 0xffff00, "center");
			menu.addItem(btnQuit);
			btnQuit.setCallback(function() { Lib.fscommand("quit"); } );
			
			buttonY += 50;			
		}
		
		Actuate.tween(menu, 1, { targetY: 220 } ).ease(Cubic.easeOut);
		
		menu.setScrollSound(MenuItemMouseOver);
		menu.setSelectSound(MenuItemClick);
	}

	public override function update() {
		super.update();
		setDiagonalCursor();
	}

	function changeState(TargetState:Class<HxlState>) {
		if (btnClicked)
			return;
		
		btnClicked = true;
		var self = this;
		if ( TargetState == null ) {
			HxlGraphics.popState();
			return;
		}
		HxlGraphics.fade.start(true, 0xff000000, fadeTime, function() {
			//flash.ui.Mouse.cursor = MouseCursor.AUTO;
			var newState = Type.createInstance(TargetState, []);
			if ( self.stackId == 0 ) {
				HxlGraphics.state = newState;
			} else {
				if ( TargetState == CreditsState ) {
					HxlGraphics.pushState(new CreditsState());
				} else {
					HxlGraphics.state = newState;
				}
			}	
		}, true);
	}


}
