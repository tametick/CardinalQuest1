package cq.states;

import cq.CqResources;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import haxel.HxlGraphics;
import haxel.HxlState;
import haxel.HxlText;
import haxel.HxlTimer;

class SplashState extends HxlState
{

	var fadeTimer:HxlTimer;
	var fadeTime:Float;
	var waitTime:Float;
	var stateNum:Int;
	var splashText:HxlText;

	public override function create():Void {
		super.create();

		fadeTimer = new HxlTimer();
		fadeTime = 0.5;
		waitTime = 2.0;
		stateNum = 0;

		splashText = new HxlText(0, (480-72)/2, 640, "Cardinal Quest");
		splashText.setFormat(null, 72, 0xffffff, "center");
		add(splashText);

		HxlGraphics.fade.start(false, 0xff000000, fadeTime);
	}

	public override function update():Void {
		super.update();	
		
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
		HxlGraphics.fade.start(true, 0xff000000, fadeTime, function() {
			var newState = new MainMenuState();
			HxlGraphics.state = newState;
		}, true);
	}

}
