package cq;
import haxel.HxlPreloader;
import haxel.HxlGame;
import haxel.HxlGraphics;
import haxel.HxlState;
import cq.CqResources;
import data.Configuration;

import flash.Lib;

import playtomic.Playtomic;

class Main {
	public static function main() {
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
		Playtomic.create();
		
		super(640, 480, SplashState, 1, FontDungeon.instance.fontName);
		//super(640, 480, GameState, 1, new FontDungeon().fontName);

	}
}
