import com.baseoneonline.haxe.astar.AStar;
import com.baseoneonline.haxe.astar.PathMap;
import com.baseoneonline.haxe.geom.IntPoint;
import flash.display.BitmapData;
import generators.CellularAutomata;
import generators.MapGenerator;

import haxel.HxlUtil;
import haxel.HxlPoint;

import generators.Perlin;

class LevelGenerator extends MapGenerator
{	
	function generateCaveMap(width:Int, height:Int):Array<Array<Int>> {
		var ca  = new CellularAutomata(width, height,64,30);		
		var map = ca.getCaveMap();
		
		// remove walls tiles sided by too much floor
		removeSecludedTiles(width, height, map, 30, 64);
		
		// water/rocks/debris
		addPerlinTiles(width, height, map, [ -1, 18, 37, 38, 59], [15, 3, 2, 2, 1], [64]);
		
		// remove water tiles sided by too much land
		removeSecludedTiles(width, height, map, 18, 7);
		
		return map;
	}
	
	function generateWildernessMap(width:Int, height:Int):Array<Array<Int>> {
		var map = Perlin.getNoiseMap(width, height, [18, 7, 64], [4, 3, 6]);
		// trees
		addPerlinTiles(width, height, map, [ -1, 8, 29, 22], [5, 1, 1, 1], [7, 64]);
		// rocks/debris
		addPerlinTiles(width, height, map, [ -1, 37, 38, 59], [10, 2, 2,1], [7, 64]);
		// remove water tiles sided by too much land
		removeSecludedTiles(width, height, map, 18, 7);
		
		return map;
	}
	
	function addCaveEntry(mapWidth:Int, mapHeight:Int, map:Array<Array<Int>>, location:HxlPoint) {
		// add cave to current location
		map[Std.int(location.y+1)][Std.int(location.x-3)] = 40;
		map[Std.int(location.y+1)][Std.int(location.x-2)] = 30;
		map[Std.int(location.y+1)][Std.int(location.x-1)] = 31;
		map[Std.int(location.y+1)][Std.int(location.x+1)] = 32;
		map[Std.int(location.y+1)][Std.int(location.x+2)] = 39;
		
		map[Std.int(location.y)][Std.int(location.x-2)] = 30;
		map[Std.int(location.y)][Std.int(location.x - 1)] = 30;
		map[Std.int(location.y)][Std.int(location.x)] = 51;
		map[Std.int(location.y)][Std.int(location.x+1)] = 30;
		
		map[Std.int(location.y-1)][Std.int(location.x-2)] = 40;
		map[Std.int(location.y-1)][Std.int(location.x-1)] = 30;
		map[Std.int(location.y-1)][Std.int(location.x)] = 30;
		map[Std.int(location.y-1)][Std.int(location.x+1)] = 39;
		
		map[Std.int(location.y-2)][Std.int(location.x-1)] = 40;
		map[Std.int(location.y-2)][Std.int(location.x)] = 39;
	}
	
	function addStairs(mapWidth:Int, mapHeight:Int, map:Array<Array<Int>>, location:HxlPoint, stairTile:Int) {
		map[Std.int(location.y)][Std.int(location.x)] = stairTile;
	}
	
	public function addReachableFeature(mapWidth:Int, mapHeight:Int, map:Array<Array<Int>>, reachableFrom:HxlPoint, featureToAdd:MapFeatures):HxlPoint {
		var newMap = HxlUtil.cloneMap(map);
		
		var isValidLocation:Bool = false;
		var location:HxlPoint = null;

		var walkableTilesWithoutStairs = Resources.walkableTiles.copy();
		walkableTilesWithoutStairs.remove(54);
		walkableTilesWithoutStairs.remove(51);

		switch (featureToAdd) {
			case CAVE_ENTRY:
				while (!isValidLocation) {
					location = HxlUtil.getRandomTile(mapWidth, mapHeight, newMap, Resources.walkableTiles);
					isValidLocation = MapGenerator.isOpenArea(mapWidth, mapHeight, newMap, Resources.walkableTiles.concat(Resources.debrisTiles),
						Std.int(location.x - 3), Std.int(location.y - 2), Std.int(location.x + 2), Std.int(location.y + 1));
				}
				addCaveEntry(mapWidth, mapHeight, newMap, location);
			case CAVE_STAIRS_DOWN:
				
				location = MapGenerator.getValidStairsDownLocation(mapWidth, mapHeight, newMap, 30, walkableTilesWithoutStairs);
				addStairs(mapWidth, mapHeight, newMap, location, 51);
				HxlUtil.copyMap(newMap, map);
				return location;
			case CAVE_STAIRS_UP:
				location = MapGenerator.getValidStairsUpLocation(mapWidth, mapHeight, newMap, 30, walkableTilesWithoutStairs);
				addStairs(mapWidth, mapHeight, newMap, location, 54);
				HxlUtil.copyMap(newMap, map);
				return location;
		}
		
		// check that it is reachable by the player
		var pathMap = new PathMap(mapWidth, mapHeight);
		for (y in 0...mapHeight)
			for (x in 0...mapWidth) {
				if ( !HxlUtil.contains(Resources.walkableTiles, newMap[y][x]) ) 
					pathMap.setWalkable(x, y, false);
			}
		var start:IntPoint = new IntPoint(Math.floor(reachableFrom.x), Math.floor(reachableFrom.y));
		var end:IntPoint = new IntPoint(Math.floor(location.x), Math.floor(location.y+1));
		var a:AStar = new AStar(pathMap, start, end);
		var solution:Array<IntPoint> = a.solve(true, false);

		if ( solution == null ) {
			// try again
			addReachableFeature(mapWidth, mapHeight, map, reachableFrom, featureToAdd);
		}
		else {
			// copy to source map
			HxlUtil.copyMap(newMap,map);
		}
		
		return reachableFrom;
	}
	
	public function getCaveMap(width:Int, height:Int):Array<Array<Int>> {
		var map:Array<Array<Int>>;
		var validMap:Bool;
		do {
			map = generateCaveMap(width, height);
			validMap = MapGenerator.isFullyConnected(width, height, map, Resources.walkableTiles);
		} while (!validMap);
		
		// make water pretty
		autoAllTiles(width, height, map, 18, 10, 11, 19, 27, 26, 25, 17, 9);
		
		// make stone pretty
		autoAllTiles(width, height, map, 30, 30, 39, 30, 31, 30, 32, 30, 40);
		
		// remove sharp corners 
		removeSharpCorners(width, height, map, 30, [31, 32, 39, 40]);
		
		return map;
	}
	
	public function getWildernessMap(width:Int, height:Int):Array<Array<Int>> {
		var map:Array<Array<Int>>;
		var validMap:Bool;
		do{
			map = generateWildernessMap(width, height);
			validMap = MapGenerator.isFullyConnected(width, height, map, Resources.walkableTiles);
		} while (!validMap);
		
		// make water pretty
		autoAllTiles(width, height, map, 18, 10, 11, 19, 27, 26, 25, 17, 9);
		
		return map;
	}
}

enum MapFeatures {
	CAVE_ENTRY;
	CAVE_STAIRS_UP;
	CAVE_STAIRS_DOWN;
}