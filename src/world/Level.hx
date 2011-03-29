package world;

import flash.display.Bitmap;
import com.baseoneonline.haxe.astar.PathMap;

import haxel.HxlPoint;
import haxel.HxlTilemap;
import haxel.HxlState;
import haxel.HxlGraphics;
import haxel.HxlUtil;

import data.Registery;

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
	
	public function isBlockingMovement(X:Int, Y:Int, ?CheckActor:Bool=false):Bool { 
		if ( X < 0 || Y < 0 || X >= widthInTiles || Y >= heightInTiles ) 
			return true;
		if ( CheckActor && cast(_tiles[Y][X], Tile).actors.length>0 )
			return true;
		return _tiles[Y][X].isBlockingMovement();
	}
	
	public function isBlockingView(X:Int, Y:Int):Bool {
		if ( X < 0 || Y < 0 || X >= widthInTiles || Y >= heightInTiles ) 
			return true;
		return _tiles[Y][X].isBlockingView();
	}
	
	public override function onAdd(state:HxlState) {
		addAllActors(state);
		addAllLoots(state);
		
		follow();
		HxlGraphics.follow(Registery.player, 10);
	}
	
	function addAllActors(state:HxlState) {
		var player = Registery.player;
		player.tilePos = startingLocation;
		player.x = getPixelPositionOfTile(player.tilePos.x, player.tilePos.y).x;
		player.y = getPixelPositionOfTile(player.tilePos.x, player.tilePos.y).y;
		state.add(player);
		
		for (mob in mobs)
			state.add(mob);
	}
	
	function addAllLoots(state:HxlState) {
		
	}
	
	override public function loadMap(MapData:Array<Array<Int>>, TileGraphic:Class<Bitmap>, ?TileWidth:Int = 0, ?TileHeight:Int = 0, ?ScaleX:Float=1.0, ?ScaleY:Float=1.0):HxlTilemap {
		var map = super.loadMap(MapData, TileGraphic, TileWidth, TileHeight, ScaleX, ScaleY);
		
		_pathMap = new PathMap(widthInTiles, heightInTiles);
		
		for (y in 0...map.heightInTiles) {
			for (x in 0...map.widthInTiles) {
				cast(_tiles[y][x], Tile).level = this;
				_tiles[y][x].color = 0x000000;
				if ( isBlockingMovement(x, y) ) 
					_pathMap.setWalkable(x, y, false);
			}
		}
				
		return map;
	}
	
	
	/**
	 * Slightly less confusing name in this context
	 */
	public function getPixelPositionOfTile(X:Dynamic, Y:Dynamic, ?Center:Bool = false):HxlPoint {
		return super.getTilePos(X, Y, Center);
	}
	
	
	public function updateFieldOfView(?SkipTween:Bool = false) {
		var player = Registery.player;
		
		var bottom = Std.int(Math.min(heightInTiles - 1, player.tilePos.y + (player.visionRadius+1)));
		var top = Std.int(Math.max(0, player.tilePos.y - (player.visionRadius+1)));
		var right = Std.int(Math.min(widthInTiles - 1, player.tilePos.x + (player.visionRadius+1)));
		var left = Std.int(Math.max(0, player.tilePos.x - (player.visionRadius+1)));
		var tile:HxlTile;
		for ( x in left...right+1 ) {
			for ( y in top...bottom+1 ) {
				tile = getTile(x, y);
				if ( tile.visibility == Visibility.IN_SIGHT ) 
					tile.visibility = Visibility.SEEN;
			}
		}

		if ( isBlockingView(Std.int(player.tilePos.x), Std.int(player.tilePos.y)) ) {
			var adjacent = new Array();
			adjacent = [[ -1, -1], [0, -1], [1, -1], [ -1, 0], [1, 0], [ -1, 1], [0, 1], [1, 1]];
			for ( i in adjacent ) {
				var xx = Std.int(player.tilePos.x + i[0]);
				var yy = Std.int(player.tilePos.y + i[1]);
				if(yy<heightInTiles && xx<widthInTiles && yy>=0 && xx>=0)
					cast(getTile(xx, yy), Tile).visibility = Visibility.IN_SIGHT;
			}
		} else {		
			HxlUtil.markFieldOfView(player.tilePos, player.visionRadius, this);
		}

		for ( x in left...right+1 ) {
			for ( y in top...bottom+1 ) {
				tile = getTile(x, y);
				switch (tile.visibility) {
					case Visibility.IN_SIGHT:
						if ( SkipTween ) {
							tile.color = 0xffffff;
						} else {
							cast(tile,Tile).colorTo(255, player.moveSpeed);
						}
					case Visibility.SEEN:
						if ( SkipTween ) {
							tile.color = 0x888888;
						} else {
							cast(tile,Tile).colorTo(95, player.moveSpeed);
						}
					case Visibility.UNSEEN:
				}
			}
		}
	}
	
	public function getTargetAccordingToKeyPress():HxlPoint {
		var player = Registery.player;
		
		var targetTile:HxlPoint = null;
		if ( HxlGraphics.keys.LEFT ) {
			if ( player.tilePos.x > 0) {
				if ( !isBlockingMovement(Std.int(player.tilePos.x-1), Std.int(player.tilePos.y)) ) {
					targetTile = new HxlPoint( -1, 0);
				}
			}
		} else if ( HxlGraphics.keys.RIGHT ) {
			if ( player.tilePos.x < widthInTiles) {
				if ( !isBlockingMovement(Std.int(player.tilePos.x+1), Std.int(player.tilePos.y)) ) {
					targetTile = new HxlPoint(1, 0);
				}
			}
		} else if ( HxlGraphics.keys.UP ) {
			if ( player.tilePos.y > 0 ) {
				if ( !isBlockingMovement(Std.int(player.tilePos.x), Std.int(player.tilePos.y-1)) ) {
					targetTile = new HxlPoint(0, -1);
				}
			}
		} else if ( HxlGraphics.keys.DOWN ) {
			if ( player.tilePos.y < heightInTiles ) {
				if ( !isBlockingMovement(Std.int(player.tilePos.x), Std.int(player.tilePos.y+1)) ) {
					targetTile = new HxlPoint(0, 1);
				}
			}
		} 
		
		return targetTile;
	}
}
