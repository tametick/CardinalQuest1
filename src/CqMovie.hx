import flash.display.Loader;
import flash.display.MovieClip;
import flash.events.Event;
import flash.system.LoaderContext;
import flash.system.ApplicationDomain;
import flash.utils.ByteArray;
import flash.display.Sprite;
import flash.Lib;

import cq.Main;

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
		Main.main();
	}
}
