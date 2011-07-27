package cq.states;

import flash.geom.Rectangle;
import haxel.HxlState;
import haxel.HxlGraphics;
import cq.CqResources;

import flash.display.StageDisplayState;
import flash.Lib;
import flash.errors.TypeError;

class CqState extends HxlState {
	public override function create() {
		if(cursor==null){
			cursor = new CursorSprite();
			cursor.setFrame(SpriteCursor.instance.getSpriteIndex("diagonal"));
		}
		cursor.visible = true;
		super.create();
	}
	
	function setDiagonalCursor() {
		cursor.angle = 0;
		var diagonal = SpriteCursor.instance.getSpriteIndex("diagonal");
		if(cursor.getFrame()!=diagonal) {
			cursor.setFrame(diagonal);
		}
	}
	
	public override function update() {
		super.update();
		if (HxlGraphics.keys.justPressed("F2")) {
			if(Lib.current.stage.displayState==StageDisplayState.NORMAL){
				Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				Lib.current.stage.fullScreenSourceRect = new Rectangle(0, 0, 640, 480);
			} else{
				Lib.current.stage.displayState = StageDisplayState.NORMAL;
				Lib.current.stage.fullScreenSourceRect = null;
			}
		}
		
		if (HxlGraphics.keys.justPressed("F3")) {
			if(Reflect.hasField(Lib.current.stage,"showDefaultContextMenu")) {
				if(Lib.current.stage.showDefaultContextMenu)
					Lib.current.stage.showDefaultContextMenu = false;
				else
					Lib.current.stage.showDefaultContextMenu = true;
			}
		}
	}
}