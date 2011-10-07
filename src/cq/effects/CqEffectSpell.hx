package cq.effects;


import haxel.HxlEmitter;
import haxel.HxlGradient;
import haxel.GraphicCache;
import haxel.HxlSprite;
import haxel.HxlUtil;

import cq.CqGraphicKey;

//TjD NME converted all Int to Int

class CqEffectSpell extends CachingEmitter {
	static var UNIQUE_EFFECT_ID:Int = 10;
	public function new(?X:Float=0, ?Y:Float=0,?color:Int = 0xD8D049) {
		if ( !GraphicCache.checkBitmapCache(CqGraphicKey.SpellEffectParticle(color))) {
			
			//fixme - don't create new color arrays every time!
			
			var bmp = HxlGradient.RectData(12, 12, [color, color+0x222222], [0.8, 0.55], Math.PI/2, 12.0);
			GraphicCache.addBitmapData(bmp, CqGraphicKey.SpellEffectParticle(color));
			bmp.dispose();
			bmp = null;
		}
		setAlphaVelocity(-5, -2);
		gravity = 0.0;
		super(UNIQUE_EFFECT_ID+color,CqGraphicKey.SpellEffectParticle(color),X, Y,color);
	}
}
