import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.display.Sprite;
import flash.display.Shape;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.system.LoaderContext;
import flash.system.ApplicationDomain;
import flash.utils.ByteArray;
import flash.Lib;
import flash.external.ExternalInterface;


import cq.Main;
import haxel.HxlGraphics;
import data.Configuration;

class MovieBytes extends ByteArray {
}

class CqPreloader extends MovieClip {
	static var url = "tametick.com";
	var tf:TextField;
	var loader:Loader;
	var ctx : LoaderContext;
	var progressBarBG:Shape;
	var progressBar:Shape;
	var initialized:Bool;	

	public static function main() {
		Lib.current.addChild(new CqPreloader());
	}
	
	function invalidUrl() {
		
		var tmp = new Bitmap(new BitmapData(stage.stageWidth,stage.stageHeight,true,0xFFFFFFFF));
		addChild(tmp);

		var txt:TextField = new TextField();
		txt.width = tmp.width - 16;
		txt.y = 8;
		#if flash
		txt.embedFonts = false;
		#else
		#end
		txt.multiline = true;
		txt.wordWrap = true;
		txt.text = "Hi there!  It looks like somebody copied this game without my permission.  Just click anywhere, or copy-paste this URL into your browser.\n\n"+url+"\n\nto play the game at my site.  Thanks, and have fun!";
		var fmt:TextFormat = new TextFormat("system",16,0x000000);
		txt.defaultTextFormat = fmt;
		txt.setTextFormat(fmt);
		addChild(txt);
		txt.addEventListener(MouseEvent.CLICK,goToMyURL);
		tmp.addEventListener(MouseEvent.CLICK,goToMyURL);

		// Stop listening for onEnterFrame events (halts further loading)
		removeEventListener(Event.ENTER_FRAME, onEnterFrame);

	}
	
	function goToMyURL(p:Dynamic) {
		//todo
	}
	
	public function new()
	{
		super();
		initialized = false;

		tf=new TextField();
		tf.x=260;
		tf.y=200;
		tf.width=200;
		tf.height=20;
		addChild(tf);

		
		progressBarBG = new Shape();
		var g = progressBarBG.graphics;
		g.lineStyle(2.0, 0xff000000);
		g.drawRect(0, 0, 200, 20);
		Lib.current.addChild(progressBarBG);
		progressBarBG.x = 260;
		progressBarBG.y = 230;

		progressBar = new Shape();
		var g = progressBar.graphics;
		g.beginFill(0xff000000);
		g.drawRect(0, 0, 200, 20);
		Lib.current.addChild(progressBar);
		progressBar.x = 260;
		progressBar.y = 230;
		

		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	private function onEnterFrame(event:Event):Void
	{
		//haxe.Log.setColor(0xffffff);
		if ( !initialized ) {
			initialized = true;
			if (!Configuration.debug && (root.loaderInfo.url.indexOf(url) < 0))  {
				invalidUrl();
				return;
			}
		}

		var percent = Math.floor((root.loaderInfo.bytesLoaded / root.loaderInfo.bytesTotal)*100);
		tf.text= percent +' %';
		progressBar.scaleX = 1.0 * (percent/100);
		if(percent==100) {
			removeChild(tf);
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			loader=new Loader();
			ctx = new LoaderContext(false, new ApplicationDomain(), null);
			loader.loadBytes(new MovieBytes(), ctx);
			addChild(loader);
			cast(this.parent,MovieClip).stop();

		}
	}
}
