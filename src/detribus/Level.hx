package detribus;

import flash.display.Bitmap;
import haxel.HxlTilemap;
import haxel.HxlUtil;
import haxel.HxlPoint;
import com.baseoneonline.haxe.astar.PathMap;
import com.baseoneonline.haxe.astar.AStar;
import com.baseoneonline.haxe.astar.AStarNode;
import com.baseoneonline.haxe.geom.IntPoint;

import detribus.Loot;

class Level extends HxlTilemap
{
	public var startingLocation:HxlPoint;
	var pathMap:PathMap;
	
	var world:World;
	
	public var mobs:Array<Mob>;
	public var loots:Array<Loot>;
	
	public function new(world:World) 
	{
		super();
		this.world = world;
		mobs = new Array();
		loots = new Array();
		pathMap = null;
		startingIndex = 1;
		tileClass = Tile;
	}
	
	public function createMobs(mobClass:String, numberOfMobs:Int) {
		var mobType:Class<Dynamic> = Type.resolveClass(mobClass);
		for (m in 0...numberOfMobs) {
			var mob:Mob = Type.createInstance(mobType, [world]);
					
			var walkableTilesWithoutStairs = getWalkableTilesWithoutStairs();
			var mobPos:HxlPoint;
			do{
				mobPos = HxlUtil.getRandomTile(widthInTiles, heightInTiles, mapData, walkableTilesWithoutStairs);
			} while (getTile(mobPos.x, mobPos.y).actor != null);
				
			mob.tilePos = mobPos;
			
			mob.x = getTilePos(mobPos.x, mobPos.y).x + 4;
			mob.y = getTilePos(mobPos.x, mobPos.y).y + 4;
			
			mobs.push(mob);
		}
	}
	
	private function getWalkableTilesWithoutStairs():Array<Int> 
	{
		var walkableTilesWithoutStairs = Resources.walkableTiles.copy();
		walkableTilesWithoutStairs.remove(54);
		walkableTilesWithoutStairs.remove(51);
		return walkableTilesWithoutStairs;
	}

	public function createGizmo() {
		var pos = getPositionFreeOfLootAndActors();
		
		var loot:Loot = Loot.getNewGizmo(world, pos.x, pos.y);
		
		loot.x = getTilePos(pos.x, pos.y).x + 4;
		loot.y = getTilePos(pos.x, pos.y).y + 4;
		
		loots.push(loot);
	}
	
	public function createRandomPowerUp() {
		var puPos = getPositionFreeOfLootAndActors();
		
		var loot:Loot = null;
		switch(HxlUtil.randomInt(4)) {
			case 0:
				loot = Loot.getNewPowerUp(world, puPos.x, puPos.y, DAMAGE);
			case 1:
				loot = Loot.getNewPowerUp(world, puPos.x, puPos.y, HP);
			case 2:
				loot = Loot.getNewPowerUp(world, puPos.x, puPos.y, DODGE);
			case 3:
				loot = Loot.getNewPowerUp(world, puPos.x, puPos.y, ARMOR);
		}
		
		loot.x = getTilePos(puPos.x, puPos.y).x + 4;
		loot.y = getTilePos(puPos.x, puPos.y).y + 4;
		
		loots.push(loot);
	}
	
	private function getPositionFreeOfLootAndActors():HxlPoint {
		var walkableTilesWithoutStairs = getWalkableTilesWithoutStairs();
		var pos:HxlPoint;
		do{
			pos = HxlUtil.getRandomTile(widthInTiles, heightInTiles, mapData, walkableTilesWithoutStairs);
		} while (getTile(pos.x, pos.y).actor != null && getTile(pos.x, pos.y).loot != null);
		
		return pos;
	}
	
	
	public function isBlockingMovement(X:Int, Y:Int, ?CheckActor:Bool=false):Bool { 
		if ( X < 0 || Y < 0 || X >= widthInTiles || Y >= heightInTiles ) return true;
		if ( CheckActor && cast(_tiles[Y][X], Tile).actor != null ) return true;
		return _tiles[Y][X].isBlockingMovement();
	}
	
	public function isBlockingView(X:Int, Y:Int):Bool {
		if ( X < 0 || Y < 0 || X >= widthInTiles || Y >= heightInTiles ) return true;
		return _tiles[Y][X].isBlockingView();
	}
	
	override public function loadMap(MapData:Array<Array<Int>>, TileGraphic:Class<Bitmap>, ?TileWidth:Int = 0, ?TileHeight:Int = 0, ?RowWidth:Int):HxlTilemap 
	{
		var map = super.loadMap(MapData, TileGraphic, TileWidth, TileHeight, RowWidth);
		
		pathMap = new PathMap(widthInTiles, heightInTiles);
		
		for (y in 0...map.heightInTiles) {
			for (x in 0...map.widthInTiles) {
				cast(_tiles[y][x], Tile).level = this;
				_tiles[y][x].color = 0x000000;
				//_tiles[y][x].color = 0xff0000;
				if ( isBlockingMovement(x, y) ) 
					pathMap.setWalkable(x, y, false);
			}
		}
				
		return map;
	}
	
	public function getPath(From:HxlPoint, To:HxlPoint, allowCardinal:Bool = true, allowDiagonal:Bool = true):Array<HxlPoint> {
		// The following is used on the blank map for AI debugging
		/*
		for ( Y in 0...heightInTiles ) 
			for ( X in 0...widthInTiles )
				updateTileGraphic(X, Y, 64);
		*/
		var start:IntPoint = new IntPoint(Math.floor(From.x), Math.floor(From.y));
		var end:IntPoint = new IntPoint(Math.floor(To.x), Math.floor(To.y));
		var a:AStar = new AStar(pathMap, start, end);
		var solution:Array<IntPoint> = a.solve(allowCardinal, allowDiagonal);
		if ( solution == null ) return null;
		
		/*
		for ( pPoint in a.visited ) {
			updateTileGraphic(pPoint.x, pPoint.y, 7);
		}
		*/
		
		// Lets convert those IntPoints into HxlPoints
		var path:Array<HxlPoint> = new Array();
		for (point in solution) {
			path.push( new HxlPoint(point.x, point.y) );
		}
		path.reverse();
		return path;
	}
	
	public function killMob(mob:Mob) {
		getTile(mob.tilePos.x, mob.tilePos.y).actor = null;
		mobs.remove(mob);
	}
}
