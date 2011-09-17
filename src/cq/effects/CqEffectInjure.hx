package cq.effects;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxel.HxlGraphics;
import haxel.HxlObject;
import haxel.HxlPoint;

import haxel.HxlEmitter;
import haxel.HxlGradient;
import haxel.GraphicCache;
import haxel.HxlSprite;
import haxel.HxlUtil;

import cq.CqGraphicKey;

class CqEffectInjure extends CachingEmitter {
	static var UNIQUE_EFFECT_ID:Int = 5;
	public function new(?X:Float=0, ?Y:Float=0) {
		if ( !GraphicCache.checkBitmapCache(CqGraphicKey.InjureEffectParticle) ) {
			//fixme - don't create new color arrays every time!
			
			var bmp:BitmapData = HxlGradient.CircleData(4, [0xdd1111, 0x3E0101], [1.0, 0.65], Math.PI/2);
			GraphicCache.addBitmapData(bmp, CqGraphicKey.InjureEffectParticle);
			bmp.dispose();
			bmp = null;
		}
		setAlphaVelocity(-5, -2);
		gravity = 0.0;
		super(UNIQUE_EFFECT_ID,CqGraphicKey.InjureEffectParticle,X, Y);
	}
}
