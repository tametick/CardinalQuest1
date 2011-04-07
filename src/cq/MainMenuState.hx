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
	var btnResumeGame:HxlMenuItem;
	var btnNewGame:HxlMenuItem;
	var btnCredits:HxlMenuItem;

	public override function create():Void {
		super.create();

		fadeTimer = new HxlTimer();
		fadeTime = 0.5;

		titleText = new HxlText(0, 60, 640, "Main Menu Screen");
		titleText.setFormat(null, 40, 0xff6666, "center");
		add(titleText);

		menu = new HxlMenu(200, 220, 240, 200);
		add(menu);

		var self = this;

		var buttonY:Int = 0;

		if ( stackId != 0 ) {
			var btnResumeGame:HxlMenuItem = new HxlMenuItem(0, buttonY, 240, "Resume Game");
			btnResumeGame.setNormalFormat(null, 40, 0xffffff, "center");
			btnResumeGame.setHoverFormat(null, 40, 0xffff00, "center");
			menu.addItem(btnResumeGame);
			btnResumeGame.setCallback(function() { self.changeState(null); });
			buttonY += 40;
		}

		var btnNewGame:HxlMenuItem = new HxlMenuItem(0, buttonY, 240, "New Game");
		btnNewGame.setNormalFormat(null, 40, 0xffffff, "center");
		btnNewGame.setHoverFormat(null, 40, 0xffff00, "center");
		menu.addItem(btnNewGame);
		btnNewGame.setCallback(function() { self.changeState(CreateCharState); });

		buttonY += 40;

		var btnCredits:HxlMenuItem = new HxlMenuItem(0, buttonY, 240, "Credits");
		btnCredits.setNormalFormat(null, 40, 0xffffff, "center");
		btnCredits.setHoverFormat(null, 40, 0xffff00, "center");
		menu.addItem(btnCredits);
		btnCredits.setCallback(function() { self.changeState(CreditsState); });

		if ( stackId == 0 ) {
			HxlGraphics.fade.start(false, 0xff000000, fadeTime);
		}
	}

	public override function update():Void {
		super.update();			
	}

	function changeState(TargetState:Class<HxlState>) {
		var self = this;
		if ( TargetState == null ) {
			HxlGraphics.popState();
			return;
		}
		HxlGraphics.fade.start(true, 0xff000000, fadeTime, function() {
			var newState = Type.createInstance(TargetState, []);
			if ( self.stackId == 0 ) {
				HxlGraphics.state = newState;
			} else {
				if ( TargetState == CreditsState ) {
					HxlGraphics.pushState(new CreditsState());
				} else {
					HxlGraphics.state = newState;
				}
			}	
		}, true);
	}


}
