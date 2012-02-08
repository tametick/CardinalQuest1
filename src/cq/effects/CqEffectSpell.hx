package cq.effects;

import flash.display.BitmapData;
import haxel.HxlPoint;

import haxel.HxlEmitter;
import haxel.HxlGradient;
import haxel.GraphicCache;
import haxel.HxlSprite;
import haxel.HxlUtil;
import data.Configuration;

import cq.CqGraphicKey;

class CqEffectSpell extends HxlEmitter {
	public function new(?X:Float=0, ?Y:Float=0, colorSource:BitmapData) {
		super(X, Y);
		
		// ?color:Int = 0xD8D049
		/*if ( !GraphicCache.checkBitmapCache(CqGraphicKey.SpellEffectParticle(color))) {
			var bmp = getBall(colorSource);
			GraphicCache.addBitmapData(bmp, CqGraphicKey.SpellEffectParticle(color));
			bmp.dispose();
			bmp = null;
		}*/
		
		//setAlphaVelocity( -3, -1);
		maxParticleScaleVelocity = new HxlPoint(-2, -2);
		minParticleScaleVelocity = new HxlPoint(-4, -4);
		gravity = 0.0;
		makeSprites(colorSource);
	}
	
	public static function randomColorBiased(colorSource:BitmapData, x:Float, y:Float, diverge:Float):UInt {
		x = x + diverge * (Math.random() - .5);
		y = y + diverge * (Math.random() - .5);
		
		if (x < 0.0) x = 0.0;
		if (y < 0.0) y = 0.0;
		if (x > 1.0) x = 1.0;
		if (y > 1.0) y = 1.0;
		
		return colorSource.getPixel(Math.floor(x * colorSource.width), Math.floor(y * colorSource.height));
	}
	
	public static function randomColor(colorSource:BitmapData):UInt {
		return colorSource.getPixel(HxlUtil.randomInt(colorSource.width), HxlUtil.randomInt(colorSource.height));
	}
	
	private function getBall(colorSource:BitmapData):BitmapData {
		return HxlGradient.RectData(9, 9, [randomColorBiased(colorSource, .5, .5, .25), randomColorBiased(colorSource, .5, .5, .5)], null, Math.PI / 2, 9.0);
	}

	
	/*
	 * We can remove this and just use sprites when we have them..
	 */
	function makeSprites(colorSource:BitmapData, ?Quantity:Int=-1, ?BakedRotations:Int=16, ?Multiple:Bool=true, ?Collide:Float=0):HxlEmitter {

		members = new Array();
		var r:Int;
		var s:HxlSprite;
		var tf:Int = 1;
		var sw:Float;
		var sh:Float;
		
		if (Quantity < 0) {
			Quantity = Configuration.mobile ? 20 : 50;
		}
		
		if (Multiple) {
			s = new HxlSprite(0,0);
			//s.loadCachedGraphic(CqGraphicKey.SpellEffectParticle(color));
			s.setPixels(getBall(colorSource));
			tf = Math.floor(s.width/s.height);
		}
		for (i in 0...Quantity) {
			s = new HxlSprite();
			if (Multiple) {
				r = Math.floor(HxlUtil.random() * tf);
				var g = getBall(colorSource);
				if (BakedRotations > 0) {
					//s.loadRotatedGraphic(Graphics,BakedRotations,r);
					s.setPixels(g);
				} else {
					//s.loadGraphic(Graphics,true);
					//s.loadCachedGraphic(CqGraphicKey.SpellEffectParticle(color));
					s.setPixels(g);
					//s.frame = r;
				}
			} else {
				var g = getBall(colorSource);
				if (BakedRotations > 0) {
					//s.loadRotatedGraphic(Graphics,BakedRotations);
					//s.loadCachedGraphic(CqGraphicKey.SpellEffectParticle(color));
					s.setPixels(g);
				} else {
					//s.loadGraphic(Graphics);
					//s.loadCachedGraphic(CqGraphicKey.SpellEffectParticle(color));
					s.setPixels(g);
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
