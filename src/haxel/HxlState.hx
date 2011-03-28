package haxel;

import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.events.KeyboardEvent;

import haxel.HxlObject;
import data.Registery;

class HxlState extends Sprite {

	public static var screen:HxlSprite;
	public static var bgColor:Int;
	public var defaultGroup:HxlGroup;

	var keyboard:HxlKeyboard;
	var initialized:Int;
	//var loadingBox:LoadingBox;
	
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
			keyboard = new HxlKeyboard();
		}
	}

	public function create():Void {
		initialized = -1;
	}
	
	public function add(obj:HxlObjectI):HxlObjectI {
		defaultGroup.add(obj);
		obj.onAdd(this);
		return obj;
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
		if ( initialized == -1 ) {
//			loadingBox.visible = true;
			initialized = 0;
		} else if ( initialized == 0 ){
			HxlGraphics.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			HxlGraphics.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			init();
			initialized = 1;
//			loadingBox.visible = false;
		} else {
			
		}
	}

	public function destroy():Void {
		HxlGraphics.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		HxlGraphics.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		defaultGroup.destroy();
	}

	
	function getTargetAccordingToKeyPress():HxlPoint {
		var player = Registery.player;
		var level = Registery.world.currentLevel;
		
		var targetTile:HxlPoint = null;
		if ( HxlGraphics.keys.LEFT ) {
			if ( player.tilePos.x > 0) {
				if ( !level.isBlockingMovement(Std.int(player.tilePos.x-1), Std.int(player.tilePos.y)) ) {
					targetTile = new HxlPoint( -1, 0);
				}
			}
		} else if ( HxlGraphics.keys.RIGHT ) {
			if ( player.tilePos.x < level.widthInTiles) {
				if ( !level.isBlockingMovement(Std.int(player.tilePos.x+1), Std.int(player.tilePos.y)) ) {
					targetTile = new HxlPoint(1, 0);
				}
			}
		} else if ( HxlGraphics.keys.UP ) {
			if ( player.tilePos.y > 0 ) {
				if ( !level.isBlockingMovement(Std.int(player.tilePos.x), Std.int(player.tilePos.y-1)) ) {
					targetTile = new HxlPoint(0, -1);
				}
			}
		} else if ( HxlGraphics.keys.DOWN ) {
			if ( player.tilePos.y < level.heightInTiles ) {
				if ( !level.isBlockingMovement(Std.int(player.tilePos.x), Std.int(player.tilePos.y+1)) ) {
					targetTile = new HxlPoint(0, 1);
				}
			}
		} 
		
		return targetTile;
	}
	
	function init() { }
	function onKeyUp(event:KeyboardEvent) { }
	function onKeyDown(event:KeyboardEvent) { }
}
