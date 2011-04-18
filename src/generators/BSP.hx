package generators;
import haxel.HxlUtil;

private class Point {
	public var x:Int;
	public var y:Int;
	public function new(x:Int, y:Int) {
		this.x = x;
		this.y = y;
	}
	
	public function toString() {
		return "<" + x + "," + y + ">";
	}
}

private class Room {
	public var x0:Int;
	public var x1:Int; 
	public var y0:Int;
	public var y1:Int;
	public function new(x0:Int, y0:Int, x1:Int, y1:Int) {
		this.x0 = x0;
		this.x1 = x1;
		this.y0 = y0;
		this.y1 = y1;
	}
	
	public function getWidth():Int {
		return x1 - x0;
	}
	
	public function getHeight():Int {
		return y1 - y0;
	}
	
	public function getCenter():Point {
		return new Point(Math.round(x0 + getWidth() / 2), Math.round(y0 + getHeight() / 2));
	}
}

private class Corridor {
	public var r0:Room;
	public var r1:Room;
	
	public function new(r0:Room, r1:Room) {
		this.r0 = r0;
		this.r1 = r1;
	}
}

class BSP 
{
	public static var minRoomWidth = 3;
	public static var minRoomHeight = 3;
	// needs to be >=2*min
	public static var maxRoomWidth = 9;
	public static var maxRoomHeight = 9;
	
	static function createRandomRoomInRect(x0:Int, y0:Int, x1:Int, y1:Int):Room {
		var maxWidth = x1 - x0;
		var maxHeight = y1 - y0;
		
		var width = HxlUtil.randomIntInRange(Math.floor(maxWidth/3), maxWidth);
		var height = HxlUtil.randomIntInRange(Math.floor(maxWidth / 3), maxHeight);
		
		if (width < minRoomWidth)
			width = minRoomWidth;
		
		if (height < minRoomHeight)
			height = minRoomHeight;
				
		return new Room(x0, y0, x0+width, y0+height);
	}
	
	static function drawRoom(map:Array<Array<Int>>, room:Room, wallIndex:Int, floorIndex:Int) {
		for (y in room.y0...room.y1)
			for (x in room.x0...room.x1)
				map[y][x] = floorIndex;
	}
	
	private static function inBounds(width:Int, height:Int, x:Int, y:Int) {
		return x < width && y < height && x >= 0 && y >= 0;
	}
	
	private static function numberOfNeighbours(map:Array<Array<Int>>, x:Int, y:Int, neighbourIndex:Int):Int {
		var neighbours = 0;
		var height = map.length;
		var width = map[0].length;
		
		if (map[y][x] == neighbourIndex)
			neighbours++;
			
		if (inBounds(width, height, x + 1, y) && map[y][x + 1] == neighbourIndex)
			neighbours++;
		if (inBounds(width, height, x , y+1) && map[y+1][x] == neighbourIndex)
			neighbours++;
		if (inBounds(width, height, x - 1, y) && map[y][x - 1] == neighbourIndex)
			neighbours++;
		if (inBounds(width, height, x , y-1) && map[y-1][x] == neighbourIndex)
			neighbours++;
			
		return neighbours;
	}
	
	static function drawCorridor(map:Array<Array<Int>>, corridor:Corridor, wallIndex:Int, floorIndex:Int) {
		var start = corridor.r0.getCenter();
		var end = corridor.r1.getCenter();
		
		var dx = end.x - start.x;
		var dy = end.y - start.y;
		var isZ = false;
		
		if (Math.abs(dx) > Math.abs(dy)) {
			if (dy != 0)
				isZ = true;
			
			var step = dx < 0? -1:1;
			var x = start.x;
			var y = start.y - 1;
			
			var stepsTaken = 0;
			while (x < end.x) {
				var neighbours = numberOfNeighbours(map, x, y - 1, floorIndex);
				if(map[y][x]==wallIndex)
					map[y][x] = -1;
					
				if (isZ && stepsTaken >= dx / 2 - 1) {
					var stepY = dy < 0? -1:1;
					while (y != end.y) {
						y += stepY;
						if(map[y][x]==wallIndex)
							map[y][x] = -1;
					}
				}
					
				x += step;
				stepsTaken++;
			}
		} else {
			if (dx != 0)
				isZ = true;
				
			var step = dy < 0? -1:1;
			var y = start.y;
			var x = start.x - 1;
			
			var stepsTaken = 0;
			while (y < end.y) {
				var neighbours = numberOfNeighbours(map, x, y, floorIndex);
				if(map[y][x]==wallIndex)
					map[y][x] = -1;
				
				if (isZ && stepsTaken >= dy / 2 -1) {
					var stepX = dx < 0? -1:1;
					while (x != end.x) {
						x += stepX;
						if(map[y][x]==wallIndex)
							map[y][x] = -1;
					}
				}	
					
				y += step;
				stepsTaken++;
			}
		}
	}
	
	static function createDoors(map:Array<Array<Int>>, wallIndex:Int, floorIndex:Int):Array<Point> { 
		var doors = new Array<Point>();
		var w = wallIndex;
		var f = floorIndex;
		
		var up =   [[-1,f,-1],
					[w, f, w],
					[f, f, f]];
					
		var down = [[f, f, f],
					[w, f, w],
					[-1,f,-1]];
					
		var right= [[f, w,-1],
					[f, f, f],
					[f, w,-1]];
					
		var left = [[-1,w, f],
					[f, f, f],
					[-1,w, f]];

		function is(a:Int, b:Int) {
			return a == b || a == -1 || b == -1;
		}
					
		var height = map.length;
		var width = map[0].length;
		for (pattern in [up,down,right,left]) {
			for (y in 0...height-3) {
				for (x in 0...width-3) {
					if (is(map[y][x],pattern[0][0]) && is(map[y][x+1],pattern[0][1]) && is(map[y][x+2],pattern[0][2]) &&
						is(map[y+1][x],pattern[1][0]) && is(map[y+1][x+1],pattern[1][1]) && is(map[y+1][x+2],pattern[1][2]) &&
						is(map[y+2][x],pattern[2][0]) && is(map[y+2][x+1],pattern[2][1]) && is(map[y+2][x+2],pattern[2][2])
					)
						doors.push(new Point(x + 1, y + 1));
				}
			}
		}
		
		return doors;
	}
	
