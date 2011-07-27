package haxel;

import data.SoundEffectsManager;
import flash.media.Sound;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

class HxlMenu extends HxlDialog {
	var items:Array<HxlMenuItem>;
	var _scrollSound:Class<Sound>;
	var _selectSound:Class<Sound>;
	var inputEnabled:Bool;
	var currentItem:Int;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=0, ?Height:Float=0) {
		super(X, Y, Width, Height);

		_scrollSound = null;
		_selectSound = null;

		items = new Array();
		toggleInput(true);
		currentItem = -1;
	}

	public function addItem(Item:HxlMenuItem) {
		Item.zIndex = 2;
		add(Item);
		items.push(Item);
		if ( currentItem == -1 ) {
			currentItem = 0;
			items[0].setHover(true);
		}
	}

	public function toggleInput(Toggle:Bool) {
		inputEnabled = Toggle;
		if ( inputEnabled ) {
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown,false,0,true);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp,false,0,true);
		} else {
			removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);				
		}
	}
	
	function onKeyDown(event:KeyboardEvent) {
		var c:Int = event.keyCode;
		if ( c == 13 ) { // Enter
			if ( _selectSound != null ) 
				playSelectSound();
				
			if ( currentItem >= 0 ) {
				items[currentItem].doCallback();
			}
		} else if ( c == 38 || c == 87 ) { // Up
			if ( _scrollSound != null ) 
				playScrollSound();
			
			if ( currentItem >= 0 ) 
				items[currentItem].setHover(false);
			currentItem--;
			if ( currentItem < 0 ) 
				currentItem = items.length - 1;
			items[currentItem].setHover(true);
			
		} else if ( c == 40 || c == 83) { // Down
			if ( _scrollSound != null ) 
				playScrollSound();
				
			if ( currentItem >= 0 ) 
				items[currentItem].setHover(false);
			currentItem++;
			if ( currentItem >= items.length ) 
				currentItem = 0;
			items[currentItem].setHover(true);

		}
	}

	function playSelectSound() {
		SoundEffectsManager.play(_selectSound);
	}
	function playScrollSound() {
		SoundEffectsManager.play(_scrollSound);
	}
	
	
	function onMouseUp(event:MouseEvent) {
		if ( !inputEnabled || !exists || !visible || !active || !HxlGraphics.mouse.justReleased() || (currentItem == -1)) return;
		if ( items[currentItem].overlapsPoint(HxlGraphics.mouse.x, HxlGraphics.mouse.y) ) {
			items[currentItem].doCallback();
			if ( _selectSound != null ) 
				playSelectSound();
		}
	}
			
	public function setScrollSound(ScrollSound:Class<Sound>) {
		_scrollSound = ScrollSound;
	}
		
	public function setSelectSound(SelectSound:Class<Sound>){
		_selectSound = SelectSound;
	}
	
	public override function update() {
		if ( inputEnabled == true && !visible ) 
			toggleInput(false);
		if ( inputEnabled ) {
			for ( i in 0...items.length ) {
				if ( currentItem != i && items[i].overlapsPoint(HxlGraphics.mouse.x, HxlGraphics.mouse.y) ) {
					items[currentItem].setHover(false);
					currentItem = i;
					items[currentItem].setHover(true);
					if ( _scrollSound != null ) 
						playScrollSound();
					break;
				}
			}
		}

		super.update();
	}
	
	public override function destroy() {
		toggleInput(false);
		super.destroy();
	}
	
}
