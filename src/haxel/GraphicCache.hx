package haxel;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.geom.Matrix;
/**
 * a container for graphics, moved out from HxlGraphics.
 */

class GraphicCache 
{
	/**
	 * Internal storage system to prevent graphics from being used repeatedly in memory.
	 */
	static var cache:Hash<BitmapData> = new Hash<BitmapData>();
	/**
	 * Returns a BitmapData object for the cached graphic matching the supplied key.
	 * If a matching bitmap is not found, returns a 20x20 pixel red square.
	 **/
	public static function getBitmap(Key:Dynamic):BitmapData {
		var keyStr:String = HxlUtil.enumToString( Key );
		if ( Key == null || !checkBitmapCacheStr(keyStr) ) 
			return createBitmap(20, 20, 0xff0000); 
		return cache.get(keyStr);
	}
	
	/**
	 * Loads a bitmap from a file, caches it, and generates a horizontally flipped version if necessary.
	 * 
	 * @param	Graphic		The image file that you want to load.
	 * @param	Reverse		Whether to generate a flipped version.
	 * 
	 * @return	The <code>BitmapData</code> we just created.
	 */
	public static function addBitmap(Graphic:Class<Bitmap>,?Reverse:Bool=false, ?Unique:Bool=false, ?Key:Dynamic=null, ?ScaleX:Float=1.0, ?ScaleY:Float=1.0):BitmapData {
		var needReverse:Bool = false;//TODO this should actually do the reversing
		var key:String = "";
		if ( Key == null ) {
			key = Type.getClassName(Graphic);
			if ( ScaleX != 1.0 || ScaleY != 1.0 ) key = key+"-"+ScaleX+"x"+ScaleY;
			if(Unique && cache.exists(key) && cache.get(key) != null) {
				//Generate a unique key
				var inc:Int = 0;
				var ukey:String;
				do {
					ukey = key + inc++;
				} while(cache.exists(ukey) && cache.get(ukey) != null);
				key = ukey;
			}
		} else {
			key = HxlUtil.enumToString( Key );
		}

		//If there is no data for this key, generate the requested graphic
		if (!checkBitmapCache(Key)) {
			var bd:BitmapData = Type.createInstance(Graphic, []).bitmapData;
			if ( ScaleX != 1.0 || ScaleY != 1.0 ) {
				var newPixels:BitmapData = new BitmapData(Std.int(bd.width * ScaleX), Std.int(bd.height * ScaleY), true, 0x00000000);
				var mtx:Matrix = new Matrix();
				mtx.scale(ScaleX, ScaleY);
				newPixels.draw(bd, mtx);
				bd = newPixels;
			}
			cache.set(key, bd);
			if (Reverse) needReverse = true;
		}

		var pixels:BitmapData = cache.get(key);

		if (!needReverse && Reverse && (pixels.width == Type.createInstance(Graphic, []).bitmapData.width)) {
			needReverse = true;
		}
		if (needReverse) {
			var newPixels:BitmapData = new BitmapData(pixels.width<<1,pixels.height,true,0x00000000);
			newPixels.draw(pixels);
			var mtx:Matrix = new Matrix();
			mtx.scale(-1,1);
			mtx.translate(newPixels.width,0);
			newPixels.draw(pixels,mtx);
			pixels = newPixels;
		}
		if ( pixels == null )
		{
			throw "Cannot find specified graphics: "+Graphic;
		}
		return pixels;

	}

	public static function clearBitmapData() {
		var fieldNames:Array<String> = new Array();
		for (k in cache.keys())
			fieldNames.push(k);
		
		for (fieldName in fieldNames) {
			cache.get(fieldName).dispose();
			cache.remove(fieldName);
		}
		fieldNames = null;
	}
	
	public static function addBitmapData(Graphic:BitmapData, ?Key:Dynamic=null, ?Force:Bool=false):BitmapData {
		var inc:Int;
		var ukey:String;
		var keystr:String;
		if(Key == null) {
			keystr = "data-"+Graphic.width+"x"+Graphic.height;
			if ( cache.exists(keystr) && cache.get(keystr) != null) {
				//Generate a unique key
				inc = 0;
				do { ukey = keystr + inc++;
				} while(cache.exists(ukey) && cache.get(ukey) != null);
				keystr = ukey;
			}
		}else
		{
			keystr = HxlUtil.enumToString(Key);
		}
		if ( !checkBitmapCache(Key) || Force ) {
			if (checkBitmapCache(Key)) {
				// dispose old in case of forcing
				cache.get(keystr).dispose();
			}
			
			var bd:BitmapData = new BitmapData( Graphic.width, Graphic.height, true, 0x00000000 );
			bd.draw(Graphic);
			cache.set(keystr, bd);
		}
		if ( cache.get(keystr) == null ) {
			throw "Cannot find in graphics cache: "+keystr;
		}
		return cache.get(keystr);
	}
	/**
	 * Check the local bitmap cache to see if a bitmap with this key has been loaded already.
	 *
	 * @param	Key		The string key identifying the bitmap.
	 * 
	 * @return	Whether or not this file can be found in the cache.
	 */
	public static function checkBitmapCache(Key:Dynamic):Bool {
		if (Key == null) return false;
		var keyStr:String = HxlUtil.enumToString(Key);
		return cache.exists(keyStr) && cache.get(keyStr) != null;
	}
	private static function checkBitmapCacheStr(keyStr:String):Bool {
		return cache.exists(keyStr) && cache.get(keyStr) != null;
	}
	/**
	 * Generates a new <code>BitmapData</code> object (a colored square) and caches it.
	 * 
	 * @param	Width	How wide the square should be.
	 * @param	Height	How high the square should be.
	 * @param	Color	What color the square should be (0xAARRGGBB)
	 * 
	 * @return	The <code>BitmapData</code> we just created.
	 */
	public static function createBitmap(Width:Int, Height:Int, Color:Int, ?Unique:Bool=false, ?Key:Dynamic=null):BitmapData {
		var keystr:String = "";
		if (Key == null)
		{
			//todo, check if its the same string as cqgraphicCache.oneColor
			keystr = "CqGraphicKeyOneColor" + Width + Height + Color;
			if (Unique && cache.exists(keystr) && cache.get(keystr)!=null) {
				//Generate a unique key
				var inc:Int = 0;
				var ukey:String;
				do {
					ukey = keystr + inc++;
				} while(cache.exists(ukey) && cache.get(ukey) != null);
				keystr = ukey;
			}
		}
		if (!checkBitmapCacheStr(keystr)) {
			cache.set(keystr, new BitmapData(Width, Height, true, Color));
		}
		if ( cache.get(keystr) == null) {
			throw "" + keystr + Width + Height + Key + Unique;
		}
		return cache.get(keystr);
	}
}