	// doesn't check bounds!
	static function countAdjunct(map:Array<Array<Int>>, y:Int, x:Int, doorIndex:Int) {
		var c = 0;
		if (map[y-1][x] == doorIndex)
			c++;
		if (map[y+1][x] == doorIndex)
			c++;
		if (map[y][x-1] == doorIndex)
			c++;
		if (map[y][x+1] == doorIndex)
			c++;
			
		return c;
	}
	
	static function drawDoors(map:Array<Array<Int>>, doors:Array<Point>, doorIndex:Int) { 
		for (door in doors) {
			if(countAdjunct(map, door.y, door.x, doorIndex)==0)
				map[door.y][door.x] = doorIndex;
		}
	}
	
	static function createRoomsInArea(x0:Int, y0:Int, x1:Int, y1:Int, corridors:Array<Corridor>):Array<Room> {
		var rooms = new Array<Room>();
		var width = x1 - x0;
		var height = y1 - y0;
		
		if (width <= maxRoomWidth && height <= maxRoomHeight) {
			if (width >= minRoomHeight && height >= minRoomHeight)
				// add 1 room if possible, 0 if not
				rooms.push(createRandomRoomInRect(x0, y0, x1, y1));
			return rooms;
		}

		
		var horizontalSplit:Bool;
		// if one axis is already small automatically split it on the other one
		if (width < maxRoomWidth)
			horizontalSplit = false;
		else if (height < maxRoomHeight)
			horizontalSplit = true;
		else 
			// choose randomly if both are big
			horizontalSplit = Math.random() < 0.5;
		
		if(horizontalSplit){
			// split horizontaly
			var splitXShift = HxlUtil.randomIntInRange(minRoomWidth, width - minRoomWidth);
			var leftSubMap = createRoomsInArea(x0, y0, x0 + splitXShift, y1, corridors);
			var rightSubMap = createRoomsInArea(x0 + splitXShift + 1, y0, x1, y1, corridors);
			
			// add rooms in left submap
			for (room in leftSubMap)
				rooms.push(room);
			
			// add rooms in right submap
			for (room in rightSubMap)
				rooms.push(room);
				
			// add corridors when possible
			if(rightSubMap.length>0 && leftSubMap.length>0)
				corridors.push(new Corridor(leftSubMap[0], rightSubMap[0]));
		} else {
			// split vertically
			var splitYShift = HxlUtil.randomIntInRange(minRoomHeight, height - minRoomHeight);
			var upperSubMap = createRoomsInArea(x0, y0, x1, y0 + splitYShift, corridors);
			var lowerSubMap = createRoomsInArea(x0, y0 + splitYShift + 1, x1, y1, corridors);
			
			// add rooms in upper submap
			for (room in upperSubMap)
				rooms.push(room);
			
			// add rooms in lower submap
			for (room in lowerSubMap)
				rooms.push(room);

			// add corridors when possible
			if(upperSubMap.length>0 && lowerSubMap.length>0)
				corridors.push(new Corridor(upperSubMap[0], lowerSubMap[0]));
		}
		
		return rooms;
	}
	
	static function isValidCorridor(r0:Room, r1:Room):Bool {
		if (r0 == r1){ 
			return false;
		}
		
		if (r0.getCenter().x <= r1.getCenter().x && r0.getCenter().y <= r1.getCenter().y) {
			return true;
		} else {
			return false;
		}
	}
	
	static function getRandomCorridors(rooms:Array<Room>, numberOfCorridors):Array<Corridor> {
		var corridors = new Array<Corridor>();
		
		var r = 0;
		while (r < numberOfCorridors) {
			var r0 = HxlUtil.getRandomElement(rooms);
			var r1 = r0;
			
			var roomsTried = 0;
			while (!isValidCorridor(r0,r1) && roomsTried<rooms.length) {
				r1 = HxlUtil.getRandomElement(rooms);
				roomsTried++;
			}

			if(roomsTried<rooms.length) {
				corridors.push(new Corridor(r0, r1));
				r++;
			}
		}
		
		return corridors;
	}
	
	public static function getBSPMap(width:Int, height:Int, wallIndex:Int, floorIndex:Int, doorIndex:Int):Array<Array<Int>> {
		var map = new Array<Array<Int>>();
		for (y in 0...height) {
			map.push(new Array<Int>());
			for (x in 0...width)
				map[y].push(wallIndex);
		}
		
		var corridors = new Array<Corridor>();
		var rooms = createRoomsInArea(1, 1, width - 2, height - 2, corridors);

		// insert rooms into map
		for (room in rooms)
			drawRoom(map, room, wallIndex, floorIndex);
		
		// add random loops
		corridors = corridors.concat(getRandomCorridors(rooms, Math.round(rooms.length/2)));
			
		// insert corridors into map
		for (corridor in corridors)
			drawCorridor(map, corridor, wallIndex, floorIndex);
						
		// mark corridors as floor
		for (y in 0...map.length)
			for (x in 0...map[0].length)
				if ( map[y][x] == -1 )
					map[y][x] = floorIndex;
					
		// add doors
		var doors = createDoors(map, wallIndex, floorIndex);
		drawDoors(map, doors, doorIndex);
			
		return map;
	}
}