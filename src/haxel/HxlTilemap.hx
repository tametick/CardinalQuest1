package haxel;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.ColorTransform;

#if flash9
import flash.display.BlendMode;
#end

/**
 * This is a traditional tilemap display and collision class.
 * It takes a string of comma-separated numbers and then associates
 * those values with tiles from the sheet you pass in.
 * It also includes some handy static parsers that can convert
 * arrays or PNG files into strings that can be successfully loaded.
 */
class HxlTilemap extends HxlObject {

	/*[Embed(source="data/autotiles.png")]*/
	/*[Embed(source="data/autotiles_alt.png")]*/ 
	public static var ImgAuto:Class<Bitmap>;
	public static var ImgAutoAlt:Class<Bitmap>;

	public var alpha(getAlpha, setAlpha) : Float;

	/**
	 * No auto-tiling.
	 */
	public static var OFF:Int = 0;
	/**
	 * Platformer-friendly auto-tiling.
	 */
	public static var AUTO:Int = 1;
	/**
	 * Top-down auto-tiling.
	 */
	public static var ALT:Int = 2;
	
	/**
	 * What tile index will you start colliding with (default: 1).
	 */
	public var collideIndex:Int;
	/**
	 * The first index of your tile sheet (default: 0) If you want to change it, do so before calling loadMap().
	 */
	public var startingIndex:Int;
	/**
	 * What tile index will you start drawing with (default: 1)  NOTE: should always be >= startingIndex.
	 * If you want to change it, do so before calling loadMap().
	 */
	public var drawIndex:Int;
	/**
	 * Set this flag to use one of the 16-tile binary auto-tile algorithms (OFF, AUTO, or ALT).
	 */
	public var auto:Int;
	
	/**
	 * Read-only variable, do NOT recommend changing after the map is loaded!
	 */
	public var widthInTiles:Int;
	/**
	 * Read-only variable, do NOT recommend changing after the map is loaded!
	 */
	public var heightInTiles:Int;
	/**
	 * Read-only variable, do NOT recommend changing after the map is loaded!
	 */
	public var totalTiles:Int;
	public var mapData:Array<Array<Int>>;
	/**
	 * Rendering helper.
	 */
	var _flashRect:Rectangle;
	
	var _pixels:BitmapData;
	var _bbPixels:BitmapData;
	var _bbKey:String;
	//var _data:Array<Int>;
	var _tileWidth:Int;
	var _tileHeight:Int;
	var _block:HxlObject;
	var _callbacks:Array<Dynamic>;
	var _screenRows:Int;
	var _screenCols:Int;

	var _tiles:Array<Array<HxlTile>>;

	/**
	 * Blending modes, just like Photoshop!
	 * E.g. "multiply", "screen", etc.
	 * @default null
	 */
	public var blend:String;
	var _alpha:Float;
	var _color:Int;
	var _ct:ColorTransform;
	var _mtx:Matrix;

	public var tileClass:Class<HxlTile>;

	/**
	 * The tilemap constructor just initializes some basic variables.
	 */
	public function new()
	{
		super();
		auto = OFF;
		collideIndex = 1;
		startingIndex = 0;
		drawIndex = 1;
		widthInTiles = 0;
		heightInTiles = 0;
		totalTiles = 0;
		//_data = null;
		_tileWidth = 0;
		_tileHeight = 0;
		//_rects = null;
		_pixels = null;
		_block = new HxlObject();
		_block.width = _block.height = 0;
		//_block.fixed = true;
		_callbacks = new Array();
		//fixed = true;

		_alpha = 1;
		_color = 0x00ffffff;
		_mtx = new Matrix();
		blend = null;

		tileClass = HxlTile;
	}

