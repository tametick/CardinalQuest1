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

	public override function create() {
		super.create();

		fadeTime = 0.5;
		
		stackRender = true;

		//game over message?
		//you're food for the minions now
		//rest in peace
		//your body crumbles, your soul fades away
		//You succumb to a greater foe
		//You breathe your' last
		var scroller:CqTextScroller = new CqTextScroller(null, 1, "You breathe your' last",0x990000);
		var Text:String = "The evil forces were too strong for you,\n now you perish for eternity...";
		scroller.addColumn(200, 400, Text, false, FontAnonymousPro.instance.fontName,20,0x990000);
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