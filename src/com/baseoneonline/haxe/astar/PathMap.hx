package com.baseoneonline.haxe.astar;

import flash.errors.Error;

class PathMap implements IAStarSearchable
{
	
	var width:Int;
	var height:Int;
	
	var map:Array<Array<PathTile>>;		
	
	/**
	 * 	CONSTRUCTOR
	 * 
	 */
	public function new(width:Int, height:Int) {
		this.width = width;
		this.height = height;
		initialize();
	}
	
	
	
	public function getWidth():Int {
		return width;
	}
	
	public function getHeight():Int {
		return height;
	}
	
	/**
	 * 	Size the map and fill with empty tiles
	 * 
	 */
	public function initialize():Void
	{
		map = new Array<Array<PathTile>>();
		var x:Int = 0;
		var y:Int = 0;
		for (x in 0...width) {
			map[x] = new Array<PathTile>();
			for (y in 0...height) {
				map[x][y] = new PathTile();
			}
		}
	}
	
	/**
	 * 	Return a Tile at this position
	 * 
	 */
	public function getTile(x:Int, y:Int):PathTile {
		outOfBoundsCheck(x,y);
		return map[x][y];
	}

	/**
	 * 
	 */
	public function setWalkable(x:Int, y:Int, walkable:Bool):Void
	{
		outOfBoundsCheck(x,y);
		map[x][y].walkable = walkable;
	}
		
	public function isWalkable(x:Int, y:Int):Bool
	{
		outOfBoundsCheck(x,y);
		return map[x][y].walkable;
	}

	
	
	function outOfBoundsCheck(x:Int, y:Int):Void
	{
		if (x<0||x>width-1||y<0||y>height-1) throw new Error("Position out of bounds ("+x+", "+y+")");
	}

	
}