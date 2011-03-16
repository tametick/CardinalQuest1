package detribus;

import haxel.HxlGroup;
import haxel.HxlText;
import haxel.HxlSprite;
import haxel.HxlGraphics;

import flash.text.TextFormat;
import flash.text.TextFormatAlign;

#if flash9
import flash.text.AntiAliasType;
import flash.text.GridFitType;
#end

class Dialog extends HxlGroup
{

	public function new(X:Int, Y:Int, Width:Int, Height:Int) {
		super();
		x = X;
		y = Y;
		width = Width;
		height = Height;
		scrollFactor.x = 0;
		scrollFactor.y = 0;
	}
	
}