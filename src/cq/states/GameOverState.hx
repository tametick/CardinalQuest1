package cq.states;

import cq.CqResources;
import cq.ui.CqTextScroller;
import flash.display.Loader;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.Lib;
import flash.net.URLRequest;
import haxe.Timer;
import haxel.HxlGraphics;
import haxel.HxlState;
import haxel.HxlText;
import haxel.HxlTimer;

class GameOverState extends CqState {

	var fadeTime:Float;
	var scroller:CqTextScroller;
	
	var kongAdLoader : Loader;
	
	var addedKong:Bool;
	static var complete;

	public override function create() {
		super.create();

		addedKong = false;
		complete = false;
		fadeTime = 0.5;
		
		stackRender = true;
		
		scroller = new CqTextScroller(DeathScreen, 1, "Game over",0x657873,0x010101);
		add(scroller);
		scroller.startScroll();
		scroller.onComplete(nextScreen);
		
		
		kongAdLoader = new Loader();
		try{
			kongAdLoader.load(new URLRequest("http://www.kongnet.net/www/delivery/avw.php?zoneid=11&cb=98732479&n=aab5b069"));
		} catch( msg : String ) {
			trace("1 Error message: " + msg );
		} catch( errorCode : Int ) {
			trace("1 Error #"+errorCode);
		} catch( unknown : Dynamic ) {
			trace("1 Unknown exception: " + Std.string(unknown));
		}
		
		kongAdLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, playKongAd, false, 0, true);	
		
		
		HxlGraphics.fade.start(false, 0xff000000, fadeTime, fadeCallBack );
	}
	
	
	function playKongAd(e : Event) {
		kongAdLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, playKongAd);
		kongAdLoader.addEventListener(MouseEvent.CLICK, clickOnKongAd, false, 0, true);
		
		Timer.delay(showAd, 500);
	}
	
	function showAd() {
		addChild(kongAdLoader);
		kongAdLoader.width *= 1.2;
		kongAdLoader.x = (640 - kongAdLoader.width) / 2;
		kongAdLoader.y = (410 - kongAdLoader.height) / 2;
	}
	
	function clickOnKongAd(e : Event) {
		var request : URLRequest;
		try {
			request = new URLRequest("http://www.kongnet.net/www/delivery/ck.php?n=aab5b069&cb=783912374");
			Lib.getURL(request);
		} catch( msg : String ) {
			trace("2 Error message: " + msg );
		} catch( errorCode : Int ) {
			trace("2 Error #"+errorCode);
		} catch( unknown : Dynamic ) {
			trace("2 Unknown exception: " + Std.string(unknown));
		}
		
		request = null;
	}
	
	private function fadeCallBack():Void 
	{
		complete = true;
	}

	public override function update() {
		super.update();	
		setDiagonalCursor();
		if ( HxlGraphics.keys.justReleased("ESCAPE") )
			nextScreen();
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
		HxlGraphics.fade.start(true, 0xff000000, fadeTime, nextScreenFadeCallback, true);
	}
	
	function nextScreenFadeCallback()
	{
		HxlGraphics.state = MainMenuState.instance;
	}
	override public function destroy() {
		super.destroy();
		
		scroller.destroy();
		scroller = null;
		
		// todo: destroy game/level/gameui?
	}
}