	/**
	 * Load the tilemap with string data and a tile graphic.
	 * 
	 * @param	MapData			2d array of Ints, specifies index of sprite to use from TileGraphic.	
	 * @param	TileGraphic		All the tiles you want to use, arranged in a strip corresponding to the numbers in MapData.
	 * @param	TileWidth		The width of your tiles (e.g. 8) - defaults to height of the tile graphic if unspecified.
	 * @param	TileHeight		The height of your tiles (e.g. 8) - defaults to width if unspecified.
	 * @param 	ScaleX 			Desired X scale of the rendered graphics.
	 * @param 	ScaleY 			Desired Y scale of the rendered graphics.
	 * 
	 * @return	A pointer this instance of HxlTilemap, for chaining as usual :)
	 */
	public function loadMap(MapData:Array<Array<Int>>, TileGraphic:Class<Bitmap>, ?TileWidth:Int = 0, ?TileHeight:Int = 0, ?ScaleX:Float=1.0, ?ScaleY:Float=1.0):HxlTilemap {
		mapData = MapData;
		
		//Figure out the map dimensions based on the mapdata
		var c:Int;
		heightInTiles = MapData.length;
		widthInTiles = MapData[0].length;
		
		//Pre-process the map data if it's auto-tiled
		var i:Int;
		totalTiles = widthInTiles*heightInTiles;
		/*
		if (auto > OFF) {
			collideIndex = startingIndex = drawIndex = 1;
			for (i in 0...totalTiles) {
				autoTile(i);
			}
		}
		*/

		//Figure out the size of the tiles
		_pixels = HxlGraphics.addBitmap(TileGraphic, false, false, null, ScaleX, ScaleY);
		if ( ScaleX != 1.0 && ScaleX > 0.0 ) TileWidth = Std.int(TileWidth * ScaleX);
		if ( ScaleY != 1.0 && ScaleY > 0.0 ) TileHeight = Std.int(TileHeight * ScaleY);
		_tileWidth = TileWidth;
		if (_tileWidth == 0) {
			_tileWidth = _pixels.height;
		}
		_tileHeight = TileHeight;
		if (_tileHeight == 0) {
			_tileHeight = _tileWidth;
		}
		_block.width = _tileWidth;
		_block.height = _tileHeight;
	
		//Then go through and create the actual map
		width = widthInTiles*_tileWidth;
		height = heightInTiles*_tileHeight;

		var rx:Int;
		var ry:Int;
		_tiles = new Array();
		for ( y in 0...heightInTiles ) {
			_tiles[y] = new Array();
			for ( x in 0...widthInTiles ) {
				_tiles[y][x] = Type.createInstance(tileClass, [x, y]);
				updateTileGraphic(x, y, MapData[y][x]);
			}
		}

		//Pre-set some helper variables for later
		_screenRows = Math.ceil(HxlGraphics.height/_tileHeight)+1;
		if (_screenRows > heightInTiles) {
			_screenRows = heightInTiles;
		}
		_screenCols = Math.ceil(HxlGraphics.width/_tileWidth)+1;
		if (_screenCols > widthInTiles) {
			_screenCols = widthInTiles;
		}
		
		_bbKey = Std.string(TileGraphic);
		//generateBoundingTiles();
		//refreshHulls();
		
		return this;
	}

	public function getTiles():Array<Array<HxlTile>> {
		return _tiles;
	}

	/**
	 * Generates a bounding box version of the tiles, flixel should call this automatically when necessary.
	 */
	function generateBoundingTiles():Void {
		return;
		/*
		if ((_bbKey == null) || (_bbKey.length <= 0)) {
			return;
		}
		
		//Check for an existing version of this bounding boxes tilemap
		var bbc:Int = getBoundingColor();
		var key:String = _bbKey + ":BBTILES" + bbc;
		var skipGen:Bool = HxlGraphics.checkBitmapCache(key);
		_bbPixels = HxlGraphics.createBitmap(_pixels.width, _pixels.height, 0, true, key);
		if (!skipGen) {
			//Generate a bounding boxes tilemap for this color
			_flashRect = new Rectangle();
			_flashRect.width = _pixels.width;
			_flashRect.height = _pixels.height;
			_flashPoint.x = 0;
			_flashPoint.y = 0;
			
			_bbPixels.copyPixels(_pixels,_flashRect,_flashPoint);
			_flashRect.width = _tileWidth;
			_flashRect.height = _tileHeight;
			
			//Check for an existing non-collide bounding box stamp
			var ov:Bool = false;//_solid;
			//_solid = false;
			bbc = getBoundingColor();
			key = "BBTILESTAMP"+_tileWidth+"X"+_tileHeight+bbc;
			skipGen = HxlGraphics.checkBitmapCache(key);
			var stamp1:BitmapData = HxlGraphics.createBitmap(_tileWidth, _tileHeight, 0, true, key);
			if (!skipGen) {
				//Generate a bounding boxes stamp for this color
				stamp1.fillRect(_flashRect,bbc);
				_flashRect.x = _flashRect.y = 1;
				_flashRect.width -= 2;
				_flashRect.height -= 2;
				stamp1.fillRect(_flashRect,0);
				_flashRect.x = _flashRect.y = 0;
				_flashRect.width = _tileWidth;
				_flashRect.height = _tileHeight;
			}
			//_solid = ov;
			
			//Check for an existing collide bounding box
			bbc = getBoundingColor();
			key = "BBTILESTAMP"+_tileWidth+"X"+_tileHeight+bbc;
			skipGen = HxlGraphics.checkBitmapCache(key);
			var stamp2:BitmapData = HxlGraphics.createBitmap(_tileWidth, _tileHeight, 0, true, key);
			if (!skipGen) {
				//Generate a bounding boxes stamp for this color
				stamp2.fillRect(_flashRect,bbc);
				_flashRect.x = _flashRect.y = 1;
				_flashRect.width -= 2;
				_flashRect.height -= 2;
				stamp2.fillRect(_flashRect,0);
				_flashRect.x = _flashRect.y = 0;
				_flashRect.width = _tileWidth;
				_flashRect.height = _tileHeight;
			}
			
			//Stamp the new tile bitmap with the bounding box border
			var r:Int;
			var c:Int;
			var i:Int = 0;
			r = 0;
			while (r < _bbPixels.height) {
				c = 0;
				while (c < _bbPixels.width) {
					_flashPoint.x = c;
					_flashPoint.y = r;
					if (i++ < collideIndex) {
						_bbPixels.copyPixels(stamp1,_flashRect,_flashPoint,null,null,true);
					} else {
						_bbPixels.copyPixels(stamp2,_flashRect,_flashPoint,null,null,true);
					}
					c += _tileWidth;
				}
				r += _tileHeight;
			}
		}
		*/
	}

