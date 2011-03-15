import haxel.HxlGroup;
import haxel.HxlText;
import haxel.HxlSprite;
import haxel.HxlGraphics;

import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

#if flash9
import flash.text.AntiAliasType;
import flash.text.GridFitType;
#end

class StatsDialog extends HxlGroup
{

	private var dialogBG:HxlSprite;

	public function new(Width:Int, Height:Int) {
		super();
		width = Width;
		height = Height;
		scrollFactor.x = 0;
		scrollFactor.y = 0;
		exists = true;
		visible = true;
		dialogBG = new HxlSprite().createGraphic(Math.floor(Width),Math.floor(Height),0xff000000);

		var tmpSprite:Sprite = new Sprite();
		var gfx = tmpSprite.graphics;
		gfx.lineStyle(3, 0xffffff);
		gfx.beginFill(0xffffff, 1.0);
		gfx.drawRoundRect(0, 0, Width, Height, 15.0);
		gfx.endFill();
		var bgBitmap:Bitmap = new Bitmap(new BitmapData(Width, Height, true, 0x0));
		bgBitmap.bitmapData.draw(tmpSprite);
		dialogBG.pixels = bgBitmap.bitmapData;
		add(dialogBG);
		dialogBG.scrollFactor.x = 0;
		dialogBG.scrollFactor.y = 0;
	}
	
}
