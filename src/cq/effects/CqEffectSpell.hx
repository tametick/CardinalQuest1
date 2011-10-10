package cq.effects;

import flash.display.BitmapData;

import haxel.HxlEmitter;
import haxel.HxlGradient;
import haxel.GraphicCache;
import haxel.HxlSprite;
import haxel.HxlUtil;

import cq.CqGraphicKey;

class CqEffectSpell extends HxlEmitter {
	var color:Int;
	public function new(?X:Float=0, ?Y:Float=0,?color:Int = 0xD8D049) {
		super(X, Y);
		this.color = color;
		if ( !GraphicCache.checkBitmapCache(CqGraphicKey.SpellEffectParticle(color))) {
			var bmp = HxlGradient.RectData(12, 12, [color, color+0x222222], [0.8, 0.55], Math.PI/2, 12.0);
			GraphicCache.addBitmapData(bmp, CqGraphicKey.SpellEffectParticle(color));
			bmp.dispose();
			bmp = null;
		}
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
			s.loadCachedGraphic(CqGraphicKey.SpellEffectParticle(color));
			tf = Math.floor(s.width/s.height);
		}
		for (i in 0...Quantity) {
			s = new HxlSprite();
			if (Multiple) {
				r = Math.floor(HxlUtil.random()*tf);
				if (BakedRotations > 0) {
					//s.loadRotatedGraphic(Graphics,BakedRotations,r);
					s.loadCachedGraphic(CqGraphicKey.SpellEffectParticle(color));		
				} else {
					//s.loadGraphic(Graphics,true);
					s.loadCachedGraphic(CqGraphicKey.SpellEffectParticle(color));
					s.frame = r;
				}
			} else {
				if (BakedRotations > 0) {
					//s.loadRotatedGraphic(Graphics,BakedRotations);
					s.loadCachedGraphic(CqGraphicKey.SpellEffectParticle(color));
				} else {
					//s.loadGraphic(Graphics);
					s.loadCachedGraphic(CqGraphicKey.SpellEffectParticle(color));
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
