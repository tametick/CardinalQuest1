package cq.states;

import cq.CqActor;
import data.Configuration;
import data.Registery;
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
import kongregate.CKongregate;

class HighScoreState extends CqState {
	var fadeTime:Float;
	var minimumTime:Float;
	var entryStamp:Float;
	var state:Int;
	var kongregate:kongregate.CKongregate;
	
	public override function create() {
		super.create();
		fadeTime = 0.5;
		HxlGraphics.fade.start(false, 0xff000000, fadeTime);
		var bg = new HxlSprite(0, 0, SpriteHighScoresBg);
		add(bg);
		state = 0;
		minimumTime = 1;
		entryStamp = Timer.stamp();
		
		//Not sure whether we need this to fade in/out along
		var highscoresText:HxlText = new HxlText(0, Configuration.app_height/7, Configuration.app_width, Resources.getString("MENU_HIGHSCORES"), true, null,42,0x0000000,"center");
		add( highscoresText );
		
		
		//Lets see whether we can connect to Kongregate..
		kongregate = new CKongregate();
		
		bg = null;
	}
	public override function update() {
		super.update();
		setDiagonalCursor();
		if (state == 1) {
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
		HxlGraphics.fade.start(true, 0xff000000, fadeTime, nextScreenCallBack, true);
	}
	function nextScreenCallBack()
	{
		HxlGraphics.popState();
	}
}