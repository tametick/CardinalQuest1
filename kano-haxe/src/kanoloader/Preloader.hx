package kanoloader;

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
import flash.system.System;
import flash.utils.ByteArray;
import haxe.Timer;

extern class KanoLogo extends Bitmap {}

class Preloader extends MovieClip {
	var progressBarBG : Shape;
	var progressBar : Shape;
	
	var logo : Bitmap;
	
	var isDone: Bool;
	
	public static function main()
	{
		Lib.current.addChild(new Preloader());
	}
	
	public function new()
	{
		super();
		
		Lib.current.stage.scaleMode = StageScaleMode.SHOW_ALL;
		Lib.current.stage.align = StageAlign.TOP;

		// add splash
		logo = new KanoLogo();
		logo.x = (640-logo.width)/2;
		logo.y = (480-logo.height)/2;
		addChild(logo);

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
		
	}

	function checkFrame(e : Event) : Void
	{
		progressBar.scaleX = root.loaderInfo.bytesLoaded / root.loaderInfo.bytesTotal;
		
		var timeLine = cast(this.parent, MovieClip);
		if(!isDone && timeLine.currentFrame  == timeLine.totalFrames)
		{
			isDone = true;
			Timer.delay(loadingFinished, 2000);
		}
		timeLine = null;
	}
	function loadingFinished() : Void
	{
		removeEventListener(Event.ENTER_FRAME, checkFrame);
		removeChild(progressBar);
		removeChild(progressBarBG);
		removeChild(logo);
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
