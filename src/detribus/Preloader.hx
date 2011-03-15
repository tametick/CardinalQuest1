package;

import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.display.Sprite;
import flash.display.Shape;
import flash.events.Event;
import flash.text.TextField;
import flash.system.LoaderContext;
import flash.system.ApplicationDomain;
import flash.utils.ByteArray;

import flash.Lib;

class MovieBytes extends ByteArray{}

class Preloader extends MovieClip
{
	var tf:TextField;
	var loader:Loader;
	var ctx : LoaderContext;
	var progressBarBG:Shape;
	var progressBar:Shape;

	public static function main()
	{
		Lib.current.addChild(new Preloader());
	}
	public function new()
	{
		super();
		tf=new TextField();
		//tf.border=true;
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
		var percent = Math.floor((root.loaderInfo.bytesLoaded / root.loaderInfo.bytesTotal)*100);
		tf.text= percent +' %';
		progressBar.scaleX = 1.0 * (percent/100);
		if(percent==100)
		{
			removeChild(tf);
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			loader=new Loader();
			ctx = new LoaderContext(false, new ApplicationDomain(), null);
			loader.loadBytes(new MovieBytes(), ctx);
			addChild(loader);
/*			tf.text='100% (test online to see preloader)';
			setChildIndex(tf,numChildren-1);
			tf.x=400;
			tf.y=50; */
			cast(this.parent,MovieClip).stop();
		}
	}
}