	/**
	 * Internal function that actually renders the tilemap.  Called by render().
	 */
	function renderTilemap():Void
	{

		//Bounding box display options
		var tileBitmap:BitmapData;
		if (HxlGraphics.showBounds) {
			tileBitmap = _bbPixels;
		} else {
			tileBitmap = _pixels;
		}

		var tmpBitmap:BitmapData = new BitmapData(_tileWidth, _tileHeight, true, 0x00ffffff);
		var tmpRect:Rectangle = new Rectangle(0, 0, _tileWidth, _tileHeight);

		getScreenXY(_point);
		_flashPoint.x = _point.x;
		_flashPoint.y = _point.y;
		var tx:Int = Math.floor(-_flashPoint.x/_tileWidth);
		var ty:Int = Math.floor(-_flashPoint.y/_tileHeight);
		if (tx < 0) tx = 0;
		if (tx > widthInTiles-_screenCols) tx = widthInTiles-_screenCols;
		if (ty < 0) ty = 0;
		if (ty > heightInTiles-_screenRows) ty = heightInTiles-_screenRows;
		_flashPoint.x += tx*_tileWidth;
		_flashPoint.y += ty*_tileHeight;
		var opx:Int = Std.int(_flashPoint.x);
		var c:Int;
		var tile:HxlTile;
		for (r in 0..._screenRows) {
			for (c in 0..._screenCols) {
				tile = _tiles[r+ty][c+tx];
				if ( tile.bitmapRect != null ) {
					if ( tile._ct == null ) {
						HxlGraphics.buffer.copyPixels(tileBitmap, tile.bitmapRect, _flashPoint, null, null, true);
					} else {
						#if flash9
						_mtx.identity();
						_mtx.translate(_flashPoint.x, _flashPoint.y);
						tmpBitmap.fillRect( tmpRect, 0xffFF0000);
						tmpBitmap.copyPixels(tileBitmap, tile.bitmapRect, new Point(0, 0), null, null, true);
						tmpBitmap.colorTransform( tmpRect,  tile._ct);
						HxlGraphics.buffer.copyPixels(tmpBitmap, tmpRect, _flashPoint, null, null, true);
						#else
						// TODO: Get this working in CPP
						HxlGraphics.buffer.copyPixels(tileBitmap, tile.bitmapRect, _flashPoint, null, null, true);
						#end
					}
					HxlGraphics.numRenders++;
				}
				_flashPoint.x += _tileWidth;
			}
			_flashPoint.x = opx;
			_flashPoint.y += _tileHeight;
		}

	}

	/**
	 * Draws the tilemap.
	 */
	public override function render():Void {
		renderTilemap();
	}

	/**
	 * Returns the tile which exists at the specified coordinate.
	 *
	 * @param	X		X coordinate of the tile (in tiles, not pixels).
	 * @param	Y		Y coordinate of the tile (in tiles, not pixels).
	 *
	 * @return HxlTile object
	 **/
	public function getTile(X:Dynamic, Y:Dynamic):Dynamic {
		X = Math.round(X);
		Y = Math.round(Y);
		if ( Y >= _tiles.length || Y < 0 || X >= _tiles[0].length || X < 0 ) return null;
		return _tiles[Y][X];
	}

