package cq;

import cq.states.GameState;
import cq.states.SplashState;
import cq.CqResources;
import cq.ui.CqPause;
import haxel.HxlPreloader;
import haxel.HxlGame;
import haxel.HxlGraphics;
import haxel.HxlState;
import data.Configuration;

import flash.Lib;
import flash.system.Capabilities;
import haxe.Timer;

import playtomic.Playtomic;
/*
 * spell reset
 * 
 */
class Main {
	public static function main() {
		#if flash9
		haxe.Log.setColor(0xffffff);
		new Main();
		#elseif iphone
		new Main();
		#elseif cpp
		Lib.create(function(){new Main();},Configuration.app_width,Configuration.app_height,60,0xffffff,(1*Lib.HARDWARE) | Lib.RESIZABLE);
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
		
		if (Configuration.debug)
			super(640, 480, GameState, 1, FontDungeon.instance.fontName);
		else
			super(640, 480, SplashState, 1, FontDungeon.instance.fontName);		
		
		pause = new CqPause();
		useDefaultHotKeys = false;
		
	}
}
