package cq;

import cq.CqResources;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import haxel.HxlGraphics;
import haxel.HxlState;
import haxel.HxlText;
import haxel.HxlTimer;

class GameOverState extends HxlState{

	var fadeTimer:HxlTimer;
	var fadeTime:Float;
	var waitTime:Float;
	var stateNum:Int;
	var gameOverText:HxlText;

	public override function create():Void {
		super.create();

		fadeTimer = new HxlTimer();
		fadeTime = 0.5;
		waitTime = 2.0;
		stateNum = 0;
		
		stackRender = true;

		gameOverText = new HxlText(0, 220, 640, "Game over");
		gameOverText.setFormat(null, 40, 0xffffff, "center");
		add(gameOverText);

		HxlGraphics.fade.start(false, 0xff000000, fadeTime);
	}

	public override function update():Void {
		super.update();	
		
		if ( stateNum == 0 && fadeTimer.delta() >= fadeTime ) {
			fadeTimer.reset();
			stateNum = 1;
		}
	}

	override function onMouseDown(event:MouseEvent):Void {
		if ( stateNum != 1 ) 
			return;
		nextScreen();
	}

	function nextScreen() {
		stateNum = 2;
		HxlGraphics.fade.start(true, 0xff000000, fadeTime, function() {
			var newState = new MainMenuState();
			HxlGraphics.state = newState;
		}, true);
	}
	
}