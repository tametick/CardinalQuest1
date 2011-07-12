package cq.states;

import cq.CqResources;
import cq.ui.CqTextScroller;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import haxel.HxlGraphics;
import haxel.HxlState;
import haxel.HxlText;
import haxel.HxlTimer;

class CreditsState extends CqState {
	var fadeTime:Float;

	public override function create() {
		super.create();

		//fadeTimer = new HxlTimer();
		fadeTime = 0.5;


		HxlGraphics.fade.start(false, 0xff000000, fadeTime);
		
		var scroller:CqTextScroller = new CqTextScroller(null, 1, "Credits");
		var introText:String = "THis is the credits";
		scroller.addColumn(100, 400, introText, false, FontAnonymousPro.instance.fontName);
		add(scroller);
		scroller.startScroll();
		scroller.onComplete(nextScreen);
	}

	public override function update() {
		super.update();
		setDiagonalCursor();
		
	}

	/*override function onMouseDown(event:MouseEvent) {
		nextScreen();
	}
	
	override function onKeyUp(event:KeyboardEvent) { 
		nextScreen();
	}*/

	function nextScreen() {

		HxlGraphics.fade.start(true, 0xff000000, fadeTime, function() {
			var newState = new MainMenuState();
			HxlGraphics.state = newState;
		}, true);
	}

}
