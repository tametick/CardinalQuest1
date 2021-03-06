package haxel;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.ColorTransform;
import flash.Lib;

import data.Configuration;

import haxel.GraphicCache;

class HxlTilemapBMPData extends BitmapData {}
/**
 * This is a traditional tilemap display and collision class.
 * It takes a string of comma-separated numbers and then associates
 * those values with tiles from the sheet you pass in.
 * It also includes some handy static parsers that can convert
 * arrays or PNG files into strings that can be successfully loaded.
 */
class HxlTilemap extends HxlObject {
	/**
	 * What tile index will you start colliding with (default: 1).
	 */
	public var startingIndex:Int;
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
	
	var _pixels:GraphicCacheBMPData;
	var _tileWidth:Int;
	var _tileHeight:Int;
	var _screenRows:Int;
	var _screenCols:Int;
	public var tileGraphicName:String;

	var _tiles:Array<Array<HxlTile>>;

	var _alpha:Float;
	var _color:Int;
	
	private var mapFrame:HxlRect;

	public var tileClass:Class<HxlTile>;

	private var tileBMPs:Array<HxlTilemapBMPData>;
	private var decorations:GraphicCacheBMPData;
	
	private var cachedTilemapBuffer:BitmapData;

	/**
	 * The tilemap constructor just initializes some basic variables.
	 */
	public function new(TileW:Int,tileH:Int) {
		super();
		startingIndex = 0;
		widthInTiles = 0;
		heightInTiles = 0;
		totalTiles = 0;
		_tileWidth = TileW;
		_tileHeight = tileH;
		_pixels = null;

		_flashRect = new Rectangle();
		
		_alpha = 1;
		_color = 0x00ffffff;

		mapData = null;
		
		tileClass = HxlTile;
		if (tmpRect == null)
			tmpRect = new Rectangle(0, 0, _tileWidth, _tileHeight);

		cachedTilemapBuffer = null;
		
		_lastTxMin = -100;
		_lastTyMin = -100;
	}

	/**
	 * Load the tilemap with string data and a tile graphic.
	 * 
	 * @param	MapData			2d array of Ints, specifies index of sprite to use from TileGraphic.	
	 * @param	TileGraphic		All the tiles you want to use, arranged in a strip corresponding to the numbers in MapData.
	 * @param	Decorations 	An HxlSpriteSheet containing all the decorations tiles can optionally possess.
	 * @param	TileWidth		The width of your tiles (e.g. 8) - defaults to height of the tile graphic if unspecified.
	 * @param	TileHeight		The height of your tiles (e.g. 8) - defaults to width if unspecified.
	 * @param 	ScaleX 			Desired X scale of the rendered graphics.
	 * @param 	ScaleY 			Desired Y scale of the rendered graphics.
	 * 
	 * @return	A pointer this instance of HxlTilemap, for chaining as usual :)
	 */
	public function loadMap(MapFrame:HxlRect, MapData:Array<Array<Int>>, TileGraphic:Class<Bitmap>, Decorations:Class<Bitmap>, ?TileWidth:Int = 0, ?TileHeight:Int = 0, ?ScaleX:Float=1.0, ?ScaleY:Float=1.0):HxlTilemap {
		mapData = MapData;
		mapFrame = MapFrame;
	
		tileGraphicName = Type.getClassName(TileGraphic);

		decorations = GraphicCache.addBitmap(Decorations,false,false, null, ScaleX, ScaleY);
		
		//Figure out the map dimensions based on the mapdata
		var c:Int;
		heightInTiles = MapData.length;
		widthInTiles = MapData[0].length;

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
		
		//Pre-set some helper variables for later
		_screenRows = Math.ceil(mapFrame.height/_tileHeight) + 1;
		if (_screenRows > heightInTiles) {
			_screenRows = heightInTiles;
		}
		
		_screenCols = Math.ceil(mapFrame.width / _tileWidth) + 1;
		if (_screenCols > widthInTiles) {
			_screenCols = widthInTiles;
		}

		// Create buffer.
		cachedTilemapBuffer = new BitmapData( _tileWidth * _screenCols, _tileHeight * _screenRows, false, 0x000000 );

		//Pre-process the map data if it's auto-tiled
		var i:Int;
		totalTiles = widthInTiles*heightInTiles;
	
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
		
		//create splitted tile bmp array
		tileBMPs = new Array<HxlTilemapBMPData>();
		_flashPoint.x = 0; 
		_flashPoint.y = 0; 
		_flashRect.width = _tileWidth;
		_flashRect.height = _tileHeight;
		
		var ty:Int = 0;
		var tx:Int = 0;

		while(ty/_tileHeight < _screenRows)
		{
			_flashRect.x = tx;
			_flashRect.y = ty;
			var tileBMP:HxlTilemapBMPData = new HxlTilemapBMPData(_tileWidth, _tileHeight);
			tileBMP.copyPixels(_pixels, _flashRect, _flashPoint);
			tileBMPs.push(tileBMP);
			tx+=_tileWidth;
			if (tx >= _pixels.width) {
				ty +=_tileHeight;
				tx = 0;
			}
		}
		
		return this;
	}

