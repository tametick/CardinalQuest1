package kongloader;

import flash.errors.Error;
import flash.external.ExternalInterface;
import flash.display.Bitmap;
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
import flash.system.Security;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.ByteArray;
import haxe.Timer;

extern class AndKonLogo extends Bitmap {}

class Preloader extends MovieClip {
	var progressBarBG : Shape;
	var progressBar : Shape;
	
	var sprite : Sprite;
	var logo : Bitmap;
	
	public static function main()
	{
		Lib.current.addChild(new Preloader());
	}
	
	public function new()
	{
		super();

		Lib.current.stage.scaleMode = StageScaleMode.SHOW_ALL;
		Lib.current.stage.align = StageAlign.TOP;

		// Site lock.
		var sitelock:Bool = true;
		if ( ExternalInterface.available ) {
			// Site lock check.
			var browserurl:String = Lib.current.root.loaderInfo.url;
			
			var firstSplit = browserurl.split("://");
			var domain = (firstSplit[1] != null) ? firstSplit[1] : firstSplit[0];

			var domain2:String = domain.split("/")[0];
			
			if ( domain2 == "andkon.com" || domain2.substr( domain2.length - 11 ) == ".andkon.com"
			  || domain2 == "wootfu.com" || domain2.substr( domain2.length - 11 ) == ".wootfu.com" )
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
			text.appendText( "This version of the game is site locked to AndKon.com.\n\nPlease visit " );
			length = text.length;
			text.setTextFormat( format1 );
			text.appendText( "http://andkon.com/arcade/" );
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
			// add splash
			sprite = new Sprite();
			sprite.buttonMode = true;
			sprite.mouseChildren = false;
			sprite.addEventListener(MouseEvent.CLICK, clickOnAndKon, false, 0, true);
			
			logo = new AndKonLogo();
			sprite.addChild( logo );
			
			sprite.x = (640-logo.width)/2;
			sprite.y = (460-logo.height)/2;
//			logo.addEventListener(MouseEvent.CLICK, clickOnAndKon);
			addChild(sprite);

			addEventListener(Event.ENTER_FRAME, checkFrame, false, 0, true);
			progressBarBG = new Shape();
			var g : Graphics = progressBarBG.graphics;
			g.lineStyle(2.0, 0xFFFFFF);
			g.drawRect(0, 0, 400, 20);
			addChild(progressBarBG);
			g = null;
			progressBarBG.x = (640 - 400) / 2;  // 640 - 400
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
		}
	}

	function clickOnAndKon(e : Event) : Void
	{
		var request : URLRequest = new URLRequest("http://andkon.com/arcade/");
		Lib.getURL(request);
		request = null;
	}
	
	function checkFrame(e : Event) : Void
	{
		progressBar.scaleX = root.loaderInfo.bytesLoaded / root.loaderInfo.bytesTotal;
		
		var timeLine = cast(this.parent, MovieClip);
		
		if(timeLine.currentFrame  == timeLine.totalFrames)
		{
			loadingFinished();
		}
		timeLine = null;
	}
	function loadingFinished() : Void
	{
		removeEventListener(Event.ENTER_FRAME, checkFrame);
		sprite.removeEventListener(MouseEvent.CLICK, clickOnAndKon);
		
		removeChild(progressBar);
		removeChild(progressBarBG);
		removeChild(sprite);
		startup();
	}
	function startup() : Void
	{
		//var mainClass : Class<Dynamic> = cast( Type.resolveClass("kongloader.KongMain") , Class<Dynamic>);
		//addChild(cast(Type.createInstance(mainClass,[]), DisplayObject));
		//mainClass = null;
		addChild(new AndKonMain());
	}
}
