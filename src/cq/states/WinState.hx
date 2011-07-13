package cq.states;

import cq.CqActor;
import cq.CqResources;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import haxel.HxlGraphics;
import haxel.HxlState;
import haxel.HxlText;
import haxel.HxlTimer;

class WinState extends CqState {

	var fadeTimer:HxlTimer;
	var fadeTime:Float;
	var waitTime:Float;
	var stateNum:Int;
	var gameOverText:HxlText;

	public override function create() {
		super.create();

		fadeTimer = new HxlTimer();
		fadeTime = 0.5;
		waitTime = 2.0;
		stateNum = 0;
		
		stackRender = true;

		gameOverText = new HxlText(0, (480-72)/2, 640, "You Win!");
		gameOverText.setFormat(null, 72, 0xffffff, "center");
		add(gameOverText);
		
		var x:Int = 40;
		var y:Int = 40;
		var boss:CqMob = CqMobFactory.newMobFromLevel(x, y, 99);
		HxlGraphics.follow(boss);
		//HxlGraphics.fade.start(false, 0xff000000, fadeTime);
		
	}

	public override function update() {
		super.update();	
		setDiagonalCursor();
		
		if ( stateNum == 0 && fadeTimer.delta() >= fadeTime ) {
			//fadeTimer.reset();
			//stateNum = 1;
		}
	}

	override function onMouseDown(event:MouseEvent) {
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