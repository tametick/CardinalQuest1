import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Bitmap;
import flash.events.Event;
import flash.system.LoaderContext;
import flash.system.ApplicationDomain;
import flash.utils.ByteArray;
import flash.display.Sprite;

import flash.Lib;

//class MyImage extends ByteArray{}

//class MySprites extends Bitmap{ public function new() { super(); } }

import detribus.Sdrl;

class DetribusMovie extends MovieClip
{
	var loader:Loader;
	var ctx : LoaderContext;

	public static function main()
	{
		Lib.current.addChild(new DetribusMovie());
	}
	public function new()
	{
		super();
		Sdrl.main();
	}
}