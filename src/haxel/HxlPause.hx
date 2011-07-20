package haxel;

import flash.display.Bitmap;

import haxel.HxlGroup;
import haxel.HxlGraphics;
import haxel.HxlSprite;
import haxel.HxlText;

class HxlPause extends HxlGroup {

	/*[Embed(source="key_minus.png")]*/ 
	/*[Embed(source="key_p.png")]*/ 
	/*[Embed(source="key_plus.png")]*/ 
	/*[Embed(source="key_0.png")]*/ 

	var ImgKeyMinus:Class<Bitmap>;
	var ImgKeyPlus:Class<Bitmap>;
	var ImgKey0:Class<Bitmap>;
	var ImgKeyP:Class<Bitmap>;

	/**
	 * Constructor.
	 */
	public function new()
	{
		super();
		scrollFactor.x = 0;
		scrollFactor.y = 0;
		var w:Int = 80;
		var h:Int = 92;
		//x = (HxlGraphics.width-w)/2;
		//y = (HxlGraphics.height - h) / 2;
		add((new HxlSprite()).createGraphic(HxlGraphics.width, HxlGraphics.height, 0xaa000000, true), true);
		var notif:HxlText = new HxlText(HxlGraphics.width / 2-80, 80, 500, "Press mouse or any key to resume");
		notif.setSize(20);
		notif.alignment = "left";
		add(notif);
		return;
		add((new HxlText(0,10,w,"PAUSED")).setFormat("",16,0xffffff,"center"),true);
		//add(new HxlSprite(4,36,ImgKeyP),true);
		add(new HxlText(16,36,w-16,"Pause Game"),true);
		//add(new HxlSprite(4,50,ImgKey0),true);
		add(new HxlText(16,50,w-16,"Mute Sound"),true);
		//add(new HxlSprite(4,64,ImgKeyMinus),true);
		add(new HxlText(16,64,w-16,"Sound Down"),true);
		//add(new HxlSprite(4,78,ImgKeyPlus),true);
		add(new HxlText(16,78,w-16,"Sound Up"),true);
	}

}
