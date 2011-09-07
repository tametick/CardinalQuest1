package com;

import flash.display.MovieClip;
import flash.display.Shape;
import flash.events.Event;
import flash.text.TextField;
import flash.utils.ByteArray;
import flash.Lib;

extern class KongData extends ByteArray{}
extern class GameData extends ByteArray{}

class Preloader extends MovieClip
{
	var bar:Bar;
	var kongData:ByteArray;
	var	loader:flash.display.Loader;
	
	public static function main()
	{
		Lib.current.addChild(new Preloader());
	}
	public function new()
	{
		super();
		bar = new Bar(200,20, 0xFF0000);
		bar.x = 20;//(Lib.current.stage.stageWidth-200)/2;
		bar.y = 20; (Lib.current.stage.stageHeight - 20) / 2;
		addChild(bar);
		
		kongData = new KongData();
		loader = new flash.display.Loader();
		loader.x = 120;
		loader.y = 20;
		addChild(loader);
		loader.loadBytes(kongData);
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	private function onEnterFrame(event:Event):Void
	{
		bar.percent = root.loaderInfo.bytesLoaded / root.loaderInfo.bytesTotal;
		var timeLine = cast(this.parent,MovieClip);
		if(timeLine.currentFrame  == timeLine.totalFrames)
		{
			timeLine.stop();
			removeChild(bar);
			loader.loadBytes(new GameData());
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
	}
}


class Bar extends MovieClip
{
	public var percent(default, setPercent):Float;
	var w:Float;
	var h:Float;
	var c:UInt;
	var fill:Shape;
	var tf:TextField;
	public function new(w, h, c)
	{
		super();
		this.w = w;
		this.h = h;
		this.c = c;

		var shape=new Shape();
		shape.graphics.lineStyle(1,0);
		shape.graphics.drawRect(0,0,w,h);
		addChild(shape);
		
		shape=new Shape();
		shape.graphics.beginFill(c,1.0);
		shape.graphics.drawRect(0,0,0*w,h);
		shape.x=shape.y=1;
		addChild(shape);
		
		tf = new TextField();
		tf.y = h+1;
		addChild(tf);

		fill = shape;
	}
	function setPercent(v:Float):Float
	{
		percent = v;
		fill.graphics.clear();
		fill.graphics.beginFill(c,1.0);
		fill.graphics.drawRect(0,0,percent*w,h);
		
		tf.text = cast Math.floor(percent*100);
		tf.x = percent*w;
		return percent;
	}
}