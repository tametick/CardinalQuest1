package cq;

import cq.states.GameState;
import cq.states.MainMenuState;
import cq.states.SplashState;
import cq.CqResources;
import cq.ui.CqPause;
import haxel.HxlGame;
import haxel.HxlGraphics;
import haxel.HxlState;
import haxel.HxlText;
import data.Configuration;

import flash.Lib;

import playtomic.Playtomic;

class Main {
	static var currentGame:Game;
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
		currentGame = new Game();
		Lib.current.addChild(currentGame);
	}
}

class Game extends HxlGame {	
	public function new() {
		var _mochiads_game_id:String = "f7594e4c18588dca";

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
