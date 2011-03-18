package generators;
import haxel.HxlUtil;

private class Point {
	public var x:Int;
	public var y:Int;
	public function new(x:Int, y:Int) {
		this.x = x;
		this.y = y;
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
	
	static function drawCorridor(map:Array<Array<Int>>, corridor:Corridor, wallIndex:Int, floorIndex:Int, doorIndex:Int) {
		
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
		
		// insert corridors into map
		for (corridor in corridors)
			drawCorridor(map, corridor, wallIndex, floorIndex, doorIndex);
		
		trace(corridors.length);
			
		return map;
	}
	
	public static function main() {
		var mapSize = 30;
		var map = getBSPMap(mapSize, mapSize, 0, 1, 5);
		for (y in 0...mapSize)
			trace(map[y]);
	}
}