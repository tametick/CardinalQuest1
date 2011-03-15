package haxel;

import haxel.HxlObject;

/**
 * The world's smallest linked list class.
 * Useful for optimizing time-critical or highly repetitive tasks!
 * See <code>HxlQuadTree</code> for how to use it, IF YOU DARE.
 */
class HxlList {
	
	/**
	 * Stores a reference to a <code>HxlObject</code>.
	 */
	public var object:HxlObject;
	/**
	 * Stores a reference to the next link in the list.
	 */
	public var next:HxlList;
	
	/**
	 * Creates a new link, and sets <code>object</code> and <code>next</code> to <code>null</null>.
	 */
	public function new()
	{
		object = null;
		next = null;
	}
}
