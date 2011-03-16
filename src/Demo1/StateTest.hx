import flash.media.SoundChannel;
import haxel.HxlGraphics;
import haxel.HxlState;
import haxel.HxlText;
import haxel.HxlSprite;
import haxel.HxlDialog;
import haxel.HxlMenu;
import haxel.HxlMenuItem;
import Resources;

import flash.system.System;

class StateTest extends HxlState
{

	public override function create():Void {
			super.create();

			var myDialog:HxlDialog = new HxlDialog(10, 10, 100, 100);
			add(myDialog);

			var test:HxlText = new HxlText(0, 0, 100, "Test", true);
			test.setFormat("VT323", 36, 0xff0000, "left");
			//add(test);
	
			var test2:HxlText = new HxlText(0, 40, 100, "Test", true);
			test2.setFormat("VT323", 36, 0xff0000, "left");
			//add(test2);

			myDialog.add(test);
			myDialog.add(test2);
			myDialog.velocity.x = 50;

			var spr1:HxlSprite = new HxlSprite( 75, 75);
			spr1.createGraphic(50, 50, 0xffff0000);
			spr1.zIndex = 2;
			add(spr1);

			var spr2:HxlSprite = new HxlSprite( 100, 100);
			spr2.createGraphic(50, 50, 0xff00ff00);
			spr2.zIndex = 3;
			add(spr2);

			var spr3:HxlSprite = new HxlSprite( 125, 125);
			spr3.createGraphic(50, 50, 0xff0000ff);
			spr3.zIndex = 1;
			add(spr3);

			var myMenu:HxlMenu = new HxlMenu(150, 225, 500, 300);
			myMenu.setBackgroundColor(0x99ffaaaa);
			add(myMenu);
			myMenu.setScrollSound(SoundScroll);
			myMenu.setSelectSound(SoundSelect);

			var item1:HxlMenuItem = new HxlMenuItem(5, 5, 490, "Menu Item 1", true, "VT323");
			item1.setNormalFormat("VT323", 24, 0x5555dd, "center", 0xff010101);
			item1.setHoverFormat("VT323", 24, 0xdd5555, "center", 0xff010101);
			myMenu.addItem(item1);	
			
			var item2:HxlMenuItem = new HxlMenuItem(5, 35, 490, "Menu Item 2", true, "VT323");
			item2.setNormalFormat("VT323", 24, 0x5555dd, "center", 0xff010101);
			item2.setHoverFormat("VT323", 24, 0xdd5555, "center", 0xff010101);
			myMenu.addItem(item2);				
	}

}
