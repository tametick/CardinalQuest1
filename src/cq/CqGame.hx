package cq;
import haxel.HxlGame;
import haxel.HxlState;

import flash.Lib;

class CqGame extends HxlGame
{
	static function main() 
	{
		Lib.current.addChild(new CqGame());
	}
	
	public function new() 
	{
		super(640, 480, GameState, 1, "Geo");

		HxlState.bgColor = 0x00000000;
	}
}