package com.baseoneonline.haxe.astar;

import com.baseoneonline.haxe.geom.IntPoint;

/**
 * 	Defines a weighted point/tile for use in AStar
 * 
 */
class AStarNode extends IntPoint
{
	
	public var g:Float;
	public var h:Float;
	public var cost:Float;
	public var f(get_f,null):Float;
	
	// Needed to return a solution (trackback)
	public var parent:AStarNode;
	
	// Taken from the original tile
	public var walkable:Bool;
	
	public function new(x:Int, y:Int, walkable:Bool=true)
	{
		g = 0;
		h = 0;
		cost = 1;
		super(x,y);
		this.walkable = walkable;
	}
	
	function get_f():Float {
		return g+h;
	}
			

}