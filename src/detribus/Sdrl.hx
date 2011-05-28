package detribus;

import haxel.HxlPreloader;
import haxel.HxlGame;
import haxel.HxlState;
import detribus.Resources;
import detribus.Player;

import flash.Lib;

class Sdrl
{
	public static function main() {
		#if flash9
		haxe.Log.setColor(0x00FF00);
		new Sdrl();
		#elseif iphone
		new Sdrl();
		#elseif cpp
		Lib.create(function(){new Sdrl();},720,480,60,0xffffff,(1*Lib.HARDWARE) | Lib.RESIZABLE);
		#end
	}

	public function new() {		
		//new HxlPreloader("SdrlGame");
		Lib.current.addChild(new SdrlGame());
	}	
	
	
}

class SdrlGame extends HxlGame {

	public static var player:Player;

	public function new() {
		//super(720, 480, StateGame, 1);
		super(360, 240, StateTitle, 2, "FontDungeon");
		_autoPause = false;
		//super(360, 240, StateCreateChar, 2);
		//super(360, 240, StateGame, 2, "FontDungeon");

		HxlState.bgColor = 0xffffffff;
	}

}