	/**
	 * Returns an HxlPoint containing the world position of a tile.
	 * 
	 * @param	X		X coordinate of target tile (in tiles, not pixels).
	 * @param	Y		Y coordinate of target tile (in tiles, not pixels).
	 * @param	Center	If true, returns point centered on tile.
	 * @return HxlPoint object
	 */
	public function getTilePos(X:Dynamic, Y:Dynamic, ?Center:Bool=false):HxlPoint {
		var pos:HxlPoint = new HxlPoint();
		pos.x = x + (X * _tileWidth);
		pos.y = y + (Y * _tileHeight);
		if ( Center ) {
			pos.x += (_tileWidth / 2);
			pos.y += (_tileHeight / 2);
		}
		return pos;
	}

	/**
	 * Change the data and graphic of a tile in the tilemap.
	 * 
	 * @param	X				The X coordinate of the tile (in tiles, not pixels).
	 * @param	Y				The Y coordinate of the tile (in tiles, not pixels).
	 * @param	Tile			The new integer data you wish to inject.
	 * @param	UpdateGraphics	Whether the graphical representation of this tile should change.
	 * 
	 * @return	Whether or not the tile was actually changed.
	 */ 
	/*
	public function setTile(X:Int,Y:Int,Tile:Int,?UpdateGraphics:Bool=true):Bool {
		if ((X >= widthInTiles) || (Y >= heightInTiles)) {
			return false;
		}
		return setTileByIndex(Y * widthInTiles + X,Tile,UpdateGraphics);
	}
	*/

	/**
	 * Change the data and graphic of a tile in the tilemap.
	 * 
	 * @param	Index			The slot in the data array (Y * widthInTiles + X) where this tile is stored.
	 * @param	Tile			The new integer data you wish to inject.
	 * @param	UpdateGraphics	Whether the graphical representation of this tile should change.
	 * 
	 * @return	Whether or not the tile was actually changed.
	 */
	/*
	public function setTileByIndex(Index:Int,Tile:Int,?UpdateGraphics:Bool=true):Bool {
		if (Index >= _data.length) {
			return false;
		}
		
		var ok:Bool = true;
		_data[Index] = Tile;
		
		if (!UpdateGraphics) {
			return ok;
		}
		
		if (auto == OFF) {
			updateTile(Index);
			return ok;
		}

		//If this map is autotiled and it changes, locally update the arrangement
		var i:Int;
		var r:Int = Std.int(Index/widthInTiles) - 1;
		var rl:Int = r+3;
		var c:Int = Index%widthInTiles - 1;
		var cl:Int = c+3;
		while (r < rl) {
			for (c in 3...cl) {
				if ((r >= 0) && (r < heightInTiles) && (c >= 0) && (c < widthInTiles)) {
					i = r*widthInTiles+c;
					autoTile(i);
					updateTile(i);
				}
			}
			r++;
		}
		
		return ok;
	}
	*/

	/**
	 * Call this function to lock the automatic camera to the map's edges.
	 * 
	 * @param	Border		Adjusts the camera follow boundary by whatever number of tiles you specify here.  Handy for blocking off deadends that are offscreen, etc.  Use a negative number to add padding instead of hiding the edges.
	 */
	public function follow(?Border:Int=0):Void {
		HxlGraphics.followBounds(Std.int(x+Border*_tileWidth),Std.int(y+Border*_tileHeight),Std.int(width-Border*_tileWidth),Std.int(height-Border*_tileHeight));
	}

