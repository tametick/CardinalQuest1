package cq.states;

import data.Configuration;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import haxel.HxlState;
import haxel.HxlGraphics;
import haxel.HxlPoint;
import cq.CqResources;

import flash.display.StageDisplayState;
import flash.Lib;
import flash.errors.TypeError;

class CqState extends HxlState {
	public override function create() {
		if(cursor==null){
			cursor = new CursorSprite();
			cursor.scrollFactor.y = cursor.scrollFactor.x = 0;
		}
		
		setDiagonalCursor();
		cursor.visible = true;
		
		super.create();
	}
	
	private function positionCursor() {
		// override the default mouse positioning
		if(cursor!=null) {
			cursor.x = HxlGraphics.mouse.screenX - cursor.origin.x;
			cursor.y = HxlGraphics.mouse.screenY - cursor.origin.y;
		}
	}
	
	function setDiagonalCursor(?facing:HxlPoint = null) {
		// it would be nice to rename this setCursor, since it no longer only sets the diagonal cursor
		
		if (facing == null || (facing.x == 0 && facing.y == 0)) {
			var diagonal = SpriteCursor.instance.getSpriteIndex("diagonal");
			
			// cursor rotation will set angle and the cursor origin
			
			cursor.angle = 0;
			cursor.origin.x = 4;
			cursor.origin.y = 2;
			
			if (cursor.getFrame() != diagonal) cursor.setFrame(diagonal);
		} else {
			var up:Int = SpriteCursor.instance.getSpriteIndex("up");
			var newAngle:Float = cursor.angle;
			
			if (facing.x==0 && facing.y==1) newAngle = 180;
			else if(facing.x==0 && facing.y==-1) newAngle = 0;
			else if(facing.x==1 && facing.y==0) newAngle = 90
			else if(facing.x==-1 && facing.y==0) newAngle = 270;
			
			if (cursor.getFrame() != up) cursor.setFrame(up);
			if (cursor.angle != newAngle) cursor.angle = newAngle;
			
			cursor.origin.x = 16;
			//cursor.origin.y = 3;
			cursor.origin.y = 9;
		}
		
		positionCursor();
	}
	
	public override function update() {
		super.update();
		positionCursor();
		
		if (HxlGraphics.keys.justPressed("F2")) {
			if(Lib.current.stage.displayState==StageDisplayState.NORMAL){
				Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				Lib.current.stage.fullScreenSourceRect = new Rectangle(0, 0, Configuration.app_width, Configuration.app_height);
			} else{
				Lib.current.stage.displayState = StageDisplayState.NORMAL;
				Lib.current.stage.fullScreenSourceRect = null;
			}
		}
		
        #if flash
		if (HxlGraphics.keys.justPressed("F3")) {
			if(Reflect.hasField(Lib.current.stage,"showDefaultContextMenu")) {
				if(Lib.current.stage.showDefaultContextMenu)
					Lib.current.stage.showDefaultContextMenu = false;
				else
					Lib.current.stage.showDefaultContextMenu = true;
			}
		}
        #end
	}
	/*
	function clickOnKong(e : Event) {
		var request : URLRequest = new URLRequest("http://kongregate.com/");
		Lib.getURL(request);
		request = null;
	}*/

}