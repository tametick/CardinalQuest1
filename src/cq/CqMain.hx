package cq;
import haxel.HxlPreloader;
import haxel.HxlGame;
import haxel.HxlState;
import cq.Resources;

import flash.Lib;

class CqMain
{
	public static function main() {
		#if flash9
		haxe.Log.setColor(0xffffff);
		new CqMain();
		#elseif iphone
		new CqMain();
		#elseif cpp
		Lib.create(function(){new CqMain();},640,480,60,0xffffff,(1*Lib.HARDWARE) | Lib.RESIZABLE);
		#end
	}

	public function new() {		
		Lib.current.addChild(new CqGame());
	}	
	
}

class CqGame extends HxlGame
{
	
	public function new() 
	{
		super(640, 480, UITestState, 1, "Geo");
		HxlState.bgColor = 0xFF000000;
	}
}
