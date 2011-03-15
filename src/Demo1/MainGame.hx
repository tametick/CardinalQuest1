//import haxel.HxlPreloader;
import haxel.HxlGame;
import haxel.HxlState;
import Resources;

import flash.Lib;

class MainGame extends HxlGame
{

	public function new() 
	{
		super(800, 600, StateTest, 1, "VT323");

		HxlState.bgColor = 0xffffff;
	}

}
