package haxel;

class HxlPoint {
		
	/**
	 * @default 0
	 */
	public var x:Float;
	/**
	 * @default 0
	 */
	public var y:Float;
	
	/**
	 * Instantiate a new point object.
	 * 
	 * @param	X		The X-coordinate of the point in space.
	 * @param	Y		The Y-coordinate of the point in space.
	 */
	public function new(?X:Float=0, ?Y:Float=0)	{
		x = X;
		y = Y;
	}

	public function clone():HxlPoint {
		return new HxlPoint(x, y);
	}
	public function toString() {
        return "<"+x+","+y+">";
    }
	public function intEquals(o:HxlPoint):Bool {
		return Math.round(x)==Math.round(o.x) && Math.round(y)==Math.round(o.y);
	}
}
