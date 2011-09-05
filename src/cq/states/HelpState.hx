package cq.states;

import cq.CqResources;
import cq.GameUI;
import data.Configuration;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import haxel.HxlButton;
import haxel.HxlGraphics;
import haxel.HxlSprite;

class HelpState extends CqState {
	public static var instance(getInstance, null):HelpState;
	private static var _instance:HelpState;
	public override function create() {
		super.create();
		var btn:HxlButton = new HxlButton(0, 0, Configuration.app_width, Configuration.app_height,nextScreen,0,0);
		var overlay:HxlSprite;
		if (GameUI.showInvHelp)
			overlay = new HxlSprite(0, 0,SpriteInvHelpOverlay);
		else
			overlay = new HxlSprite( 0, 0, SpriteHelpOverlay);
		btn.add(overlay);
		btn.setEventPriority(-1);
		btn.setEventStopPropagate(true);
		add(btn);
		
		btn = null;
		overlay  = null;
	}
	
	public override function update() {
		super.update();
		setDiagonalCursor();
	}

	override function onMouseDown(event:MouseEvent) {
		nextScreen();
	}
	
	override function onKeyUp(event:KeyboardEvent) { 
		nextScreen();
	}

	function nextScreen() {
		HxlGraphics.popState();
	}
	private static function getInstance():HelpState
	{
		if (_instance == null)
		 _instance = new HelpState();
		return _instance;
	}

}
