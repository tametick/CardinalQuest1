package cq.states;

import cq.CqResources;
import data.SoundEffectsManager;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import haxel.HxlGraphics;
import haxel.HxlSprite;
import haxel.HxlState;
import haxel.HxlText;
import haxel.HxlTimer;
import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Cubic;

class SplashState extends CqState {
	var fadeTimer:HxlTimer;
	var fadeTime:Float;
	var waitTime:Float;
	var stateNum:Int;
	var splashText:HxlSprite;

	public override function create() {
		SoundEffectsManager.play(FortressGate);
		super.create();

		fadeTimer = new HxlTimer();
		fadeTime = 1;
		waitTime = 0;
		stateNum = 0;

		splashText = new LogoSprite((640-345)/2, -50);
		add(splashText);

		HxlGraphics.fade.start(false, 0xff000000, fadeTime);
		Actuate.tween(splashText, fadeTime, { y: (480-50)/2 - 55 }).ease(Cubic.easeOut);
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
		HxlGraphics.state = new MainMenuState();
	}

}
