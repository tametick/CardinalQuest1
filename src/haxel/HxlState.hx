package haxel;

import flash.display.Sprite;
import flash.geom.Rectangle;

class HxlState extends Sprite {

	public static var screen:HxlSprite;
	public static var bgColor:Int;
	public var defaultGroup:HxlGroup;

	public function new() {

		super();
		defaultGroup = new HxlGroup();
		if ( screen == null ) {
			screen = new HxlSprite();
			screen.createGraphic(HxlGraphics.width, HxlGraphics.height, 0, true);
			screen.origin.x = screen.origin.y = 0;
			screen.antialiasing = true;
			screen.exists = false;
			//screen.solid = false;
			//screen.fixed = true;
		}
	}

	public function create():Void {
	}
	
	public function add(obj:HxlObject):HxlObject {
		return defaultGroup.add(obj);
	}
	
	public function remove(obj:HxlObject):HxlObject {
		return defaultGroup.remove(obj);
	}

	public function preProcess():Void {
		screen.fill(bgColor);
		HxlGraphics.numRenders = 0;
	}

	public function render():Void {
		defaultGroup.render();
	}

	public function postProcess():Void {
	}

	public function update():Void {
		defaultGroup.update();
	}

	public function destroy():Void {
		defaultGroup.destroy();
	}
}
