package kongloader;

import flash.external.ExternalInterface;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.Sprite;
import flash.display.StageScaleMode;
import flash.display.StageAlign;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.Lib;
import flash.net.URLRequest;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.ByteArray;
import haxe.Timer;

class Preloader extends MovieClip {
	var progressBarBG : Shape;
	var progressBar : Shape;
	
	public var kongAd : Sprite;
	var kongAdLoader : Loader;
	var adSeen:Bool;
	
	public static function main()
	{
		Lib.current.addChild(new Preloader());
	}
	
	public function new()
	{
		super();

		adSeen = false;
		
		Lib.current.stage.scaleMode = StageScaleMode.SHOW_ALL;
		Lib.current.stage.align = StageAlign.TOP;

		// Site lock.
		var sitelock:Bool = true;
		if ( ExternalInterface.available ) {
			// Site lock check.
			var browserurl = flash.external.ExternalInterface.call("function(){return window.location.href}").toString();	
			
			var firstSplit = browserurl.split("://");
			var domain1 = firstSplit[0];
			var domain2 = firstSplit[1].split("/")[0];
			
			if ( domain1 == "armorgames.com" || domain1 == "www.armorgames.com" || domain2 == "armorgames.com" || domain2 == "www.armorgames.com" )
//			if ( domain1 == "wootfu.com" || domain1 == "www.wootfu.com" || domain2 == "wootfu.com" || domain2 == "www.wootfu.com" )
			{
				sitelock = false;
			}
		}
		
		if ( sitelock ) {
			var text = new TextField();
			var format1 = new TextFormat();
			var format2 = new TextFormat();
			var length:Int;
			
			format1.bold = false;
			format1.color = 0xffffff;
			format1.size = 16;

			format2.bold = true;
			format2.color = 0xffff00;
			format2.size = 16;
			
			text.x = 10;
			text.y = 10;
			text.width = 620;
			text.height = 460;
			text.textColor = 0xffffff;
			text.wordWrap = true;
			text.appendText( "This version of the game is site locked to ArmorGames.com.\n\nPlease visit " );
			length = text.length;
			text.setTextFormat( format1 );
			text.appendText( "http://ArmorGames.com/" );
			text.setTextFormat( format2, length, text.length );
			length = text.length;
			text.appendText( " or " );
			text.setTextFormat( format1, length, text.length );
			length = text.length;
			text.appendText( "http://CardinalQuest.com/" );
			text.setTextFormat( format2, length, text.length );
			length = text.length;
			text.appendText( " to play Cardinal Quest." );
			text.setTextFormat( format1, length, text.length );
			length = text.length;
			addChild( text );
		} else {
			addEventListener(Event.ENTER_FRAME, checkFrame, false, 0, true);
			progressBarBG = new Shape();
			var g : Graphics = progressBarBG.graphics;
			g.lineStyle(2.0, 0xFFFFFF);
			g.drawRect(0, 0, 400, 20);
			addChild(progressBarBG);
			g = null;
			progressBarBG.x = (640 - 400) / 2;
			progressBarBG.y = 400;
			progressBar = new Shape();
			g = progressBar.graphics;
			g.beginFill(0x800000);
			g.drawRect(1, 1, 400 - 2, 20 - 2);
			g = null;
			addChild(progressBar);
			progressBar.x = progressBarBG.x;
			progressBar.y = progressBarBG.y;
			progressBar.scaleX = 0;
	/*		
			kongAd = new Sprite();
			kongAdLoader = new Loader();
			try {
				var urlr = new URLRequest("http://www.kongnet.net/www/delivery/avw.php?zoneid=11&cb=98732479&n=aab5b069");
				kongAdLoader.load(urlr);
				kongAdLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, playKongAd, false, 0, true);
			} catch( msg : String ) {
				//trace("1 Error message : " + msg );
			} catch( errorCode : Int ) {
				//trace("1 Error #" + errorCode);
			} catch( unknown : Dynamic ) {
				//trace("1 Unknown exception : " + Std.string(unknown));
			} 
	*/		
		}
	}
/*	
	function playKongAd(e : Event) : Void
	{
		try{
			kongAdLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, playKongAd);
			kongAd.addEventListener(MouseEvent.CLICK, clickOnKongAd, false, 0, true);
			
			
			addChild(kongAd);
			kongAd.addChild(kongAdLoader);
			kongAd.buttonMode = true;
			kongAd.mouseChildren = false;
			kongAd.width = kongAdLoader.width;
			kongAd.x = (640 - kongAdLoader.width) / 2;
			kongAd.y = (400 - kongAdLoader.height) / 2;
			
			Timer.delay(markAdAsSeen, 1000);
		} catch( msg : String ) {
			//trace("1 Error message : " + msg );
		} catch( errorCode : Int ) {
			//trace("1 Error #" + errorCode);
		} catch( unknown : Dynamic ) {
			//trace("1 Unknown exception : " + Std.string(unknown));
		}  
	}

	function clickOnKongAd(e : Event) : Void
	{
		var request : URLRequest;
		try {
			request = new URLRequest("http://www.kongnet.net/www/delivery/ck.php?n=aab5b069&cb=783912374");
			Lib.getURL(request);
		} catch( msg : String ) {
			//trace("2 Error message : " + msg );
		} catch( errorCode : Int ) {
			//trace("2 Error #" + errorCode);
		} catch( unknown : Dynamic ) {
			//trace("2 Unknown exception : " + Std.string(unknown));
		} catch ( error:IOErrorEvent) {
			//trace("1 IOErrorEvent: " + Std.string(error));
		} 
		
		request = null;
	}
	
	function markAdAsSeen() {
		adSeen = true;
	}
*/
	function checkFrame(e : Event) : Void
	{
		progressBar.scaleX = root.loaderInfo.bytesLoaded / root.loaderInfo.bytesTotal;
		
		var timeLine = cast(this.parent, MovieClip);
		
		if(timeLine.currentFrame  == timeLine.totalFrames)
		{
/*			
			kongAdLoader.removeEventListener(MouseEvent.CLICK, clickOnKongAd);
			try{
				removeChild(kongAd);
				kongAd.removeChild(kongAdLoader);
				kongAdLoader.unloadAndStop();
			} catch( unknown : Dynamic ) {
				//trace("2 Unknown exception : " + Std.string(unknown));
			}
			
			kongAdLoader = null;
			kongAd = null;
*/
			cast(this.parent, MovieClip).stop();
			loadingFinished();
//		} else if (timeLine.currentFrame == timeLine.totalFrames) {
//			Timer.delay(markAdAsSeen, 3000);
		}
		timeLine = null;
	}
	function loadingFinished() : Void
	{
		removeEventListener(Event.ENTER_FRAME, checkFrame);
		removeChild(progressBar);
		removeChild(progressBarBG);
		startup();
	}
	function startup() : Void
	{
		//var mainClass : Class<Dynamic> = cast( Type.resolveClass("kongloader.KongMain") , Class<Dynamic>);
		//addChild(cast(Type.createInstance(mainClass,[]), DisplayObject));
		//mainClass = null;
		addChild(new KongMain());
	}
}
