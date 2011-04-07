package cq;

import cq.CqResources;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import haxel.HxlButton;
import haxel.HxlGraphics;
import haxel.HxlState;
import haxel.HxlText;

class CreateCharState extends HxlState
{
	var fadeTime:Float;
	var state:Int;

	public override function create():Void {
		super.create();

		fadeTime = 0.5;
		state = 0;

		var titleText:HxlText = new HxlText(0, 0, 640, "Create Character");
		titleText.setFormat(null, 40, 0xffffff, "center");
		add(titleText);

		var btnStart:HxlButton = new HxlButton(520, 430, 100, 30);
		btnStart.setBackgroundColor(0xff999999, 0xffcccccc);
		btnStart.loadText(new HxlText(0, 3, 100, "START", true, "Geo").setFormat("Geo", 18, 0xffffff, "center", 0x010101));

		add(btnStart);
		var self = this;
		btnStart.setCallback(function() {
			self.gotoState(GameState);
		});

		HxlGraphics.fade.start(false, 0xff000000, fadeTime, function() {
			self.state = 1;
		});
	}

	public override function update():Void {
		super.update();	
	}

	override function onKeyDown(event:KeyboardEvent) { 
		if ( HxlGraphics.keys.ESCAPE ) {
			gotoState(MainMenuState);
		}
	}

	function gotoState(TargetState:Class<HxlState>) {
		if ( state != 1 ) return;
		state = 0;
		HxlGraphics.fade.start(true, 0xff000000, fadeTime, function() {
			var newState = Type.createInstance(TargetState, []);
			HxlGraphics.state = newState;
		}, true);
	}
}
