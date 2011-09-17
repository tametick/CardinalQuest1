package cq.states;

import data.Configuration;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.net.URLRequest;
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