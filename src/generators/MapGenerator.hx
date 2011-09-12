package generators;

import haxel.HxlPoint;
import haxel.HxlUtil;

class MapGenerator 
{

	public function new() 
	{
		
	}
	
	function addPerlinTiles(width:Int, height:Int, baseMap:Array<Array<Int>>, tilesIndexes:Array<Int>, tilesWeights:Array<Int>, canHaveTile:Array<Int>, ?jaggedness:Int = 8) {
		var treeMap = Perlin.getNoiseMap(width, height, tilesIndexes, tilesWeights,jaggedness);
		for (y in 0...height)
			for (x in 0...width)
				if ( HxlUtil.contains(canHaveTile, baseMap[y][x]) && treeMap[y][x] != -1)
					baseMap[y][x] = treeMap[y][x];
	}
	
	
	inline function sumOfDifferentTiles(width:Int, height:Int, x:Int, y:Int, map:Array<Array<Int>>):Int {
		var sum = 0;
		
		if (x - 1 >= 0 && map[y][x - 1] != map[y][x])
			sum++;
		if (x + 1 < width && map[y][x + 1] != map[y][x])
			sum++;
		if (y - 1 >= 0 && map[y-1][x] != map[y][x])
			sum++;
		if (y + 1 < height && map[y+1][x] != map[y][x])
			sum++;			
			
		return sum;
	}
	
	function isSecluded(width:Int, height:Int, x:Int, y:Int, map:Array<Array<Int>>):Bool {
		return sumOfDifferentTiles(width, height, x, y, map) > 2;
	}
	
	function isRiver(width:Int, height:Int, x:Int, y:Int, map:Array<Array<Int>>):Bool {
		if ( sumOfDifferentTiles(width, height, x, y, map) != 2)
			return false;
		
		if ( (x - 1 >= 0 && map[y][x - 1] != map[y][x])  &&  (x + 1 < width && map[y][x + 1] != map[y][x]) )
			return true;
			
		if ( (y - 1 >= 0 && map[y-1][x] != map[y][x])  &&  (y + 1 < height && map[y+1][x] != map[y][x]) )
			return true;			
		
		return false;
	}

	function countTilesInArea(x0:Int, y0:Int, x1:Int, y1:Int, map:Array<Array<Int>>, tileToCount:Int):Int {
		return (map[y0][x0]==tileToCount?1:0)+(map[y0][x1]==tileToCount?1:0)+(map[y1][x0]==tileToCount?1:0)+(map[y1][x1]==tileToCount?1:0);
	}
	
	function removeSharpCorner(x0:Int, y0:Int, x1:Int, y1:Int, map:Array<Array<Int>>, tileThatFormSharpCorners:Int, tileToAddToCorner:Array<Int>) {
		if (map[y0][x0] != tileThatFormSharpCorners)
			map[y0][x0] = tileToAddToCorner[3];
		else if (map[y0][x1] != tileThatFormSharpCorners)
			map[y0][x1] = tileToAddToCorner[2];
		else if (map[y1][x0] != tileThatFormSharpCorners)
			map[y1][x0] = tileToAddToCorner[1];
		else if (map[y1][x1] != tileThatFormSharpCorners)
			map[y1][x1] = tileToAddToCorner[0];
	}
	
	function removeSharpCorners(width:Int, height:Int, map:Array<Array<Int>>, tileThatFormSharpCorners:Int, tileToAddToCorner:Array<Int>) {
		for (y in 1...height-1)
			for (x in 1...width-1) {
				var numOfTiles = countTilesInArea(x, y, x + 1, y + 1, map, tileThatFormSharpCorners);
				if (numOfTiles == 3)
					removeSharpCorner(x, y, x + 1, y + 1, map, tileThatFormSharpCorners, tileToAddToCorner);
			}
	}
	
	function removeSecludedTiles(width:Int, height:Int, map:Array<Array<Int>>, tileToRemove:Int, tileToAdd:Int) {
		var removedTiles = false;
		
		for (y in 0...height)
			for (x in 0...width)
				if (map[y][x] == tileToRemove && (isSecluded(width,height,x,y,map) || isRiver(width,height,x,y,map))) {
					map[y][x] = tileToAdd;
					removedTiles = true;
				}
		
		if (removedTiles)
			removeSecludedTiles(width, height, map, tileToRemove, tileToAdd);
	}

