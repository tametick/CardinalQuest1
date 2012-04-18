package com.baseoneonline.haxe.astar;

/**
 * 	Defines a weighted point/tile for use in AStar
 * 
 */
class AStarNode
{
	public var x:Int;
	public var y:Int;
	
	public var searchIdx:Int;
	
	public var g:Int;
	public var h:Int;
	public var cost:Int;
	public var f:Int;
	
	// Needed to return a solution (trackback)
	public var parent:AStarNode;
	public var child:AStarNode;
	
	// Taken from the original tile
	public var walkable:Bool;
	
	public function new(x:Int, y:Int, walkable:Bool=true)
	{
		this.x = x;
		this.y = y;
		
		searchIdx = -1;
		
		g = 0;
		h = 0;
		cost = 1;
		this.walkable = walkable;
	}
	
	public function requestForSearch( _searchIdx:Int ) {
		if ( _searchIdx != searchIdx ) {
			g = 0;
			h = 0;
//			cost = 1;
			searchIdx = _searchIdx;
		}
	}
/*	
	function get_f():Float {
		return g+h;
	}
	*/		

}
