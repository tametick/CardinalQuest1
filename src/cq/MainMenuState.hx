package cq;

import cq.CqResources;
import haxel.HxlGraphics;
import haxel.HxlMenu;
import haxel.HxlMenuItem;
import haxel.HxlState;
import haxel.HxlText;
import haxel.HxlTimer;

class MainMenuState extends HxlState
{

	var fadeTimer:HxlTimer;
	var fadeTime:Float;
	var titleText:HxlText;

	var menu:HxlMenu;
	var btnNewGame:HxlMenuItem;
	var btnCredits:HxlMenuItem;

	public override function create():Void {
		super.create();

		fadeTimer = new HxlTimer();
		fadeTime = 0.5;

		titleText = new HxlText(0, 60, 640, "Main Menu Screen");
		titleText.setFormat(null, 40, 0xff6666, "center");
		add(titleText);

		menu = new HxlMenu(220, 220, 200, 200);
		add(menu);

		var self = this;

		var btnNewGame:HxlMenuItem = new HxlMenuItem(0, 0, 200, "New Game");
		btnNewGame.setNormalFormat(null, 40, 0xffffff, "center");
		btnNewGame.setHoverFormat(null, 40, 0xffff00, "center");
		menu.addItem(btnNewGame);
		btnNewGame.setCallback(function() { self.changeState(GameState); });

		var btnCredits:HxlMenuItem = new HxlMenuItem(0, 40, 200, "Credits");
		btnCredits.setNormalFormat(null, 40, 0xffffff, "center");
		btnCredits.setHoverFormat(null, 40, 0xffff00, "center");
		menu.addItem(btnCredits);
		btnCredits.setCallback(function() { self.changeState(CreditsState); });

		HxlGraphics.fade.start(false, 0xff000000, fadeTime);
	}

	public override function update():Void {
		super.update();			
	}

	function changeState(TargetState:Class<HxlState>) {
		var self = this;
		HxlGraphics.fade.start(true, 0xff000000, fadeTime, function() {
			var newState = Type.createInstance(TargetState, []);
			//HxlGraphics.state = newState;
			// Test code for state stacking
			
			if ( self.stackId == 0 ) {//|| TargetState == CreditsState ) {
				HxlGraphics.state = newState;
			} else {
				if ( TargetState == CreditsState ) HxlGraphics.pushState(new CreditsState());
				else HxlGraphics.popState();
			}
			
		}, true);
	}


}
