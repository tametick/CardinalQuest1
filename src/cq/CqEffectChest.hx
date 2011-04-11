package cq;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;

import haxel.HxlEmitter;
import haxel.HxlGradient;
import haxel.HxlGraphics;
import haxel.HxlSprite;
import haxel.HxlUtil;

class CqEffectChest extends HxlEmitter {

	public function new(?X:Float=0, ?Y:Float=0) {
		super(X, Y);
		
		var bmp:BitmapData = HxlGradient.RectData(12, 12, [0xe1e1e1, 0x5e5e5e], [0.7, 0.55], Math.PI/2, 12.0);
		HxlGraphics.addBitmapData(bmp, "ChestEffect");
		setAlphaVelocity(-5, -2);
		gravity = 0.0;
		makeSprites();
	}

	/*
	 * We can remove this and just use sprites when we have them..
	 */
	function makeSprites(?Quantity:Int=50, ?BakedRotations:Int=16, ?Multiple:Bool=true, ?Collide:Float=0):HxlEmitter {

		members = new Array();
		var r:Int;
		var s:HxlSprite;
		var tf:Int = 1;
		var sw:Float;
		var sh:Float;
		if (Multiple) {
			s = new HxlSprite(0,0);
			s.loadCachedGraphic("ChestEffect");
			tf = Math.floor(s.width/s.height);
		}
		for (i in 0...Quantity) {
			s = new HxlSprite();
			if (Multiple) {
				r = Math.floor(HxlUtil.random()*tf);
				if (BakedRotations > 0) {
					//s.loadRotatedGraphic(Graphics,BakedRotations,r);
					s.loadCachedGraphic("ChestEffect");		
				} else {
					//s.loadGraphic(Graphics,true);
					s.loadCachedGraphic("ChestEffect");
					s.frame = r;
				}
			} else {
				if (BakedRotations > 0) {
					//s.loadRotatedGraphic(Graphics,BakedRotations);
					s.loadCachedGraphic("ChestEffect");
				} else {
					//s.loadGraphic(Graphics);
					s.loadCachedGraphic("ChestEffect");
				}
			}
			if (Collide > 0) {
				sw = s.width;
				sh = s.height;
				s.width *= Collide;
				s.height *= Collide;
				s.offset.x = (sw-s.width)/2;
				s.offset.y = (sh-s.height)/2;
				//s.solid = true;
			} else {
				//s.solid = false;
			}
			s.exists = false;
			s.scrollFactor = scrollFactor;
			add(s);
		}
		return this;
	}

}