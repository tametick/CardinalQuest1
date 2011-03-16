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
	var currentItem:Int;
	
	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=0, ?Height:Float=0) {
		super(X, Y, Width, Height);

		background = new HxlSprite(0, 0);
		background.zIndex = 0;
		add(background);

		items = new Array();
		toggleInput(true);
		currentItem = -1;
	}

	public function addItem(Item:HxlMenuItem):Void {
		Item.zIndex = 2;
		add(Item);
		items.push(Item);
		if ( currentItem == -1 ) {
			currentItem = 0;
			items[0].setHover(true);
		}
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
		var c:Int = event.keyCode;
		if ( c == 13 ) { // Enter
			// TODO
		} else if ( c == 38 ) { // Up
			if ( currentItem >= 0 ) items[currentItem].setHover(false);
			currentItem--;
			if ( currentItem < 0 ) currentItem = items.length - 1;
			items[currentItem].setHover(true);
		} else if ( c == 40 ) { // Down
			if ( currentItem >= 0 ) items[currentItem].setHover(false);
			currentItem++;
			if ( currentItem >= items.length ) currentItem = 0;
			items[currentItem].setHover(true);
		}
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
