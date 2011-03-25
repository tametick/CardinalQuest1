package cq;

import cq.CqResources;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import haxel.HxlGraphics;
import haxel.HxlState;
import haxel.HxlText;
import haxel.HxlTimer;

class CreditsState extends HxlState
{

	var fadeTimer:HxlTimer;
	var fadeTime:Float;
	var waitTime:Float;
	var stateNum:Int;
	var creditsText:HxlText;

	public override function create():Void {
		super.create();

		fadeTimer = new HxlTimer();
		fadeTime = 0.5;
		waitTime = 2.0;
		stateNum = 0;

		creditsText = new HxlText(0, 220, 640, "Credits Screen");
		creditsText.setFormat(null, 40, 0xffffff, "center");
		add(creditsText);

		HxlGraphics.fade.start(false, 0xff000000, fadeTime);
		HxlGraphics.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
	}

	public override function update():Void {
		super.update();	
		
		if ( stateNum == 0 && fadeTimer.delta() >= fadeTime ) {
			fadeTimer.reset();
			stateNum = 1;
		} 
		/*else if ( stateNum == 1 && fadeTimer.delta() >= waitTime ) {
			nextScreen();
		}*/
	}

	function onMouseDown(event:MouseEvent):Void {
		if ( stateNum != 1 ) return;
		nextScreen();
	}

	function nextScreen() {
		stateNum = 2;
		HxlGraphics.fade.start(true, 0xff000000, fadeTime, function() {
			var newState = new MainMenuState();
			HxlGraphics.state = newState;
		}, true);
		HxlGraphics.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);	
	}

}