	function resetBuffer() {
		if ( cachedTilemapBuffer != null ) {
			cachedTilemapBuffer.dispose();
			cachedTilemapBuffer = null;
		}
		
		cachedTilemapBuffer = new BitmapData( _tileWidth * widthInTiles, _tileHeight * heightInTiles, false, 0x000000 );
	}
	
	public function getTiles():Array<Array<HxlTile>> {
		return _tiles;
	}

	override public function destroy() 	{
		super.destroy();
		
		if ( cachedTilemapBuffer != null ) {
			cachedTilemapBuffer.dispose();
			cachedTilemapBuffer = null;
		}
		
	    for( i in 0...tileBMPs.length ) {
			tileBMPs[i].dispose();
			tileBMPs[i] = null;
		}
		tileBMPs = null;
		
		for ( y in 0...heightInTiles ) {
			for ( x in 0...widthInTiles ) {
				_tiles[y][x].destroy();
				_tiles[y][x] = null;
				
			}
		}
		_tiles = null;
		
		if(_pixels!=null) {
			_pixels.dispose();
			_pixels = null;		
		}
		
		tmpRect = null;
	}

	/**
	 * Internal function that actually renders the tilemap.  Called by render().
     */
	static var tmpRect:Rectangle;
	static var originPoint:Point = new Point(0, 0);

	var _lastTxMin:Int;
	var _lastTyMin:Int;
	
