package com.baseoneonline.haxe.astar;

import com.baseoneonline.haxe.geom.IntPoint;

class AStar
{
	public static var c_searchIndex = 0;
	
	// The dimensions of the entire map
	var width:Int;
	var height:Int;
	var map:IAStarSearchable;
	
	// Our start and goal nodes
	var start:AStarNode;
	var goal:AStarNode;
	
	// must be two-dimensional array containing AStarNodes;
//	var map:Array<Array<AStarNode>>;
	
	// open set: nodes to be considered
	public var open:NodeSet;
	
	// closed set: nodes not to consider anymore
	public var closed:NodeSet;
	
	// Euclidian is better, but slower 
	//dynamic function dist(){} //= distEuclidian;
	//var dist:Function = distManhattan;	

	// Diagonal moves span a larger distance
	static inline var COST_ORTHOGONAL:Float = 1;
	static inline var COST_DIAGONAL:Float = 1.414;
	
	
	/**
	 * 
	 * @param 	map		The map to be searched, will not be modified
	 * @param	start	Guess what? The starting position!
	 * @param	goal	This is where we want to end up.
	 */
	public function new(map:IAStarSearchable, start:IntPoint, goal:IntPoint)
	{
		++c_searchIndex;
		
		width = map.getWidth();
		height = map.getHeight();
		
		//dist = distEuclidian;
		
		this.start = new AStarNode(start.x, start.y);
		this.goal = new AStarNode(goal.x, goal.y); 
		
		this.map = map;
	}
	
	
	/**
	 * 
	 * 
	 * 		FIND PATH
	 * 
	 * 	Find the path!
	 * 
	 * 	@return	An array of IntPoints describing the resulting path
	 * 
	 */
	public function solve(?allowCardinal:Bool=true, ?allowDiagonal:Bool=true):Array<IntPoint>
	{
		//trace("Starting to solve: "+start+" to "+goal);
		open = new NodeSet(width);
		closed = new NodeSet(width);
		
		var node:AStarNode = start;
		node.h = dist(goal);
		open.push(node);
		
		var solved:Bool = false;
		var i:Int = 0;
		
		
		// Ok let's start
		while(!solved) {
			
			// This line can actually be removed
			//if (i++ > 10000) throw new Error("Overflow");
			if (open.length <= 0) break;
			
			// Sort open list by cost.  This is NOT an algorithmically appropriate way to handle this problem.
			// We should use a priority queue instead.
			open.sort();
			
			if (open.length <= 0) break;
			node = open.shift();
			closed.push(node);
			
			// Could it be true, are we there?
			if (node.x == goal.x && node.y == goal.y) {
				// We found a solution!
				solved = true;
				break;
			}
			
			var n:AStarNode;
			for (n in neighbors(node, allowCardinal, allowDiagonal)) {
				
				if (!hasElement(open,n) && !hasElement(closed,n)) {
					open.push(n);
					n.requestForSearch(c_searchIndex);
					n.parent = node;
					n.h = dist(n);
					n.g = node.g + n.cost;
				} else {
					if (node.g + n.cost < n.g) {
						n.parent = node;
						n.g = node.g + n.cost;
					}
				}
			}
			
			
		}

		// The loop was broken,
		// see if we found the solution
		if (solved) {
			//trace("Solved");
			// We did! Format the data for use.
			var solution:Array<IntPoint> = new Array<IntPoint>();
			// Start at the end...
			solution.push(new IntPoint(node.x, node.y));
			// ...walk all the way to the start to record where we've been...
			while (Std.is(node.parent, AStarNode) && node.parent!=start) {
				node = node.parent;
				solution.push(new IntPoint(node.x, node.y));
			}
			// ...and add our initial position.
			solution.push(new IntPoint(node.x, node.y));
			
			return solution;
		} else {
			// No solution found... :(
			// This might be something else instead
			// (like an array with only the starting position)
			return null;
		}
	}
	
	/**
	 * 	Faster, more inaccurate heuristic method
	 *	Change function name to "dist" to use, and remove the function below
	 */
	function distManhattan(n1:AStarNode, n2:AStarNode=null):Float {
		if (n2 == null) n2 = goal;
		return Math.abs(n1.x-n2.x)+Math.abs(n1.y-n2.y);
	}
	