	/**
	 * Shoots a ray from the start point to the end point.
	 * If/when it passes through a tile, it stores and returns that point.
	 * 
	 * @param	StartX		The X component of the ray's start.
	 * @param	StartY		The Y component of the ray's start.
	 * @param	EndX		The X component of the ray's end.
	 * @param	EndY		The Y component of the ray's end.
	 * @param	Result		A <code>Point</code> object containing the first wall impact.
	 * @param	Resolution	Defaults to 1, meaning check every tile or so.  Higher means more checks!
	 * @return	Whether or not there was a collision between the ray and a colliding tile.
	 */
	public function ray(StartX:Float, StartY:Float, EndX:Float, EndY:Float, Result:HxlPoint, ?Resolution:Int=1):Bool {
		// TODO: Replace this function! We should probably just have a bresenham function in HxlUtil
		return false;
		/*
		var step:Float = _tileWidth;
		if (_tileHeight < _tileWidth) {
			step = _tileHeight;
		}
		step /= Resolution;
		var dx:Float = EndX - StartX;
		var dy:Float = EndY - StartY;
		var distance:Float = Math.sqrt(dx*dx + dy*dy);
		var steps:Int = Math.ceil(distance/step);
		var stepX:Float = dx/steps;
		var stepY:Float = dy/steps;
		var curX:Float = StartX - stepX;
		var curY:Float = StartY - stepY;
		var tx:Int;
		var ty:Int;
		for (i in 0...steps) {
			curX += stepX;
			curY += stepY;
			
			if ((curX < 0) || (curX > width) || (curY < 0) || (curY > height)) {
				continue;
			}
			
			tx = Std.int(curX/_tileWidth);
			ty = Std.int(curY/_tileHeight);
			if ((cast( _data[ty*widthInTiles+tx], Int)) >= collideIndex) {
				//Some basic helper stuff
				tx *= _tileWidth;
				ty *= _tileHeight;
				var rx:Float = 0;
				var ry:Float = 0;
				var q:Float;
				var lx:Float = curX-stepX;
				var ly:Float = curY-stepY;
				
				//Figure out if it crosses the X boundary
				q = tx;
				if (dx < 0) {
					q += _tileWidth;
				}
				rx = q;
				ry = ly + stepY*((q-lx)/stepX);
				if ((ry > ty) && (ry < ty + _tileHeight)) {
					if (Result == null) {
						Result = new HxlPoint();
					}
					Result.x = rx;
					Result.y = ry;
					return true;
				}
				
				//Else, figure out if it crosses the Y boundary
				q = ty;
				if (dy < 0) {
					q += _tileHeight;
				}
				rx = lx + stepX*((q-ly)/stepY);
				ry = q;
				if ((rx > tx) && (rx < tx + _tileWidth)) {
					if (Result == null) {
						Result = new HxlPoint();
					}
					Result.x = rx;
					Result.y = ry;
					return true;
				}
				return false;
			}
		}
		return false;
		*/
	}

	/**
	 * Converts a one-dimensional array of tile data to a comma-separated string.
	 * 
	 * @param	Data		An array full of integer tile references.
	 * @param	Width		The number of tiles in each row.
	 * 
	 * @return	A comma-separated string containing the level data in a <code>FlxTilemap</code>-friendly format.
	 */
	public static function arrayToCSV(Data:Array<Int>,Width:Int):String
	{
		var r:Int;
		var c:Int;
		var csv:String = "";
		var Height:Int = Std.int(Data.length / Width);
		for (r in 0...Height) {
			for (c in 0...Width) {
				if (c == 0) {
					if (r == 0) {
						csv += Data[0];
					} else {
						csv += "\n"+Data[r*Width];
					}
				} else {
					csv += ", "+Data[r*Width+c];
				}
			}
		}
		return csv;
	}

	/**
	 * An internal function used by the binary auto-tilers.
	 * 
	 * @param	Index		The index of the tile you want to analyze.
	 */
	function autoTile(Index:Int):Void {
		return;
		/*
		if (_data[Index] == 0) return;
		_data[Index] = 0;
		if ((Index-widthInTiles < 0) || (_data[Index-widthInTiles] > 0)) { 		//UP
			_data[Index] += 1;
		}
		if ((Index%widthInTiles >= widthInTiles-1) || (_data[Index+1] > 0)) { 		//RIGHT
			_data[Index] += 2;
		}
		if ((Index+widthInTiles >= totalTiles) || (_data[Index+widthInTiles] > 0)) { //DOWN
			_data[Index] += 4;
		}
		if ((Index%widthInTiles <= 0) || (_data[Index-1] > 0)) { 					//LEFT
			_data[Index] += 8;
		}
		if ((auto == ALT) && (_data[Index] == 15)) {	//The alternate algo checks for interior corners
			if ((Index%widthInTiles > 0) && (Index+widthInTiles < totalTiles) && (_data[Index+widthInTiles-1] <= 0)) {
				_data[Index] = 1;		//BOTTOM LEFT OPEN
			}
			if ((Index%widthInTiles > 0) && (Index-widthInTiles >= 0) && (_data[Index-widthInTiles-1] <= 0)) {
				_data[Index] = 2;		//TOP LEFT OPEN
			}
			if ((Index%widthInTiles < widthInTiles) && (Index-widthInTiles >= 0) && (_data[Index-widthInTiles+1] <= 0)) {
				_data[Index] = 4;		//TOP RIGHT OPEN
			}
			if ((Index%widthInTiles < widthInTiles) &&(Index+widthInTiles < totalTiles) && (_data[Index+widthInTiles+1] <= 0)) {
				_data[Index] = 8; 		//BOTTOM RIGHT OPEN
			}
		}
		_data[Index] += 1;
		*/
	}

