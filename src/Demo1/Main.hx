//import haxel.HxlPreloader;
//import haxel.HxlGame;
//import haxel.HxlState;
import Resources;

import flash.Lib;

class Main
{

	public static function main() {
		#if flash9
		haxe.Log.setColor(0x00FF00);
		new Main();
		#elseif iphone
		new Main();
		#elseif cpp
		Lib.create(function(){new Main();},800,600,60,0xffffff,(1*Lib.HARDWARE) | Lib.RESIZABLE);
		#end
	}

	public function new() {
		Lib.current.addChild(new MainGame());
	}

}
