package detribus;

import flash.media.SoundChannel;
import haxel.HxlGraphics;
import haxel.HxlState;
import haxel.HxlText;
import detribus.Resources;
import haxel.HxlSound;
import haxel.HxlGraphics;

class StateTitle extends BaseMenuState {
	
	var titleMenu:Menu;
	public static var menuMusic:HxlSound;
	
	public override function create():Void {
		super.create();

		if ( menuMusic == null) {
			menuMusic = new HxlSound();
			menuMusic.loadEmbedded(Rain, true);
			menuMusic.play();
		}
		
		var titleText:HxlText = new HxlText(0, 20, 360, "Detribus", true);
		titleText.setFormat("FontDungeon", 80, 0xffffff, "center", 0x010101);
		add(titleText);
		
		titleMenu = new Menu(80, 120, 200, 100 );
		add(titleMenu);
		
		var item1:MenuItem = new MenuItem(10, 10, 180, "New Game");
		item1.setFormat("FontDungeon", 24, 0x000000, "center");
		titleMenu.addItem(item1);
		item1.itemCallback = function() { 
			BaseMenuState.playSelectSound();
			HxlGraphics.fade.start(true, 0xffffffff, 0.25, function() {
				HxlGraphics.state = new StateHelp();
				cast(HxlGraphics.state, StateHelp).startGame = true;				
			}, true);
		};
		
		var item2:MenuItem = new MenuItem(10, 36, 180, "Help");
		item2.setFormat("FontDungeon", 24, 0x000000, "center");
		titleMenu.addItem(item2);
		item2.itemCallback = function() { 
			BaseMenuState.playSelectSound();
			HxlGraphics.fade.start(true, 0xffffffff, 0.25, function() {
				var help = new StateHelp();
				help.startGame = false;
				HxlGraphics.state  = help;
			}, true);
		};
		
		HxlGraphics.fade.start(false, 0xffffffff, 0.25);

	}	
	
	public override function update():Void {
		super.update();		
	}
	
}
