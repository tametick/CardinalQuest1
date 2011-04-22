package cq;
import haxel.HxlPreloader;
import haxel.HxlGame;
import haxel.HxlGraphics;
import haxel.HxlState;
import cq.CqResources;
import data.Configuration;

import flash.Lib;

class Main {
	public static function main() {
		// set to false before releasing
		HxlGraphics.debug = true;
		
		#if flash9
		haxe.Log.setColor(0xffffff);
		new Main();
		#elseif iphone
		new Main();
		#elseif cpp
		Lib.create(function(){new Main();},640,480,60,0xffffff,(1*Lib.HARDWARE) | Lib.RESIZABLE);
		#end
	}

	public function new() {		
		Lib.current.addChild(new Game());
	}	
}

class Game extends HxlGame {
	public function new() {
		Configuration.tileSize = 16;
		Configuration.zoom = 2.0;
		HxlState.bgColor = 0xFF000000;
		
		
		if(HxlGraphics.debug)
			super(640, 480, GameState, 1, "Geo");
		else
			super(640, 480, SplashState, 1, "Geo");

	}
}
