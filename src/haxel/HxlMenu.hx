package haxel;

import flash.display.Bitmap;

class HxlMenu extends HxlDialog
{

	public var scrollSound(getScrolSound, setScrollSound):HxlSound;
	
	var background:HxlSprite;
	var items:Array<HxlMenuItem>;
	var _scrollSound:HxlSound;
	
	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=0, ?Height:Float=0) {
		super(X, Y, Width, Height);

		background = new HxlSprite(0, 0);
		background.zIndex = 0;
		add(background);

		items = new Array();
	}

	public function addItem(Item:HxlMenuItem):Void {
		Item.zIndex = 2;
		add(Item);
		items.push(Item);
	}

	public function setBackgroundColor(Color:Int):Void {
		background.createGraphic(Std.int(width), Std.int(height), Color);
	}

	public function setBackgroundGraphic(Graphic:Class<Bitmap>):Void {
		background.loadGraphic(Graphic);
	}
	
	public function getScrolSound():HxlSound {
		return _scrollSound;
	}
	
	public function setScrollSound(ScrollSound:HxlSound):HxlSound {
		_scrollSound = ScrollSound;
		return _scrollSound;
	}

}
