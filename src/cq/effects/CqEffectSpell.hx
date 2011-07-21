package cq.effects;

import flash.display.BitmapData;

import haxel.HxlEmitter;
import haxel.HxlGradient;
import haxel.GraphicCache;
import haxel.HxlSprite;
import haxel.HxlUtil;

import cq.CqGraphicKey;

class CqEffectSpell extends CachingEmitter {
	static var UNIQUE_EFFECT_ID:UInt = 1;
	public function new(?X:Float=0, ?Y:Float=0) {
		if ( !GraphicCache.checkBitmapCache(CqGraphicKey.SpellEffectParticle)) {
			var bmp:BitmapData = HxlGradient.RectData(12, 12, [0xD8D049, 0x9E981D], [0.8, 0.55], Math.PI/2, 12.0);
			GraphicCache.addBitmapData(bmp, CqGraphicKey.SpellEffectParticle);
		}
		setAlphaVelocity(-5, -2);
		gravity = 0.0;
		super(UNIQUE_EFFECT_ID,CqGraphicKey.SpellEffectParticle,X, Y);
	}
}
