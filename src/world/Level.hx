package world;

import flash.display.Bitmap;
import com.baseoneonline.haxe.astar.PathMap;
import haxel.HxlPoint;
import haxel.HxlTilemap;

class Level extends HxlTilemap
{
	public var mobs:Array<Mob>;
	public var loots:Array<Loot>;
	public var startingLocation:HxlPoint;
	var _pathMap:PathMap;
	
	public function new() 
	{
		super();
		
		mobs = new Array();
		loots = new Array();
		_pathMap = null;
		startingIndex = 1;
	}
	
	public function isBlockingMovement(X:Int, Y:Int, ?CheckActor:Bool = false):Bool { 
		return false;
	}
	
	override public function loadMap(MapData:Array<Array<Int>>, TileGraphic:Class<Bitmap>, ?TileWidth:Int = 0, ?TileHeight:Int = 0, ?ScaleX:Float=1.0, ?ScaleY:Float=1.0):HxlTilemap {
		var map = super.loadMap(MapData, TileGraphic, TileWidth, TileHeight, ScaleX, ScaleY);
		
		_pathMap = new PathMap(widthInTiles, heightInTiles);
		
		for (y in 0...map.heightInTiles) {
			for (x in 0...map.widthInTiles) {
				cast(_tiles[y][x], Tile).level = this;
//				_tiles[y][x].color = 0x000000;
				if ( isBlockingMovement(x, y) ) 
					_pathMap.setWalkable(x, y, false);
			}
		}
				
		return map;
	}
}
