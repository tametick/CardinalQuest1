package cq.states;

import cq.CqActor;
import cq.CqConfiguration;
import cq.CqRegistery;
import cq.CqResources;
import cq.ui.CqTextScroller;
import data.Registery;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import haxe.Timer;
import haxel.HxlGraphics;
import haxel.HxlPoint;
import haxel.HxlSprite;
import haxel.HxlState;
import haxel.HxlText;
import haxel.HxlTimer;
import haxel.HxlUtil;

class HighScoreState extends CqState {
	var fadeTime:Float;
	var minimumTime:Float;
	var entryStamp:Float;
	var state:Int;
	public override function create() {
		super.create();
		fadeTime = 0.5;
		HxlGraphics.fade.start(false, 0xff000000, fadeTime);
		var bg = new HxlSprite(0, 0, SpriteHighScoresBg);
		add(bg);
		state = 0;
		minimumTime = 1;
		entryStamp = Timer.stamp();
	}
	public override function update() {
		super.update();
		setDiagonalCursor();
		if (state == 1)
		{
			state = 2;
			nextScreen();
		}
	}

	override function onMouseDown(event:MouseEvent) {
		if (state == 0 && entryStamp+minimumTime < Timer.stamp())
			state = 1;
	}
	
	override function onKeyUp(event:KeyboardEvent) { 
		if (state == 0 && entryStamp+minimumTime < Timer.stamp())
			state = 1;
	}

	function nextScreen() {
		HxlGraphics.fade.start(true, 0xff000000, fadeTime, function() {
			HxlGraphics.popState();
		}, true);
	}
	
}