	/* Secluded tiles must be removed before calling this function! */
	function autoTile(width:Int, height:Int, x:Int, y:Int, srcMap:Array<Array<Int>>, newMap:Array<Array<Int>>, tileToAuto:Int, N:Int, NE:Int, E:Int, SE:Int, S:Int, SW:Int, W:Int, NW:Int) {				
		// W
		if (x - 1 >= 0 && srcMap[y][x - 1] != srcMap[y][x]) {
			// NW
			if (y - 1 >= 0 && srcMap[y - 1][x] != srcMap[y][x])
				newMap[y][x] = NW;
			// SW
			else if (y + 1 < height && srcMap[y + 1][x] != srcMap[y][x]) 
				newMap[y][x] = SW;
			// W
			else
				newMap[y][x] = W;
		}
		// E
		else if (x + 1 < width && srcMap[y][x + 1] != srcMap[y][x]){
			// NE
			if (y - 1 >= 0 && srcMap[y - 1][x] != srcMap[y][x])
				newMap[y][x] = NE;
			// SE
			else if (y + 1 < height && srcMap[y + 1][x] != srcMap[y][x]) 
				newMap[y][x] = SE;
			// E
			else
				newMap[y][x] = E;
		}
		// N
		else if (y - 1 >= 0 && srcMap[y - 1][x] != srcMap[y][x]) {
			newMap[y][x] = N;
		}
		// S
		else if (y + 1 < height && srcMap[y + 1][x] != srcMap[y][x]) {
			newMap[y][x] = S;
		}
	}
	
	function autoAllTiles(width:Int, height:Int, map:Array<Array<Int>>, tileToAuto:Int, N:Int, NE:Int, E:Int, SE:Int, S:Int, SW:Int, W:Int, NW:Int) {
		var newMap = new Array<Array<Int>>();
		copyMap(width,height,map,newMap);
		
		for (y in 0...height)
			for (x in 0...width)
				if (map[y][x] == tileToAuto)
					autoTile(width, height, x, y, map, newMap, tileToAuto, N, NE, E, SE, S, SW, W, NW);
					
		copyMap(width,height,newMap,map);
	}
	
	function copyMap(width:Int, height:Int,srcMap:Array<Array<Int>>, newMap:Array<Array<Int>>) 
	{
		for (y in 0...height) {
			newMap[y] = new Array<Int>();
			for (x in 0...width)
				newMap[y][x] = srcMap[y][x];
		}
	}
	
	static function pointToNum(width:Int, height:Int, p:HxlPoint):Int {
		return Std.int((p.y*width)+p.x);
	}
	
	static function numToPoint(width:Int, height:Int, num:Int):HxlPoint {
		return new HxlPoint(num % width, Math.floor(num / width));
	}
	
	static function isOpen(width:Int, height:Int, map:Array<Array<Int>>, openTiles:Array<Int>, x:Int, y:Int) {
		if ( x < 1 || x > width-2 || y < 1 || y > height-2 ) return false;
		if ( HxlUtil.contains(openTiles, map[y][x]) ) return true;
		return false;
	}
	
	static function isOpenArea(mapWidth:Int, mapHeight:Int, map:Array<Array<Int>>, openTiles:Array<Int>, x0:Int, y0:Int,x1:Int,y1:Int) {
		if ( x0 < 1 || x1 > mapWidth-2 || y0 < 1 || y1 > mapHeight-2 ) return false;
		for(yy in y0...y1)
			for (xx in x0...x1)
				if (!HxlUtil.contains(openTiles, map[yy][xx]))
					return false;
		return true;
	}
	
	static function getValidStairsUpLocation(mapWidth:Int, mapHeight:Int, map:Array<Array<Int>>, wallTile, openTiles:Array<Int>):HxlPoint {
		for (y in 1...mapHeight-2)
			for (x in 1...mapWidth - 2) {
				if (map[y][x - 1] == wallTile && map[y][x] == wallTile && map[y][x + 1] == wallTile && HxlUtil.contains(openTiles, map[y + 1][x]) )
					return new HxlPoint(x, y);
			}
		return null;
	}
	
	static function getValidStairsDownLocation(mapWidth:Int, mapHeight:Int, map:Array<Array<Int>>, wallTile, openTiles:Array<Int>):HxlPoint {
		for (iy in 2...mapHeight-1)
			for (ix in 2...mapWidth-1) {
				var y = mapHeight - iy;
				var x = mapWidth - ix;
				
				if (map[y][x - 1] == wallTile && map[y][x] == wallTile && map[y][x + 1] == wallTile && HxlUtil.contains(openTiles, map[y - 1][x]) )
					return new HxlPoint(x, y);
			}
		return null;
	}
	