    public override function render() {
		getScreenXY(_point);
		
		_point.x -= mapFrame.left;
		_point.y -= mapFrame.top;
		
		_flashPoint.x = _point.x;
		_flashPoint.y = _point.y;
		var txMin:Int = Math.floor( -_point.x / _tileWidth);
		var txMax:Int = txMin + _screenCols;
		var tyMin:Int = Math.floor( -_point.y / _tileHeight);
		var tyMax:Int = tyMin + _screenRows;
		
		var xCrop:Int = 0;
		var yCrop:Int = 0;

		var realtxMin:Int = txMin;
		var realtyMin:Int = tyMin;
		
		if (txMin < 0) { xCrop += -txMin; txMin = 0; }
		if (txMax > widthInTiles) { xCrop += txMax - widthInTiles; txMax = widthInTiles; }
		if (tyMin < 0) { yCrop += -tyMin; tyMin = 0; }
		if (tyMax > heightInTiles) { yCrop += tyMax - heightInTiles; tyMax = heightInTiles; }
		
		_flashPoint.x = 0; // txMin * _tileWidtsh;
		_flashPoint.y = 0; // tyMin * _tileHeight;
		var opx:Int = Std.int(_flashPoint.x);
		
		var alldirty:Bool = (realtxMin != _lastTxMin) || (realtyMin != _lastTyMin);
		
		var tile:HxlTile;
		for (r in tyMin...tyMax) {
			for (c in txMin...txMax) {
				tile = _tiles[r][c];
				
				if ( alldirty || tile.visible && tile.dirty ) {
					tmpRect = tileBMPs[0].rect;
					cachedTilemapBuffer.copyPixels(tileBMPs[(tile.getDataNum()-startingIndex)], tmpRect, _flashPoint, null, null, false);
					
					for ( d in tile.decorationIndices ) {
						var dx:Int = Std.int( d % (decorations.width / _tileWidth) );
						var dy:Int = HxlUtil.floor( d / (decorations.width / _tileWidth) );
						
						tmpRect.left = dx * _tileWidth;
						tmpRect.right = tmpRect.left + _tileWidth;
						tmpRect.top = dy * _tileHeight;
						tmpRect.bottom = tmpRect.top + _tileHeight;
						cachedTilemapBuffer.copyPixels( decorations, tmpRect, _flashPoint, null, null, true );
					}
				
					tmpRect.left = _flashPoint.x;
					tmpRect.top = _flashPoint.y;
					tmpRect.right = _flashPoint.x + _tileWidth;
					tmpRect.bottom = _flashPoint.y + _tileHeight;
					
					if (tile._ct != null){
						cachedTilemapBuffer.colorTransform( tmpRect,  tile._ct);
					}

					tile.dirty = false;
				}
				_flashPoint.x += _tileWidth;
			}
			_flashPoint.x = opx;
			_flashPoint.y += _tileHeight;
		}
		
		tile = null;	
		
		_flashPoint.x = _point.x + txMin * _tileWidth + mapFrame.left;
		_flashPoint.y = _point.y + tyMin * _tileHeight + mapFrame.top;

		tmpRect.left = 0;
		tmpRect.right = (_screenCols - xCrop) * _tileWidth;
		tmpRect.top = 0;
		tmpRect.bottom = (_screenRows - yCrop) * _tileHeight;
		
		HxlGraphics.buffer.copyPixels(cachedTilemapBuffer, tmpRect, _flashPoint, null, null, false);
		HxlGraphics.numRenders++;
		
		_lastTyMin = realtyMin;
		_lastTxMin = realtxMin;
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
		if ( Y >= _tiles.length || Y < 0 || X >= _tiles[0].length || X < 0 ) 
			return null;
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
	static var pos:HxlPoint;
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
	public function follow(?Border:Int = 0) {
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
	public static function arrayToCSV(Data:Array<Int>,Width:Int):String {
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
	
	public function updateTileGraphic(X:Int, Y:Int, Data:Int) {
		var tile:HxlTile = getTile(X,Y);
		if ( tile == null ) 
			return;	
		tile.setDataNum( Data );
	}
}

enum Visibility {
	UNSEEN;
	SEEN;
	IN_SIGHT;
	SENSED;
}

class HxlTile {
	public var visible:Bool;
	public var visibility:Visibility;

	// override these
	
	public var blocksMovement(default, null):Bool;
	public var blocksView(default, null):Bool;
	public var isStairs(default, null):Bool;
	public var isDoor(default, null):Bool;
	
	/**
	 * The coordinates of this tile within the HxlTilemap.
	 **/
	public var mapX:Int;
	public var mapY:Int;

	/**
	 * An Int representing the index of the graphic to use for this tile. If 0, tile has no graphic.
	 **/
	var dataNum:Int;
	public var decorationIndices:Array<Int>;

	var _alpha:Float;
	var _color:Int;
	public var _ct:ColorTransform;
	public var dirty:Bool;

	public var alpha(getAlpha, setAlpha) : Float;
	public var color(getColor, setColor) : Int;

	public function new(?X:Int = 0, ?Y:Int = 0, ?Rect:Rectangle = null) {
		visibility = UNSEEN;
		mapX = X;
		mapY = Y;
		_alpha = 1;
		_color = 0x00ffffff;
		visible = true;
		dirty = true;
		
		decorationIndices = new Array<Int>();
		
		blocksMovement = false;
		blocksView = false;
		isStairs = false;
		isDoor = false;
	}

	public function destroy() {
		_ct = null;
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
		if ((_alpha != 1) || (_color != 0x00ffffff)) 
			_ct = new ColorTransform((_color>>16)/255.0,(_color>>8&0xff)/255.0,(_color&0xff)/255.0,_alpha);
		else 
			_ct = null;
		
		dirty = true;
		
		return Alpha;
	}

	public function getDataNum():Int {
		return dataNum;
	}
	
	public function setDataNum(DataNum:Int):Int {
		if (DataNum == dataNum) return DataNum;
		dataNum = DataNum;
		dirty = true;
		return DataNum;
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
		if ((_alpha != 1) || (_color != 0x00ffffff)) 
			_ct = new ColorTransform((_color>>16)/255.0,(_color>>8&0xff)/255.0,(_color&0xff)/255.0,_alpha);
		else 
			_ct = null;
			
		dirty = true;
			
		return Color;
	}

}


