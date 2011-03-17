import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Bitmap;
import flash.events.Event;
import flash.system.LoaderContext;
import flash.system.ApplicationDomain;
import flash.utils.ByteArray;
import flash.display.Sprite;
import flash.Lib;

import cq.CqMain;

class CqMovie extends MovieClip
{
	var loader:Loader;
	var ctx : LoaderContext;

	public static function main()
	{
		Lib.current.addChild(new CqMovie());
	}
	public function new()
	{
		super();
		CqMain.main();
	}
}
