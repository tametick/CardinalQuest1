package cq.ui;

import data.Configuration;
import flash.display.Bitmap;

import haxel.HxlSprite;
import haxel.HxlText;
import haxel.HxlGroup;
class CqPause extends HxlGroup {

	/*[Embed(source="key_minus.png")]*/ 
	/*[Embed(source="key_p.png")]*/ 
	/*[Embed(source="key_plus.png")]*/ 
	/*[Embed(source="key_0.png")]*/ 

	var ImgKeyMinus:Class<Bitmap>;
	var ImgKeyPlus:Class<Bitmap>;
	var ImgKey0:Class<Bitmap>;
	var ImgKeyP:Class<Bitmap>;

	public function new() {
		super();
		scrollFactor.x = 0;
		scrollFactor.y = 0;
		add((new HxlSprite()).createGraphic(Configuration.app_width, Configuration.app_height, 0xaa000000, true), true);
		
		//var notif:HxlText = new HxlText(0, 80, 640, "Click to resume",true,null,48,0xffffff,"center");
		//add(notif);
		
		return;
	}

}
