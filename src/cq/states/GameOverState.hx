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
	var scroller:CqTextScroller;
	
	var addedKong:Bool;
	static var complete;

	public override function create() {
		super.create();

		addedKong = false;
		complete = false;
		fadeTime = 0.5;
		
		stackRender = true;
		
		scroller = new CqTextScroller(DeathScreen, 1, "Game over",0x657873);
		add(scroller);
		scroller.startScroll();
		scroller.onComplete(nextScreen);
		HxlGraphics.fade.start(false, 0xff000000, fadeTime, function() { complete = true; } );
	}

	public override function update() {
		super.update();	
		setDiagonalCursor();
		if ( HxlGraphics.keys.justReleased("ESCAPE") )
			nextScreen();
			/*
		if (complete && !addedKong) {
			addedKong = true;
			
			// todo: remove later
			var sponsored= new HxlText(10, 10, 135, "Sponsored by",true,FontAnonymousPro.instance.fontName,18);
			add(sponsored);
			var kongLogo = new KongLogoSprite.instance;
			kongLogo.x = 25;
			kongLogo.y = sponsored.y + sponsored.height+5;
			add(kongLogo);
			
			sponsored.zIndex = 1000;
			kongLogo.zIndex = 1000;
		}*/
	}
	
	override private function onKeyUp(event:KeyboardEvent) {
		super.onKeyUp(event);
		
		if (complete)
			nextScreen();
	}
	
	override private function onMouseUp(event:MouseEvent) {
		super.onMouseUp(event);
		
		if (complete)
			nextScreen();		
	}

	public function nextScreen() {
		HxlGraphics.fade.start(true, 0xff000000, fadeTime, function() {
			HxlGraphics.state = MainMenuState.instance;
		}, true);
	}
	
	override public function destroy() {
		super.destroy();
		
		scroller.destroy();
		scroller = null;
		
		// todo: destroy game/level/gameui?
	}
}