	function updateTileGraphic(X:Int, Y:Int, Data:Int) {
		var tile:HxlTile = getTile(X,Y);
		if ( tile == null ) return;
		tile.dataNum = Data;
		if ( Data == 0 ) {
			tile.bitmapRect = null;
			return;
		}
		var rx:Int = (Data - startingIndex) * _tileWidth;
		var ry:Int = 0;
		if (rx >= _pixels.width) {
			ry = Std.int(rx/_pixels.width)*_tileHeight;
			rx %= _pixels.width;
		}
		tile.bitmapRect = new Rectangle(rx, ry, _tileWidth, _tileHeight);
	}

	/**
	 * Set <code>alpha</code> to a number between 0 and 1 to change the opacity of the tilemap.
	 */
	public function getAlpha():Float {
		return _alpha;
	}
	
	public function setAlpha(Alpha:Float):Float {
		if (Alpha > 1) Alpha = 1;
		if (Alpha < 0) Alpha = 0;
		if (Alpha == _alpha) return Alpha;
		_alpha = Alpha;
		if ((_alpha != 1) || (_color != 0x00ffffff)) _ct = new ColorTransform((_color>>16)/255.0,(_color>>8&0xff)/255.0,(_color&0xff)/255.0,_alpha);
		else _ct = null;
		return Alpha;
	}

}

enum Visibility {
	UNSEEN;
	SEEN;
	IN_SIGHT;
}

class HxlTile {
	public var visibility:Visibility;
	
	// override these
	public function isBlockingView():Bool {	return false; }
	public function isBlockingMovement():Bool {	return false;}	
	
	/**
	 * A Rectangle describing the location of this tiles graphic on the HxlTilemap bitmap.
	 **/
	public var bitmapRect:Rectangle;

	/**
	 * The coordinates of this tile within the HxlTilemap.
	 **/
	public var mapX:Int;
	public var mapY:Int;

	/**
	 * An Int representing the index of the graphic to use for this tile. If 0, tile has no graphic.
	 **/
	public var dataNum:Int;

	/**
	 * Blending modes, just like Photoshop!
	 * E.g. "multiply", "screen", etc.
	 * @default null
	 */
	public var blend:String;
	var _alpha:Float;
	var _color:Int;
	public var _ct:ColorTransform;
	var _mtx:Matrix;

	public var alpha(getAlpha, setAlpha) : Float;
	public var color(getColor, setColor) : Int;

	public function new(?X:Int = 0, ?Y:Int = 0, ?Rect:Rectangle = null) {
		visibility = UNSEEN;
		mapX = X;
		mapY = Y;
		bitmapRect = Rect;
		_alpha = 1;
		_color = 0x00ffffff;
		blend = null;
	}

	/**
	 * Set <code>alpha</code> to a number between 0 and 1 to change the opacity of this tile.
	 */
	public function getAlpha():Float {
		return _alpha;
	}
	
	public function setAlpha(Alpha:Float):Float {
		if (Alpha > 1) Alpha = 1;
		if (Alpha < 0) Alpha = 0;
		if (Alpha == _alpha) return Alpha;
		_alpha = Alpha;
		if ((_alpha != 1) || (_color != 0x00ffffff)) _ct = new ColorTransform((_color>>16)/255.0,(_color>>8&0xff)/255.0,(_color&0xff)/255.0,_alpha);
		else _ct = null;
		return Alpha;
	}

	/**
	 * Set <code>color</code> to a number in this format: 0xRRGGBB.
	 * <code>color</code> IGNORES ALPHA.  To change the opacity use <code>alpha</code>.
	 * Tints the whole sprite to be this color (similar to OpenGL vertex colors).
	 */
	public function getColor():Int {
		return _color;
	}

	public function setColor(Color:Int):Int {
		Color &= 0x00ffffff;
		if (_color == Color) return Color;
		_color = Color;
		if ((_alpha != 1) || (_color != 0x00ffffff)) _ct = new ColorTransform((_color>>16)/255.0,(_color>>8&0xff)/255.0,(_color&0xff)/255.0,_alpha);
		else _ct = null;
		return Color;
	}

}


