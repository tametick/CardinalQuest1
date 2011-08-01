package cq.states;

import cq.CqResources;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import haxel.HxlGraphics;
import haxel.HxlSprite;
import haxel.HxlState;
import haxel.HxlText;
import haxel.HxlTimer;

class CreditsState extends CqState {
	var fadeTime:Float;

	public override function create() {
		super.create();

		fadeTime = 0.5;
		HxlGraphics.fade.start(false, 0xff000000, fadeTime);
		var text = new HxlSprite(0, 0, SpriteCredits);
		add(text);
	}
	

	public override function update() {
		super.update();
		setDiagonalCursor();
	}

	override function onMouseDown(event:MouseEvent) {
		nextScreen();
	}
	
	override function onKeyUp(event:KeyboardEvent) { 
		nextScreen();
	}

	function nextScreen() {
		HxlGraphics.fade.start(true, 0xff000000, fadeTime, function() {
			HxlGraphics.popState();
		}, true);
	}
}
