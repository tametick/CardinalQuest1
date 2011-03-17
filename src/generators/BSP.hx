package generators;
import haxel.HxlUtil;

class BSP 
{
	public static var minWidth = 5;
	public static var minHeight = 5;	
	
	static function insertSubMap(map:Array<Array<Int>>, subMap:Array<Array<Int>>, subWidth:Int, subHeight:Int, xShift:Int, yShift:Int) {
		for (y in 0...subHeight)
			for (x in 0...subWidth)
				map[y + yShift][x + xShift] = subMap[y][x];
	}
	
	public static function getBSPMap(width:Int, height:Int, wallIndex:Int, floorIndex:Int, doorIndex:Int):Array<Array<Int>> {
		var map = new Array<Array<Int>>();
		for (y in 0...height) {
			map.push(new Array<Int>());
			for (x in 0...width)
				map[y].push(wallIndex);
		}
		
		var horizontal=true;
		if (Math.random() < 0.5)
			horizontal = false;
			
			
		var submap1, submap2:Array<Array<Int>>;
		var tooSmall = true;
		if (horizontal) {
			if (tooSmall)
				return map;
			
			var splitX = HxlUtil.randomInt(Math.round(width / 2)) + Math.round(width / 4);
			submap1 = getBSPMap(splitX, height, wallIndex, floorIndex, doorIndex);
			submap2 = getBSPMap(width - splitX, height, wallIndex, floorIndex, doorIndex);
			insertSubMap(map, submap1, splitX, height, 0, 0);
			insertSubMap(map, submap2, width - splitX, height, splitX, 0);
		} else {
			if (tooSmall)
				return map;
				
			var splitY = HxlUtil.randomInt(Math.round(height / 2)) + Math.round(height / 4);
			submap1 = getBSPMap(width, splitY, wallIndex, floorIndex, doorIndex);
			submap2 = getBSPMap(width, height - splitY, wallIndex, floorIndex, doorIndex);
			insertSubMap(map, submap1, width, splitY, 0, 0);
			insertSubMap(map, submap2, width, height-splitY, 0, splitY);
		}
		
		return map;
	}
	
	public static function main() {
		var map = getBSPMap(30, 30, 0, 8, 5);
		for (y in 0...30)
			trace(map[y]);
	}
}