package haxel;

import flash.display.Bitmap;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

class HxlMenu extends HxlDialog
{

	public var scrollSound(getScrolSound, setScrollSound):HxlSound;
	
	var background:HxlSprite;
	var items:Array<HxlMenuItem>;
	var _scrollSound:HxlSound;
	var inputEnabled:Bool;
	
	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=0, ?Height:Float=0) {
		super(X, Y, Width, Height);

		background = new HxlSprite(0, 0);
		background.zIndex = 0;
		add(background);

		items = new Array();
		toggleInput(true);
	}

	public function addItem(Item:HxlMenuItem):Void {
		Item.zIndex = 2;
		add(Item);
		items.push(Item);
	}

	public function toggleInput(Toggle:Bool):Void {
		inputEnabled = Toggle;
		if ( inputEnabled ) {
			HxlGraphics.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			HxlGraphics.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		} else {
			HxlGraphics.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			HxlGraphics.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);				
		}
	}
	
	function onKeyDown(event:KeyboardEvent):Void {
		// TODO
	}
	
	function onMouseUp(event:MouseEvent):Void {
		var mX = HxlGraphics.mouse.x;
		var mY = HxlGraphics.mouse.y;
		// TODO
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
	
	public override function update():Void {
		if ( inputEnabled == true && !visible ) toggleInput(false);
		super.update();
	}
	
	public override function destroy():Void {
		toggleInput(false);
		super.destroy();
	}
	
}
