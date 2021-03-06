package cq.effects;

import flash.display.BitmapData;


import haxel.HxlObject;


import haxel.HxlEmitter;
import haxel.HxlGradient;
import haxel.GraphicCache;
import haxel.HxlSprite;
import haxel.HxlUtil;

import cq.CqGraphicKey;
import data.Configuration;

class CqEffectInjure extends HxlEmitter {

	public function new(?X:Float=0, ?Y:Float=0) {
		super(X, Y);
		
		if ( !GraphicCache.checkBitmapCache(CqGraphicKey.InjureEffectParticle) ) {
			var bmp = HxlGradient.CircleData(4, [0xdd1111, 0x3E0101], null, [1.0, 0.65], Math.PI/2);
			GraphicCache.addBitmapData(bmp, CqGraphicKey.InjureEffectParticle);
			bmp.dispose();
			bmp = null;
		}
		setAlphaVelocity(-5, -2);
		gravity = 0.0;
		makeSprites(Configuration.mobile ? 9 : 50);
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
			s.loadCachedGraphic(CqGraphicKey.InjureEffectParticle);
			tf = Math.floor(s.width/s.height);
		}
		for (i in 0...Quantity) {
			s = new HxlSprite();
			if (Multiple) {
				r = Math.floor(HxlUtil.random()*tf);
				if (BakedRotations > 0) {
					s.loadCachedGraphic(CqGraphicKey.InjureEffectParticle);		
				} else {
					s.loadCachedGraphic(CqGraphicKey.InjureEffectParticle);
					s.frame = r;
				}
			} else {
				if (BakedRotations > 0) {
					s.loadCachedGraphic(CqGraphicKey.InjureEffectParticle);
				} else {
					s.loadCachedGraphic(CqGraphicKey.InjureEffectParticle);
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
