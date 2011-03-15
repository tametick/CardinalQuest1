package com.baseoneonline.flash.geom
{
	/**
	 * 	Simple integer point implementation
	 * 	
	 * 
	 */
	public class IntPoint
	{
		
		public var x:int;
		public var y:int;
		
		function IntPoint(x:int=0, y:int=0)
		{
			this.x = x;
			this.y = y;
		}
		
		
		public function add(p:IntPoint):void
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
}