	public static function isFullyConnected(width:Int, height:Int, map:Array<Array<Int>>, tilesToCount:Array<Int>, ?mapToMarkedDisconnectedAreas:Array<Array<Int>>=null, ?disconnectedMarker:Int=-1):Bool {
		if (mapToMarkedDisconnectedAreas != null) {
			// mark walkable areas with disconnectedMarker
			for (y in 0...height)
				for (x in 0...width) {
					if (HxlUtil.contains(tilesToCount, map[y][x]))
						mapToMarkedDisconnectedAreas[y][x] = disconnectedMarker;
				}
		}
		
		var openCount = HxlUtil.countTiles(width, height, map, tilesToCount);
		var openList = new Array();
		var closedList = new Array();
		var pass = false;
		
		// pick a random, valid starting location
		var start = HxlUtil.getRandomTile(width, height, map, tilesToCount);
		
		// add starting location to open list
		openList.push(pointToNum(width, height, start));
		if (mapToMarkedDisconnectedAreas != null) 
			mapToMarkedDisconnectedAreas[Std.int(start.y)][Std.int(start.x)] = map[Std.int(start.y)][Std.int(start.x)];
		
		// while length of open list is more than 0, continue popping and processing tiles
		while ( openList.length > 0 ) {
			var curNum = openList.pop();
			var curPos = numToPoint(width,height, curNum);
			var checkNum = 0;
			
			// check north, west, south, and east tiles
			var N = new HxlPoint(curPos.x, curPos.y - 1);
			var E = new HxlPoint(curPos.x+1, curPos.y);
			var S = new HxlPoint(curPos.x, curPos.y + 1);
			var W = new HxlPoint(curPos.x-1, curPos.y);
			
			// if that tile is open and not in either the open or closed list, add it to the open list
			if ( isOpen(width,height,map,tilesToCount, Std.int(curPos.x), Std.int(curPos.y-1)) ) {
				checkNum = pointToNum(width, height, N);
				if ( !HxlUtil.contains(openList, checkNum) && !HxlUtil.contains(closedList, checkNum) ) {
					openList.push(checkNum);
					if (mapToMarkedDisconnectedAreas != null) 
						mapToMarkedDisconnectedAreas[Std.int(N.y)][Std.int(N.x)] = map[Std.int(N.y)][Std.int(N.x)];
				}
			}
			if ( isOpen(width,height,map,tilesToCount, Std.int(curPos.x+1), Std.int(curPos.y)) ) {
				checkNum = pointToNum(width, height, E);
				if ( !HxlUtil.contains(openList, checkNum) && !HxlUtil.contains(closedList, checkNum) ) {
					openList.push(checkNum);
					if (mapToMarkedDisconnectedAreas != null) 
						mapToMarkedDisconnectedAreas[Std.int(E.y)][Std.int(E.x)] = map[Std.int(E.y)][Std.int(E.x)];
				}
			}
			if ( isOpen(width,height,map,tilesToCount, Std.int(curPos.x), Std.int(curPos.y+1)) ) {
				checkNum = pointToNum(width, height, S);
				if ( !HxlUtil.contains(openList, checkNum) && !HxlUtil.contains(closedList, checkNum) ) {
					openList.push(checkNum);
					if (mapToMarkedDisconnectedAreas != null) 
						mapToMarkedDisconnectedAreas[Std.int(S.y)][Std.int(S.x)] = map[Std.int(S.y)][Std.int(S.x)];
				}
			}
			if ( isOpen(width,height,map,tilesToCount, Std.int(curPos.x-1), Std.int(curPos.y)) ) {
				checkNum = pointToNum(width, height, W);
				if ( !HxlUtil.contains(openList, checkNum) && !HxlUtil.contains(closedList, checkNum) ) {
					openList.push(checkNum);
					if (mapToMarkedDisconnectedAreas != null) 
						mapToMarkedDisconnectedAreas[Std.int(W.y)][Std.int(W.x)] = map[Std.int(W.y)][Std.int(W.x)];
				}
			}
			closedList.push(curNum);
		}
		
		// Map had inaccessible areas
		if ( closedList.length < openCount )
			return false;
		
		return true;
		
	}
}