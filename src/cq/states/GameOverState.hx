package cq.states;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Cubic;
import cq.CqResources;
import cq.ui.CqTextScroller;
import data.Configuration;
import data.Resources;
import data.SoundEffectsManager;
import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.Lib;
import flash.net.URLRequest;
import haxe.Timer;
import haxel.HxlGraphics;
import haxel.HxlMenu;
import haxel.HxlMenuItem;
import haxel.HxlSprite;
import haxel.HxlState;
import haxel.HxlText;
import haxel.HxlTimer;

class GameOverState extends CqState {

	static var fadeTime:Float;
	var scroller:CqTextScroller;
	
	var menu:HxlMenu;
	var btnClicked:Bool;
	
	var sponsorSplash : HxlSprite;
	var sponsorFade : Bool;
	
	public var kongAd : Sprite;
	var kongAdLoader : Loader;
	
	var addedKong:Bool;
	static var complete;

	public override function create() {
		super.create();

		addedKong = false;
		complete = false;
		fadeTime = 0.5;
		
		stackRender = true;
		
		scroller = new CqTextScroller(DeathScreen, 1, Resources.getString( "MENU_GAME_OVER" ),0x657873,0x010101);
		add(scroller);
		scroller.startScroll();
		scroller.onComplete(goToMenu);
		scroller.zIndex--;
		
		if (!Configuration.standAlone && Configuration.allowKongregateAds) {
			kongAd = new Sprite();
			kongAdLoader = new Loader();
			try{
				kongAdLoader.load(new URLRequest("http://www.kongnet.net/www/delivery/avw.php?zoneid=11&cb=98732479&n=aab5b069"));
				kongAdLoader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, kongAdFailed );
			} catch( msg : String ) {
				trace("1 Error message: " + msg );
			} catch( errorCode : Int ) {
				trace("1 Error #"+errorCode);
			} catch( unknown : Dynamic ) {
				trace("1 Unknown exception: " + Std.string(unknown));
			}
			
			kongAdLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, playKongAd, false, 0, true);	
		}
		
		sponsorSplash = null;
		if (!Configuration.standAlone && Configuration.isArmorSponsored) {
			sponsorSplash = new HxlSprite( 0, 0, ArmorGames );
			sponsorSplash.alpha = 1.0;
			add(sponsorSplash);
			sponsorSplash.alpha = 0.0;
			sponsorFade = false;

			Actuate.timer(1.2).onComplete(beginSponsorFade);
		//	Actuate.update(
		}
		
		menu = new HxlMenu(200, Configuration.app_width, 240, 200);
		add(menu);
		
		var buttonY:Int = 0;

		var textColor = 0x657873;
		var textHighlight = 0x670000;
		
		var btnNewGame:HxlMenuItem = new HxlMenuItem(0, buttonY, 240, Resources.getString( "MENU_NEW_GAME" ), true, null);
		btnNewGame.setNormalFormat(null, 35, textColor, "center");
		btnNewGame.setHoverFormat(null, 35, textHighlight, "center");
		menu.addItem(btnNewGame);
		btnNewGame.setCallback(function() {
			nextScreen("game");
		});
		buttonY += 50;

		var btnMenu:HxlMenuItem = new HxlMenuItem(0, buttonY, 240, Resources.getString( "MENU_MAIN_MENU" ), true, null);
		btnMenu.setNormalFormat(null, 35, textColor, "center");
		btnMenu.setHoverFormat(null, 35, textHighlight, "center");
		menu.addItem(btnMenu);
		btnMenu.setCallback(function() {
			nextScreen("menu");
		});
		buttonY += 50;
		
		menu.setScrollSound(MenuItemMouseOver);
		menu.setSelectSound(MenuItemClick);
		Actuate.tween(menu, 1, { targetY: 325 } ).ease(Cubic.easeOut);
		
		update();
		
		HxlGraphics.fade.start(false, 0xff000000, fadeTime, fadeCallBack );
	}
	
	function kongAdFailed( e : IOErrorEvent ) {
		kongAdLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, kongAdFailed);
		kongAdLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, playKongAd);
	}
	
	function playKongAd(e : Event) {
		kongAdLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, kongAdFailed);
		kongAdLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, playKongAd);
		kongAd.addEventListener(MouseEvent.CLICK, clickOnKongAd, false, 0, true);
		
		Timer.delay(showAd, 500);
	}
	
	function showAd() {
		addChild(kongAd);
		kongAd.addChild(kongAdLoader);
		kongAd.buttonMode = true;
		kongAd.mouseChildren = false;
		kongAdLoader.width *= 1.1;
		kongAd.width = kongAdLoader.width;
		kongAd.x = (640 - kongAdLoader.width) / 2;
		kongAd.y = (410 - kongAdLoader.height) / 2;
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

	function beginSponsorFade():Void
	{
		sponsorFade	= true;
	}
	
	public override function update() {
		super.update();	
		
		if ( sponsorSplash != null && sponsorFade ) {
			sponsorSplash.alpha = Math.min( 1.0, sponsorSplash.alpha + 1.5*HxlGraphics.elapsed );
		}

		setDiagonalCursor();
		if ( HxlGraphics.keys.justReleased("ESCAPE") )
			nextScreen("menu");
	}
	
	override function onMouseDown(event:MouseEvent) {
		if ( sponsorSplash != null && sponsorSplash.overlapsPoint( HxlGraphics.mouse.x, HxlGraphics.mouse.y) ) {
			if ( Configuration.isArmorSponsored ) {
				var request : URLRequest = new URLRequest("http://armorgames.com/");
				Lib.getURL(request);
				request = null;
			}
		}
	}	
	/*
	override private function onKeyUp(event:KeyboardEvent) {
		super.onKeyUp(event);
		
		if (complete)
			nextScreen("menu");
	}
	
	override private function onMouseUp(event:MouseEvent) {
		super.onMouseUp(event);
		
		if (complete)
			nextScreen("menu");		
	}*/
	
	public static function nextScreen(state:String) {
		switch(state) {
			case "menu":
				HxlGraphics.fade.start(true, 0xff000000, fadeTime, menuFadeCallback, true);
			case "game":
				HxlGraphics.fade.start(true, 0xff000000, fadeTime, gameFadeCallback, true);	
		}
	}
	
	function goToMenu() {
		HxlGraphics.fade.start(true, 0xff000000, fadeTime, menuFadeCallback, true);
	}
	
	static function menuFadeCallback()	{
		HxlGraphics.state = new MainMenuState();
	}
	
	static function gameFadeCallback() {
		HxlGraphics.state = new CreateCharState();
	}
	override public function destroy() {
		super.destroy();
		
		scroller.destroy();
		scroller = null;
		
		// todo: destroy game/level/gameui?
	}
}