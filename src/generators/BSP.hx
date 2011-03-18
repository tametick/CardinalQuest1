package generators;
import haxel.HxlUtil;

class Room {
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
}

class BSP 
{
	public static var minRoomWidth = 3;
	public static var minRoomHeight = 3;
	// needs to be >=2*min
	public static var maxRoomWidth = 8;
	public static var maxRoomHeight = 8;
	
	static function createRandomRoomInRect(x0:Int, y0:Int, x1:Int, y1:Int):Room {
		var maxWidth = x1 - x0;
		var maxHeight = y1 - y0;
		
		var width = HxlUtil.randomIntInRange(Math.floor(maxWidth/3), maxWidth);
		var height = HxlUtil.randomIntInRange(Math.floor(maxWidth/3), maxHeight);
				
		return new Room(x0, y0, x0+width, y0+height);
	}
	
	static function insertRoom(map:Array<Array<Int>>, room:Room, wallIndex:Int, floorIndex:Int) {
		for (y in room.y0...room.y1)
			for (x in room.x0...room.x1)
				map[y][x] = floorIndex;
	}
	
	static function createCorridor(map:Array<Array<Int>>, room1:Room, room2:Room, wallIndex:Int, floorIndex:Int, doorIndex:Int) {
		
	}
	
	static function getRoomsInArea(x0:Int, y0:Int, x1:Int, y1:Int):Array<Room> {
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
			
			// add rooms in left submap
			for (room in getRoomsInArea(x0, y0, x0 + splitXShift, y1))
				rooms.push(room);
			
			// add rooms in right submap
			for (room in getRoomsInArea(x0 + splitXShift, y0, x1, y1))
				rooms.push(room);				
		} else {
			// split vertically
			var splitYShift = HxlUtil.randomIntInRange(minRoomHeight, height - minRoomHeight);
			
			// add rooms in upper submap
			for (room in getRoomsInArea(x0, y0, x1, y0+splitYShift))
				rooms.push(room);
			
			// add rooms in lower submap
			for (room in getRoomsInArea(x0, y0+splitYShift, x1, y1))
				rooms.push(room);
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
		
		var rooms = getRoomsInArea(0, 0, width - 1, height - 1);

		// insert rooms into map
		for (room in rooms)
			insertRoom(map, room, wallIndex, floorIndex);
		
		// create corridors between rooms
		for (r in 0...rooms.length-2)
			createCorridor(map, rooms[r], rooms[r + 1], wallIndex, floorIndex, doorIndex);
		
		return map;
	}
	
	public static function main() {
		var mapSize = 32;
		var map = getBSPMap(mapSize, mapSize, 0, 1, 5);
		for (y in 0...mapSize)
			trace(map[y]);
	}
}