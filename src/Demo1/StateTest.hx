import flash.media.SoundChannel;
import haxel.HxlGraphics;
import haxel.HxlState;
import haxel.HxlText;
import haxel.HxlSprite;
import haxel.HxlDialog;
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

			//remove(spr2);

			//defaultGroup.sortMembersByZIndex();
			HxlGraphics.log(System.totalMemory);
			var memoryUsedInKb = (System.totalMemory/1024);
			HxlGraphics.log(memoryUsedInKb+"KB");
	}

}
