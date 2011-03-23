package haxel;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;

class HxlDialog extends HxlGroup
{

	var background:HxlSprite;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super();
		x = X;
		y = Y;
		width = Width;
		height = Height;
		scrollFactor.x = 0;
		scrollFactor.y = 0;
	}

	public override function add(Object:HxlObject,?ShareScroll:Bool=true):HxlObject {
		super.add(Object, ShareScroll);
		return Object;
	}

	public override function replace(OldObject:HxlObject,NewObject:HxlObject):HxlObject {
		NewObject.scrollFactor.x = NewObject.scrollFactor.y = 0;
		super.replace(OldObject, NewObject);
		return NewObject;
	}

	public function setBackgroundColor(Color:Int):Void {
		if ( background == null ) {
			background = new HxlSprite(0, 0);
			background.zIndex = 0;
			add(background);
		}
		background.createGraphic(Std.int(width), Std.int(height), Color);
	}

	public function setBackgroundGraphic(Graphic:Class<Bitmap>, ?Tiled:Bool=false, ?CornerRadius:Float=0.0):Void {
		if ( background == null ) {
			background = new HxlSprite(0, 0);
			background.zIndex = 0;
			add(background);
		}
		if ( Tiled ) {
			background.width = width;
			background.height = height;
			var source:BitmapData = Type.createInstance(Graphic, []).bitmapData;
			var targetBmp:BitmapData = new BitmapData(Std.int(width), Std.int(height), true, 0x0);
			var targetShape:Shape = new Shape();
			targetShape.graphics.beginBitmapFill(source, null, true);
			// drawRoundRect below if using corner radius
			if ( CornerRadius <= 0.0 ) {
				targetShape.graphics.drawRect(0, 0, width, height);
			} else {
				targetShape.graphics.drawRoundRect(0, 0, width, height, CornerRadius, CornerRadius);
			}
			targetShape.graphics.endFill();
			targetBmp.draw(targetShape);
			background.width = width;
			background.height = height;
			background.pixels = targetBmp;
			targetBmp = null;
			targetShape = null;
			source = null;
		} else {
			background.loadGraphic(Graphic);
		}
	}


	public override function update():Void
	{
	    super.update();
	    reset(x, y);
	}

}
