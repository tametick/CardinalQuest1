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

	public override function create():Void {
		super.create();

		fadeTimer = new HxlTimer();
		fadeTime = 0.5;

		titleText = new HxlText(0, 60, 640, "Main Menu Screen");
		titleText.setFormat(null, 40, 0xff6666, "center");
		add(titleText);

		menu = new HxlMenu(220, 220, 200, 200);
		add(menu);

		var item1:HxlMenuItem = new HxlMenuItem(0, 0, 200, "New Game");
		item1.setNormalFormat(null, 40, 0xffffff, "center");
		item1.setHoverFormat(null, 40, 0xffff00, "center");
		menu.addItem(item1);

		var item2:HxlMenuItem = new HxlMenuItem(0, 40, 200, "Credits");
		item2.setNormalFormat(null, 40, 0xffffff, "center");
		item2.setHoverFormat(null, 40, 0xffff00, "center");
		menu.addItem(item2);


		HxlGraphics.fade.start(false, 0xff000000, fadeTime);
	}

	public override function update():Void {
		super.update();			
	}

}
