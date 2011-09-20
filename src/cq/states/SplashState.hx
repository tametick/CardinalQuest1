package cq.states;

import cq.CqResources;
import data.SoundEffectsManager;
import data.Configuration;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.geom.Rectangle;
import flash.Lib;
import flash.ui.Mouse;
import flash.display.StageScaleMode;
import flash.display.StageAlign;
import flash.display.StageDisplayState;

import haxel.HxlGraphics;
import haxel.HxlSprite;
import haxel.HxlState;
import haxel.HxlText;
import haxel.HxlTimer;
import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Cubic;

#if flash
	import flash.system.Capabilities;
	import flash.ui.ContextMenu;
#end

class SplashState extends CqState {
	var fadeTimer:HxlTimer;
	var fadeTime:Float;
	var waitTime:Float;
	var stateNum:Int;
	var splashText:HxlSprite;
	
	public override function create() {
		Lib.current.stage.scaleMode = StageScaleMode.SHOW_ALL;
		if (Configuration.debug)
			Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;

		super.create();
			
		Lib.current.stage.align = StageAlign.TOP;
		Lib.current.stage.fullScreenSourceRect = new Rectangle(0, 0, Configuration.app_width, Configuration.app_height);
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
		fadeTime = 1;
		waitTime = 0;
		stateNum = 0;

		splashText = new LogoSprite((640-345)/2, -50);
		add(splashText);

		HxlGraphics.fade.start(false, 0xff000000, fadeTime);
		Actuate.tween(splashText, fadeTime, { y: (480 - 50) / 2 - 55 } ).ease(Cubic.easeOut);

		splashText = null;
	}

	public override function update() {
		super.update();
		setDiagonalCursor();

		if ( stateNum == 0 && fadeTimer.delta() >= fadeTime ) {
			fadeTimer.reset();
			stateNum = 1;
		} else if ( stateNum == 1 && fadeTimer.delta() >= waitTime ) {
			nextScreen();
		}
	}

	override function onMouseDown(event:MouseEvent) {
		nextScreen();
	}

	override function onKeyUp(event:KeyboardEvent) {
		nextScreen();
	}

	function nextScreen() {
		if ( stateNum != 1 )
			return;

		stateNum = 2;
		HxlGraphics.state = MainMenuState.instance;
	}

}