	/**
	 * 	Slower but much better heuristic method. Actually,
	 * 	this returns just the distance between 2 poInts.
	 */
	function dist(n1:AStarNode, n2:AStarNode=null):Float {
		if (n2 == null) n2 = goal;
		return Math.sqrt(Math.pow((n1.x-n2.x),2)+Math.pow((n1.y-n2.y),2));
	}
	
	
	/**
	 * 
	 * 		NEIGHBORS
	 * 
	 * 	Return a node's neighbors, IF they're walkable
	 * 
	 * 	@return An array of AStarNodes.
	 */
	function neighbors(node:AStarNode, ?allowCardinal:Bool=true, ?allowDiagonal:Bool=true):Array<AStarNode>
	{
		var x:Int = node.x;
		var y:Int = node.y;
		var n:AStarNode;
		var a:Array<AStarNode> = new Array<AStarNode>();
		
		if ( allowCardinal ) {
			if ( Math.random() < 0.5 ) {
				// W
				if (x > 0) {
					
					n = map.getNode(x-1, y);
					if (n.walkable) {
						n.cost = COST_ORTHOGONAL;
						a.push(n);
					}
				}
				// E
				if (x < width-1) {
					n = map.getNode(x+1, y);
					if (n.walkable) {
						n.cost = COST_ORTHOGONAL;
						a.push(n);
					}
				} 
				// N
				if (y > 0) {
					n = map.getNode(x, y-1);
					if (n.walkable) {
						n.cost = COST_ORTHOGONAL;
						a.push(n);
					}
				}
				// S
				if (y < height-1) {
					n = map.getNode(x, y+1);
					if (n.walkable) {
						n.cost = COST_ORTHOGONAL;
						a.push(n);
					}
				}
			} else {
				// S
				if (y < height-1) {
					n = map.getNode(x, y+1);
					if (n.walkable) {
						n.cost = COST_ORTHOGONAL;
						a.push(n);
					}
				}
				// N
				if (y > 0) {
					n = map.getNode(x, y-1);
					if (n.walkable) {
						n.cost = COST_ORTHOGONAL;
						a.push(n);
					}
				}
				// E
				if (x < width-1) {
					n = map.getNode(x+1, y);
					if (n.walkable) {
						n.cost = COST_ORTHOGONAL;
						a.push(n);
					}
				} 
				// W
				if (x > 0) {
					
					n = map.getNode(x-1, y);
					if (n.walkable) {
						n.cost = COST_ORTHOGONAL;
						a.push(n);
					}
				}
			}
		}
		
		// Don't cut corners here,
		// but make diagonal travelling possible.
		
		if ( allowDiagonal ) {
			// NW
			if (x > 0 && y > 0) {
				n = map.getNode(x-1, y-1);
				if (n.walkable 
					&& map.getNode(x-1, y).walkable 
					&& map.getNode(x, y-1).walkable
				) {						
					n.cost = COST_DIAGONAL;
					a.push(n);
				}
			}
			// NE
			if (x < width-1 && y > 0) {
				n = map.getNode(x+1, y-1);
				if (n.walkable 
					&& map.getNode(x+1, y).walkable 
					&& map.getNode(x, y-1).walkable
				) {
					n.cost = COST_DIAGONAL;
					a.push(n);
				}
			}
			// SW
			if (x > 0 && y < height-1) {
				n = map.getNode(x-1, y+1);
				if (n.walkable
					&& map.getNode(x-1, y).walkable 
					&& map.getNode(x, y+1).walkable
				) {
					n.cost = COST_DIAGONAL;
					a.push(n);
				}
			}
			// SE
			if (x < width-1 && y < height-1) {
				n = map.getNode(x+1, y+1);
				if (n.walkable
					&& map.getNode(x+1, y).walkable
					&& map.getNode(x, y+1).walkable
				) {
					n.cost = COST_DIAGONAL;
					a.push(n);
				}
			}
		}
		
		return a;
		
	}
	
	
	/**
	 * 		HAS ELEMENT
	 * 
	 * Checks if a given array contains the object specified.
	 */
	static function hasElement(a:NodeSet, e:AStarNode):Bool
	{
		return a.exists(e);
	}
}



private class NodeSet {
	var list:Array<AStarNode>;
	var set:IntHash<Bool>;
	var width:Int;
	
	public var length(default, null):Int;
	
	private inline function index(node:AStarNode) {
		return node.x + width * node.y;
	}
	
	public function new(mapWidth:Int) {
		list = new Array<AStarNode>();
		set = new IntHash<Bool>();
		
		width = mapWidth;
		length = 0;
	}
	
	public function push(node:AStarNode) {
		list.push(node);
		set.set(index(node), true);
		length++;
	}
	
	public function pop():AStarNode {
		var curNode = list.pop();
		if (curNode != null) {
			set.remove(index(curNode));
			length--;
		}
		return curNode;
	}
	
	public function shift():AStarNode {
		var curNode = list.shift();
		if (curNode != null) {
			set.remove(index(curNode));
			length--;
		}
		return curNode;
	}
	
	public function exists(node:AStarNode):Bool {
		return set.exists(index(node));
	}
	
	public function sort() {
		// see the comment where this is used -- it is not an acceptable way of writing A*.
		QuickSortNodes.run(list);
	}
}
