package com.baseoneonline.flash.astar
{
	import com.baseoneonline.flash.geom.IntPoint;
	
	/**
	 * 	Defines a weighted point/tile for use in AStar
	 * 
	 */
	public class AStarNode extends IntPoint
	{
		
		public var g:Number = 0;
		public var h:Number = 0;
		public var cost:Number = 1;
		
		// Needed to return a solution (trackback)
		public var parent:AStarNode;
		
		// Taken from the original tile
		public var walkable:Boolean;
		
		function AStarNode(x:int, y:int, walkable:Boolean=true)
		{
			super(x,y);
			this.walkable = walkable;
		}
		
		public function get f():Number {
			return g+h;
		}
				
	
	}
}