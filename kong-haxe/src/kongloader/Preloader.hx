package kongloader;

import flash.display.DisplayObject;
import flash.display.StageScaleMode;
import flash.display.StageAlign;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.events.Event;
import flash.Lib;
import flash.utils.ByteArray;

class Preloader extends MovieClip
{
	var progressBarBG : Shape;
	var progressBar : Shape;
	
	public static function main()
	{
		Lib.current.addChild(new Preloader());
	}
	
	public function new()
	{
		super();

		Lib.current.stage.scaleMode = StageScaleMode.SHOW_ALL;
		Lib.current.stage.align = StageAlign.TOP;

		addEventListener(Event.ENTER_FRAME, checkFrame);
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
		
		var timeLine = cast(this.parent,MovieClip);
		if(timeLine.currentFrame  == timeLine.totalFrames)
		{
			cast(this.parent, MovieClip).stop();
			loadingFinished();
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
		//var mainClass : Class<Dynamic> = cast( Type.resolveClass("KongMain") , Class<Dynamic>);
		//addChild(cast(Type.createInstance(mainClass,[]), DisplayObject));
		//mainClass = null;
		addChild(new KongMain());
	}
}
