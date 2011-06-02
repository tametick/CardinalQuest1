package detribus;

import haxel.HxlGroup;
import haxel.HxlGraphics;
import detribus.BaseMenuState;

import flash.events.MouseEvent;
import flash.events.KeyboardEvent;

class Menu extends HxlGroup
{

	var items:Array<MenuItem>;
	var selectedItem:Int;
	var pressed:Bool;
	var initialized:Bool;
	
	public function new(X:Int, Y:Int, Width:Int, Height:Int) 
	{
		super();
		x = X;
		y = Y;
		width = Width;
		height = Height;
		items = new Array();
		selectedItem = -1;
		pressed = false;
		initialized = false;
	}
	
	public override function update():Void {
		if (!initialized) {
			if (HxlGraphics.stage != null) {
				HxlGraphics.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp,false,0,true);
				HxlGraphics.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp,false,0,true);
				initialized = true;
			}
		}
		
		if ( selectedItem == -1 && items.length >= 1 ) {
			selectedItem = 0;
			items[selectedItem].toggleHover(true);
		}
		
		for (i in 0...items.length) {
			if ( selectedItem != i && items[i].overlapsPoint(HxlGraphics.mouse.x, HxlGraphics.mouse.y) ) {
				if ( selectedItem >= 0 ) items[selectedItem].toggleHover(false);
				selectedItem = i;
				items[selectedItem].toggleHover(true);
				break;
			}
		}
		
		super.update();
	}
	
	public function addItem(Item:MenuItem):Void {
		items.push(Item);
		add(Item);
	}

	public override function destroy():Void {
		if (HxlGraphics.stage != null) {
			HxlGraphics.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			HxlGraphics.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
	}

	function onMouseUp(event:MouseEvent):Void {
		if (!exists || !visible || !active || !HxlGraphics.mouse.justReleased() || (selectedItem == -1)) return;
		if ( items[selectedItem].overlapsPoint(HxlGraphics.mouse.x, HxlGraphics.mouse.y)) items[selectedItem].doCallback();
	}

	function onKeyUp(event:KeyboardEvent):Void {
		if (!exists || !visible || !active || (selectedItem == -1)) return;
		var c:Int = event.keyCode;
		if ( c == 38) {	// Up
			items[selectedItem].toggleHover(false);
			selectedItem--;
			if ( selectedItem < 0 ) selectedItem = items.length - 1;
			items[selectedItem].toggleHover(true);
			BaseMenuState.playScrollSound();
			
		} else if (	c ==  40 ) {	// Down
			items[selectedItem].toggleHover(false);
			selectedItem++;
			if ( selectedItem >= items.length ) selectedItem = 0;
			items[selectedItem].toggleHover(true);
			BaseMenuState.playScrollSound();
		} else if ( c == 13 || c == 32 ) {	// Enter or Space
			items[selectedItem].doCallback();
			BaseMenuState.playSelectSound();
		}
	}
}
