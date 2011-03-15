package haxel;

/**
 * Stores a rectangle.
 */
class HxlRect extends HxlPoint {

	public var bottom(getBottom, null):Float;
	public var left(getLeft, null):Float;
	public var right(getRight, null):Float;
	public var top(getTop, null):Float;
	/**
	 * @default 0
	 */
	public var width:Float;
	/**
	 * @default 0
	 */
	public var height:Float;
	
	/**
	 * Instantiate a new rectangle.
	 * 
	 * @param	X		The X-coordinate of the point in space.
	 * @param	Y		The Y-coordinate of the point in space.
	 * @param	Width	Desired width of the rectangle.
	 * @param	Height	Desired height of the rectangle.
	 */
	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=0, ?Height:Float=0) {
		super(X,Y);
		width = Width;
		height = Height;
	}
	
	/**
	 * The X coordinate of the left side of the rectangle.  Read-only.
	 */
	public function getLeft():Float	{
		return x;
	}
	
	/**
	 * The X coordinate of the right side of the rectangle.  Read-only.
	 */
	public function getRight():Float {
		return x + width;
	}
	
	/**
	 * The Y coordinate of the top of the rectangle.  Read-only.
	 */
	public function getTop():Float {
		return y;
	}
	
	/**
	 * The Y coordinate of the bottom of the rectangle.  Read-only.
	 */
	public function getBottom():Float {
		return y + height;
	}

}
