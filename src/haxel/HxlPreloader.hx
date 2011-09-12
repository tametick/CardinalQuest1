package haxel;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

class HxlPreloader extends MovieClip {
	var myUrl:String;
	var mainClassName:String;
	
	// progress bar
	var progress: flash.display.Shape;
	var fully_loaded: Bool;

	public function new(mainClass:String, ?url:String=null) {
		super();
		
		mainClassName = mainClass;
		
		// site-locking
		myUrl = url;
		if (isInvalidUrl())
			return;
		
		var x = 100;
		var y = 100;
		var height = 14;
		var width = 104;
		//var music: flash.media.Sound = Type.createInstance(Type.resolveClass("resources.classes.Music"), []);
		
		// background for the progress bar
		var progressBg = new flash.display.Shape();
		var g = progressBg.graphics;
		g.beginFill(0x002288);
		g.drawRect(-2, -2, 104, 14);
		flash.Lib.current.addChild(progressBg);
		progressBg.x = 100;
		progressBg.y = 100;

		// the progress bar itself
		progress = new flash.display.Shape();
		g = progress.graphics;
		g.beginFill(0x00ff88);
		g.drawRect(0, 0, 100, 10);
		flash.Lib.current.addChild(progress);
		progress.x = 100;
		progress.y = 100;

		fully_loaded = false;
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME,onEnterFrame,false,0,true);
	}

	function isInvalidUrl():Bool {
		var tmp:Bitmap;
		if ((myUrl != null) && (root.loaderInfo.url.indexOf(myUrl) < 0)) {
			tmp = new Bitmap(new BitmapData(stage.stageWidth,stage.stageHeight,true,0xFFFFFFFF));
			addChild(tmp);
			
			var fmt:TextFormat = new TextFormat();
			fmt.color = 0x000000;
			fmt.size = 16;
			fmt.align = TextFormatAlign.CENTER;
			fmt.bold = true;
			fmt.font = "system";
			
			var txt:TextField = new TextField();
			txt.width = tmp.width-16;
			txt.height = tmp.height-16;
			txt.y = 8;
			txt.multiline = true;
			txt.wordWrap = true;
			txt.embedFonts = true;
			txt.defaultTextFormat = fmt;
			txt.text = "Hi there!  It looks like somebody copied this game without my permission.  Just click anywhere, or copy-paste this URL into your browser.\n\n"+myUrl+"\n\nto play the game at my site.  Thanks, and have fun!";
			addChild(txt);
			
			txt.addEventListener(MouseEvent.CLICK,goToMyURL,false,0,true);
			tmp.addEventListener(MouseEvent.CLICK,goToMyURL,false,0,true);
			return true;
		}
		return false;
	}
	
	function goToMyURL(?event:MouseEvent=null) {
		Lib.getURL(new URLRequest("http://"+myUrl));
	}
	
	function onEnterFrame(e: flash.events.Event) {
		
		var totalBytes = flash.Lib.current.loaderInfo.bytesTotal;
		var actBytes = flash.Lib.current.loaderInfo.bytesLoaded;

		if (!fully_loaded && actBytes <= totalBytes) {
			var percent = actBytes / totalBytes;
			update(percent);
		}

		if (!fully_loaded && actBytes == totalBytes) {
			fully_loaded = true;
			//music.play();
			
			var mainClass:Class<Dynamic> = Type.resolveClass(mainClassName);
			if (mainClass != null) {
				var app:Dynamic = Type.createInstance(mainClass, new Array());
				Lib.current.removeChild(progress);
				Lib.current.addChild(cast( app, Sprite));
			}
		}
	}
	
	function update(percent:Float) 
	{
		// animate progress bar
		progress.scaleX = 1.0 * percent;
	}	
}