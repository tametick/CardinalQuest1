package detribus.generators;

/**
 * Based on AS3 code by Eddie Lee:
 * http://illogictree.com/upload/FlxCaveGenerator.as
 */

import haxel.HxlUtil;
 
class CellularAutomata 
{

	var width:Int;
	var height:Int;
	
	/**
	 * How many times do you want to "smooth" the cave.
	 * The higher number the smoother.
	 */
	static var numSmoothingIterations:Int;
	
	/**
	 * During initial state, how percent of matrix are walls?
	 * The closer the value is to 1.0, more wall-e the area is
	 */
	static var initWallRatio:Float = 0.5;
	
	var floor:Int;
	var wall:Int;
	
	public function new(width:Int, height:Int, ?floor:Int = 1, ?wall:Int = 0) {
		this.width = width;
		this.height = height;
		numSmoothingIterations = 6;
		initWallRatio = 0.5;
		this.wall = wall;
		this.floor = floor;
	}
	
	static public function convertMatrixToStr( mat:Array<Array<Int>> ):String {
		var mapString:String = "";
		
		for ( y in 0...mat.length){
			for ( x in 0...mat[y].length )
				mapString += Std.string(mat[y][x]) + ",";
			
			mapString += "\n";
		}
		
		return mapString;
	}
	
	function genInitMatrix( rows:Int, cols:Int ):Array<Array<Int>> {
		// Build array of 1s
		var mat:Array<Array<Int>> = new Array<Array<Int>>();
		for ( y in 0...rows )
		{
			mat.push( new Array<Int>() );
			for ( x in 0...cols )
				mat[y].push(wall);
		}
		
		return mat;
	}
	
	/**
	 * 
	 * @param	mat		Matrix of data (0=empty, 1 = wall)
	 * @param	xPos	Column we are examining
	 * @param	yPos	Row we are exampining
	 * @param	dist	Radius of how far to check for neighbors
	 * 
	 * @return	Number of walls around the target, including itself
	 */
	function countNumWallsNeighbors( mat:Array<Array<Int>>, xPos:Int, yPos:Int, ?dist:Int = 1 ):Int	{
		var count:Int = 0;
		
		for ( y in -dist...dist+1 )
		{
			for ( x in -dist...dist+1 )
			{
				// Boundary
				if ( xPos + x < 0 || xPos + x > width - 1
					 || yPos + y < 0 || yPos + y > height - 1 ) 
					continue;
				
				// Neighbor is non-wall
				if ( mat[yPos + y][xPos + x] != wall ) 
					++count;
			}
		}
		
		return count;
	}
	
	/**
	 * Use the 4-5 rule to smooth cells
	 */
	function runCelluarAutomata( inMat:Array<Array<Int>>, outMat:Array<Array<Int>> ) {
		var numRows = inMat.length;
		var numCols = inMat[0].length;
		
		for ( y in 0...numRows )
		{
			for ( x in 0...numCols)
			{
				var numWalls:Int = countNumWallsNeighbors( inMat, x, y, 1 );
				
				if ( numWalls >= 5 ) 
					outMat[y][x] = floor;
				else 
					outMat[y][x] = wall;
			}
		}
	}
	
	function getCellularAutomataMap():Array<Array<Int>> {
		// Initialize random array
		var mat = genInitMatrix( height, width );
		for ( y in 0...height )
		{
			for ( x in 0...width ) {
				var r = Math.random();
				mat[y][x] =  r<initWallRatio? floor:wall ;
			}
		}
		
		// Secondary buffer
		var mat2 = genInitMatrix( height, width );
		
		// Run automata
		for ( i in 0...numSmoothingIterations )
		{
			runCelluarAutomata( mat, mat2 );
			
			// Swap
			var temp = mat;
			mat = mat2;
			mat2 = temp;
		}
		
		return mat;
	}
	
	public function getCaveMap():Array<Array<Int>> {
		var caMap = getCellularAutomataMap();
		
		// fill edges with wall
		for (y in 0...height){
			caMap[y][0] = wall;
			caMap[y][width-1] = wall;
		}
		for (x in 0...width){
			caMap[0][x] = wall;
			caMap[height-1][x] = wall;
		}
		
		// mark disconnected areas
		var markedMap = HxlUtil.cloneMap(caMap);
		var connected = MapGenerator.isFullyConnected(width, height, caMap, [floor], markedMap, -1);
		
		var accesibleTiles = HxlUtil.countTiles(width, height, markedMap, [floor]);
				
		if (accesibleTiles > width * height / 3) {
			HxlUtil.repalceAllTiles(width, height, markedMap, -1, wall);
			return markedMap;
		}
		else 
			return getCaveMap();
	}
	
	
	public static function main() {
		var ca  = new CellularAutomata(20, 20,1,8);
		var cave = ca.getCaveMap();
		trace("\n"+convertMatrixToStr(cave));
	}
}