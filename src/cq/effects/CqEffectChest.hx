package cq.effects;


import haxel.HxlEmitter;
import haxel.HxlGradient;
import haxel.GraphicCache;
import haxel.HxlSprite;
import haxel.HxlUtil;

import cq.CqGraphicKey;

class CqEffectChest extends CachingEmitter {
	static var UNIQUE_EFFECT_ID:Int = 0;
	public function new(?X:Float = 0, ?Y:Float = 0) {
		if ( !GraphicCache.checkBitmapCache(CqGraphicKey.ChestEffectParticle)) {
			//fixme - don't create new color arrays every time!
			var bmp = HxlGradient.RectData(12, 12, [0xe1e1e1, 0x5e5e5e], [0.7, 0.55], Math.PI/2, 12.0);
			GraphicCache.addBitmapData(bmp, CqGraphicKey.ChestEffectParticle);
			bmp.dispose();
			bmp = null;
		}
		setAlphaVelocity(-5, -2);
		gravity = 0.0;
		super(UNIQUE_EFFECT_ID,CqGraphicKey.ChestEffectParticle,X, Y);
	}

	
}
