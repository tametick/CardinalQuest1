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

class CqEffectInjure extends HxlEmitter {

	static var effectCache:Array<BitmapData> = new Array<BitmapData>();
	static var cacheStatus:Int = 0;//0-nobody filling it up, 1-somebody filling it up, 2-filled up
	static var hs:Int = 100;
	var currentFrame:Int;
	var frameBitmap:HxlSprite;
	var usingCache:Int;//0-isnt using, normal op. 1-this is filling it up. 2-using filled up cache
	public function new(?X:Float=0, ?Y:Float=0) {
		super(X, Y);
		
		if ( !GraphicCache.checkBitmapCache(CqGraphicKey.InjureEffectParticle) ) {
			var bmp:BitmapData = HxlGradient.CircleData(4, [0xdd1111, 0x3e0101], [1.0, 0.65], Math.PI/2);
			GraphicCache.addBitmapData(bmp, CqGraphicKey.InjureEffectParticle);
		}
		switch(cacheStatus){
			case 0:
				cacheStatus = usingCache = 1;	
				setAlphaVelocity(-5, -2);
				gravity = 0.0;
				currentFrame = 0;
				makeSprites();
			case 1:
				usingCache = 0;	
				setAlphaVelocity(-5, -2);
				gravity = 0.0;
				currentFrame = 0;
				makeSprites();
			case 2:
				usingCache = 2;	
				frameBitmap = new HxlSprite();
				frameBitmap.y = y-hs;
				frameBitmap.x = x-hs;
				frameBitmap.pixels = effectCache[0];
				add(frameBitmap);
				currentFrame = -1;
		}
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
	override function update()
	{
		if (0 == usingCache)//uncached run
			super.update();
		else
			updateMembers();
	}
	
	static var rect:Rectangle = new Rectangle();
	static var alphaBitmapData:BitmapData = new BitmapData(30,30,true,0);
	static var dest:Point = new Point();
	static var pt:Point = new Point();
	override function updateMembers() {
		currentFrame++;
		if (2 == usingCache) {
			if (currentFrame >= effectCache.length)
			{
				kill();
				return;
			}else {	
				frameBitmap.pixels = effectCache[currentFrame];
			}
		}else if(1 == usingCache){
			super.updateEmitter();
			var frame:BitmapData = new BitmapData(hs<<1,hs<<1,true,0);
			var o:HxlSprite;
			var l:Int = members.length;
			for (i in 0...l) {
				o = cast( members[i], HxlSprite);
				if ((o != null) && o.exists && o.active) {
					o.update();
					dest.x = x - o.x+hs;
					dest.y = y - o.y+hs;
					rect.width = o.width+2;
					rect.height = o.height + 2;
					var argb:UInt = 0;
					argb += (Std.int(o.alpha * 255) << 24);
					argb += 0xFFFFFF;
					alphaBitmapData.floodFill(0, 0, argb );
					frame.copyPixels(o.pixels, rect, dest,alphaBitmapData,pt,false);
				}
			}
			effectCache.push(frame);
		}
		
	}
	public override function kill() {
		super.kill();
		on = false;
		if (1 == usingCache)
		{
			cacheStatus = 2;
		}
	}

}
