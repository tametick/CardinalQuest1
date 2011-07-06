package cq.states;

import haxel.HxlState;
import haxel.HxlGraphics;
import cq.CqResources;

import flash.display.StageDisplayState;
import flash.Lib;
import flash.errors.TypeError;

class CqState extends HxlState {
	public override function create() {
		if(CursorSprite.instance == null)
			CursorSprite.instance = new CursorSprite();
		cursor = CursorSprite.instance;
		cursor.setFrame(SpriteCursor.instance.getSpriteIndex("diagonal"));
		
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
			if(Lib.current.stage.displayState==StageDisplayState.NORMAL)
				Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN;
			else{
				Lib.current.stage.displayState = StageDisplayState.NORMAL;
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