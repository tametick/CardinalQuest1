package com.baseoneonline.haxe.astar;

class PathTile
{
	
	public var walkable:Bool;
	public var id:Int;
	
	
	public function new(walkable:Bool=true, id:Int=-1)
	{
		this.id = id;
		this.walkable = walkable;
	}
	
	
}