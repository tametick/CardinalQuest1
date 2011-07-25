package cq.states;

import cq.CqResources;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import haxel.HxlGraphics;
import haxel.HxlSprite;

class HelpState extends CqState {

	public override function create() {
		super.create();
		var overlay:HxlSprite = new HxlSprite(0, 0, SpriteHelpOverlay);
		overlay.x = -7;
		overlay.y = -48;
		add(overlay);
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
		HxlGraphics.popState();
	}

}
