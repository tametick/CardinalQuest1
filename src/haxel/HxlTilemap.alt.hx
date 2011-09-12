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
	//var _callbacks:Array<Dynamic>;
	var _screenRows:Int;
	var _screenCols:Int;
	public var tileGraphicName:String;

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

	
	private var tileBMPs:Array<BitmapData>;
	private var tilesByCT:Hash<BitmapData>;
	/**
	 * The tilemap constructor just initializes some basic variables.
	 */
	public function new(TileW:Int,tileH:Int) {
		super();
		auto = OFF;
		collideIndex = 1;
		startingIndex = 0;
		drawIndex = 1;
		widthInTiles = 0;
		heightInTiles = 0;
		totalTiles = 0;
		//_data = null;
		_tileWidth = TileW;
		_tileHeight = tileH;
		//_rects = null;
		_pixels = null;
		_block = new HxlObject();
		_block.width = _block.height = 0;
		//_block.fixed = true;
		//_callbacks = new Array();
		//fixed = true;

		_flashRect = new Rectangle();
		
		_alpha = 1;
		_color = 0x00ffffff;
		_mtx = new Matrix();
		blend = null;

		tileClass = HxlTile;
		if (tmpRect == null)
			tmpRect = new Rectangle(0, 0, _tileWidth, _tileHeight);
		
		if (tmpBitmap == null)
			tmpBitmap = new BitmapData(_tileWidth, _tileHeight, true, 0x00ffffff);
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
	
		tileGraphicName = Type.getClassName(TileGraphic);

		//Figure out the map dimensions based on the mapdata
		var c:Int;
		heightInTiles = MapData.length;
		widthInTiles = MapData[0].length;
		
		//Pre-process the map data if it's auto-tiled
		var i:Int;
		totalTiles = widthInTiles*heightInTiles;

		//Figure out the size of the tiles
		_pixels = GraphicCache.addBitmap(TileGraphic, false, false, null, ScaleX, ScaleY);
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
		//create splitted tile bmp array
		tileBMPs = new Array<BitmapData>();
		_flashPoint.x = 0; 
		_flashPoint.y = 0; 
		_flashRect.width = _tileWidth;
		_flashRect.height = _tileHeight;
		
		var ty:Int = 0;
		var tx:Int = 0;

		tilesByCT = new Hash<BitmapData>();
		while(ty/_tileHeight < _screenRows)
		{
			_flashRect.x = tx;
			_flashRect.y = ty;
			var tileBMP:BitmapData = new BitmapData(_tileWidth, _tileHeight);
			tileBMP.copyPixels(_pixels, _flashRect, _flashPoint);
			tileBMPs.push(tileBMP);
			tx+=_tileWidth;
			if (tx >= _pixels.width) {
				ty +=_tileHeight;
				tx = 0;
			}
		}
		_bbKey = Std.string(TileGraphic);
		
		return this;
	}

	public function getTiles():Array<Array<HxlTile>> {
		return _tiles;
	}

	override public function destroy() 	{
		super.destroy();
		
		if (tmpBitmap == null){
			// alreasdy destroyed
			return;
		}
		
		tmpBitmap.dispose();
		tmpBitmap = null;
		_pixels.dispose();
		_pixels = null;
		if(_bbPixels!=null) {
			_bbPixels.dispose();
			_bbPixels = null;
		}
		tmpRect = null;
		
		// Level still needs _tiles when being removed
		//_tiles = null;
	}
	
	/**
	 * Generates a bounding box version of the tiles, flixel should call this automatically when necessary.
	 */
	function generateBoundingTiles() {
		return;
	}

	/**
	 * Internal function that actually renders the tilemap.  Called by render().
	 */
	var tmpBitmap:BitmapData;
	var tmpRect:Rectangle;
	static var originPoint:Point = new Point(0, 0);
	function renderTilemap() {
		var tileBitmap:BitmapData = _pixels;

		getScreenXY(_point);
		_flashPoint.x = _point.x;
		_flashPoint.y = _point.y;
		var tx:Int = Math.floor(-_flashPoint.x/_tileWidth);
		var ty:Int = Math.floor(-_flashPoint.y/_tileHeight);
		if (tx < 0) tx = 0;
		if (tx > widthInTiles-_screenCols) tx = widthInTiles-_screenCols;
		if (ty < 0) ty = 0;
		if (ty > heightInTiles-_screenRows) ty = heightInTiles-_screenRows;
		_flashPoint.x += tx * _tileWidth;
		_flashPoint.y += ty * _tileHeight;
		var opx:Int = Std.int(_flashPoint.x);
		var c:Int;
		var tile:HxlTile;
		for (r in 0..._screenRows) {
			for (c in 0..._screenCols) {
				tile = _tiles[r+ty][c+tx];
				if ( tile.visible ) {
					#if flash9	
					if (!tilesByCT.exists( ((tile.dataNum-startingIndex) +"_" + tile._ct) ))
					{
						tmpBitmap = tileBMPs[(tile.dataNum-startingIndex)].clone();
						//test
						if (tile._ct != null)
							tmpBitmap.colorTransform( tmpRect,  tile._ct);
						tilesByCT.set(  ((tile.dataNum-startingIndex) +"_"+ tile._ct), tmpBitmap.clone());
					}
					HxlGraphics.buffer.copyPixels(tilesByCT.get(  ((tile.dataNum-startingIndex) +"_"+ tile._ct)), tmpRect, _flashPoint, null, null, false);
					#else
					// TODO: Get this working in CPP
					HxlGraphics.buffer.copyPixels(tileBitmap, tile.bitmapRect, _flashPoint, null, null, true);
					#end
					HxlGraphics.numRenders++;
				}
				_flashPoint.x += _tileWidth;
			}
			_flashPoint.x = opx;
			_flashPoint.y += _tileHeight;
		}

		tileBitmap = null;
	}

	/**
	 * Draws the tilemap.
	 */
	public override function render() {
		renderTilemap();
	}

	public function getTileBitmap(X:Int, Y:Int):BitmapData {
		var tileBitmap:BitmapData = _pixels;
		var tile:HxlTile = _tiles[Y][X];
		return (tilesByCT.get(  ((tile.dataNum-startingIndex) +"_" + tile._ct)));
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
	var pos:HxlPoint;
	public function getTilePos(X:Float, Y:Float, ?Center:Bool=false):HxlPoint {
		if (pos == null)
			pos = new HxlPoint();
			
		pos.x = this.x + (Math.floor(X) * _tileWidth);
		pos.y = this.y + (Math.floor(Y) * _tileHeight);
		if ( Center ) {
			pos.x += (_tileWidth / 2);
			pos.y += (_tileHeight / 2);
		}
		return pos.clone();
	}

	/**
	 * Call this function to lock the automatic camera to the map's edges.
	 * 
	 * @param	Border		Adjusts the camera follow boundary by whatever number of tiles you specify here.  Handy for blocking off deadends that are offscreen, etc.  Use a negative number to add padding instead of hiding the edges.
	 */
	public function follow(?Border:Int=0) {
		HxlGraphics.followBounds(Std.int(x+Border*_tileWidth),Std.int(y+Border*_tileHeight),Std.int(width-Border*_tileWidth),Std.int(height-Border*_tileHeight));
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
	function autoTile(Index:Int) {
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

	public function updateTileGraphic(X:Int, Y:Int, Data:Int) {
		var tile:HxlTile = getTile(X,Y);
		if ( tile == null ) 
			return;	
		tile.dataNum = Data;
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
	public var visible:Bool;
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
//	public var altBitmap:BitmapData;

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
		visible = true;
//		altBitmap = null;
	}

	/**
	 * Set <code>alpha</code> to a number between 0 and 1 to change the opacity of this tile.
	 */
	public function getAlpha():Float {
		return _alpha;
	}
	
	public function setAlpha(Alpha:Float):Float {
//		altBitmap = null;
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
//		altBitmap = null;
		Color &= 0x00ffffff;
		if (_color == Color) return Color;
		_color = Color;
		if ((_alpha != 1) || (_color != 0x00ffffff)) _ct = new ColorTransform((_color>>16)/255.0,(_color>>8&0xff)/255.0,(_color&0xff)/255.0,_alpha);
		else _ct = null;
		return Color;
	}

}

