package cq;

import cq.states.GameState;
import cq.states.SplashState;
import cq.CqResources;
import haxel.HxlPreloader;
import haxel.HxlGame;
import haxel.HxlGraphics;
import haxel.HxlState;
import data.Configuration;

import flash.Lib;
import flash.system.Capabilities;
import haxe.Timer;

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
		if (StringTools.startsWith(Capabilities.os, "Mac")) {
			// mac requires a delay for properly full-screening
			Timer.delay(function() { Lib.current.addChild(new Game()); }, 1000);
		} else {
			Lib.current.addChild(new Game());
		}
			
	}	
}

class Game extends HxlGame {
	public function new() {
		Configuration.tileSize = 16;
		Configuration.zoom = 2.0;
		HxlState.bgColor = 0xFF000000;
		Playtomic.create();
		
		super(640, 480, SplashState, 1, FontDungeon.instance.fontName);		
		//super(640, 480, GameState, 1, FontDungeon.instance.fontName);
	}
}
