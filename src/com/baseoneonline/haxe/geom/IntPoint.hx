package com.baseoneonline.haxe.geom;

/**
 * 	Simple integer point implementation
 * 	
 * 
 */
class IntPoint
{
	
	public var x:Int;
	public var y:Int;
	
	public function new(x:Int=0, y:Int=0)
	{
		this.x = x;
		this.y = y;
	}
	
	
	public function add(p:IntPoint)
	{
		x += p.x;
		y += p.y;
	}
	
	public function addNew(p:IntPoint):IntPoint {
		return new IntPoint(x+p.x, y+p.y);
	}
	

	public function toString():String
	{
		return "IntPoint("+x+", "+y+")";
	}
			
}