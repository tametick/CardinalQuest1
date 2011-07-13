package cq.states;

import cq.CqResources;
import cq.ui.CqTextScroller;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import haxel.HxlGraphics;
import haxel.HxlState;
import haxel.HxlText;
import haxel.HxlTimer;

class GameOverState extends CqState {

	var fadeTime:Float;
	private var scroller:CqTextScroller;

	public override function create() {
		super.create();

		fadeTime = 0.5;
		
		stackRender = true;
		
		scroller = new CqTextScroller(DeathScreen, 1, "Game over",0x657873);
		add(scroller);
		scroller.startScroll();
		scroller.onComplete(nextScreen);
		HxlGraphics.fade.start(false, 0xff000000, fadeTime);
	}

	public override function update() {
		super.update();	
		setDiagonalCursor();
	}

	function nextScreen() {
		HxlGraphics.fade.start(true, 0xff000000, fadeTime, function() {
			var newState = new MainMenuState();
			HxlGraphics.state = newState;
		}, true);
	}
	
}