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

class Main extends HxlGame {
	public static function main() {
		Configuration.app_width = 640;//Lib.current.stage.stageWidth;
		Configuration.app_height = 480;//Lib.current.stage.stageHeight;
		Lib.current.addChild(new Main());
	}

	public function new() {
		var _mochiads_game_id:String = "f7594e4c18588dca";
		
		Configuration.tileSize = 16;
		Configuration.zoom = 2.0;
		HxlState.bgColor = 0xFF000000;
		
		//Initialize Kongregate score API
		Registery.getKong()
		
		Playtomic.create();
		
		if (Configuration.debug)
			super(Configuration.app_width, Configuration.app_height, GameState, 1, FontDungeon.instance.fontName);
		else
			super(Configuration.app_width,Configuration.app_height, SplashState, 1, FontDungeon.instance.fontName);		
		
		pause = new CqPause();
		useDefaultHotKeys = false;
	}
}
