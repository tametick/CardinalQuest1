package com.baseoneonline.haxe.astar;

class AStar
{
	public static var c_searchIndex = 0;
	
	// The dimensions and contents of the entire map
	var width:Int;
	var height:Int;
	var nodes:Array<AStarNode>;
	
	// Our start and goal nodes
	var start:AStarNode;
	var goal:AStarNode;
	
	// open set: nodes to be considered. Implemented as a min heap.
	public var open:Array<AStarNode>;
	
	private inline function getNode(x:Int, y:Int):AStarNode {
		return nodes[y*width + x];
	}
	
	inline function dist(n1:AStarNode):Int {
		// Slow
//		return Std.int(Math.abs(n1.x-goal.x)+Math.abs(n1.y-goal.y));

		// *Much slower*
//		return ((n1.x-goal.x)&0x0000FFFF) + ((n1.y-goal.y)&0x0000FFFF);

		// Fast. Apparently AS3 is implementing these Ints as floats. >_<
		return ((n1.x > goal.x)?n1.x - goal.x:goal.x - n1.x)
			 + ((n1.y > goal.y)?n1.y - goal.y:goal.y - n1.y);
	}
	
	/**
	 * 
	 * @param 	map		The map to be searched, will not be modified
	 * @param	start	Guess what? The starting position!
	 * @param	goal	This is where we want to end up.
	 */
	public function new(map:IAStarSearchable)
	{
		width = map.getWidth();
		height = map.getHeight();
		
		//dist = distEuclidian;

		this.nodes = map.getAStarNodes();
		
		open = new Array<AStarNode>();
	}
	
	public function addToOpenQueue( _node:AStarNode ) {
		var nodePos:Int = open.push(_node) - 1;
		
		while ( nodePos > 0 ) {
			var parentPos:Int = ((nodePos + 1) >> 1) - 1;
			
			if ( open[nodePos].f < open[parentPos].f ) {
				var t:AStarNode = open[nodePos];
				open[nodePos] = open[parentPos];
				open[parentPos] = t;
				
				nodePos = parentPos;
			} else {
				return;
			}
		}
	}
	
	public function removeFromOpenQueue() : AStarNode {
		var rv:AStarNode = open[0];
		
		var last:AStarNode = open.pop();
		
		if ( open.length == 0 ) {
			return rv;
		}
		
		open[0] = last;
		
		var nodePos:Int = 0;
		
		while ( true ) {
			var childLPos:Int = ((nodePos + 1) << 1) - 1;
			var childRPos:Int = childLPos + 1;
			
			if ( open.length <= childLPos ) {
				return rv;
			} else if ( open.length <= childRPos ) {
				if ( open[nodePos].f > open[childLPos].f ) {
					var t:AStarNode = open[nodePos];
					open[nodePos] = open[childLPos];
					open[childLPos] = t;
				}
				return rv;
			} else {
				var minChildPos:Int = open[childLPos].f < open[childRPos].f ? childLPos : childRPos;
				
				if ( open[nodePos].f > open[minChildPos].f ) {
					var t:AStarNode = open[nodePos];
					open[nodePos] = open[minChildPos];
					open[minChildPos] = t;
					
					nodePos = minChildPos;
				} else {
					return rv;
				}
			}
		}
		
		return rv;
	}

	inline function considerNode(x:Int, y:Int, _parent:AStarNode)
	{
		var n:AStarNode = getNode(x, y);

		if (n.walkable) {
			if ( n.searchIdx != c_searchIndex ) {
				n.requestForSearch(c_searchIndex);
				n.parent = _parent;
				n.h = dist(n);
				n.g = _parent.g + n.cost;
				n.f = n.g + n.h;
				addToOpenQueue(n);
			} else {
				if (_parent.g + n.cost < n.g) {
					n.parent = _parent;
					n.g = _parent.g + n.cost;
					n.f = n.g + n.h;
				}
			}
		}
	}
	
	public function solve(startX:Int, startY:Int, goalX:Int, goalY:Int):AStarNode
	{
		this.start = getNode(startX, startY);
		this.goal = getNode(goalX, goalY); 
		
		++c_searchIndex;
		
		//trace("Starting to solve: "+start+" to "+goal);
		while ( open.length > 0 ) {
			open.pop();
		}
		
		var node:AStarNode = start;
		node.requestForSearch(c_searchIndex);
		node.h = dist(node);
		node.f = node.g + node.h;
		addToOpenQueue( node );
		
		// Ok let's start
		while(true) {
			
			if (open.length <= 0) break;

			// Pull a new node off the open queue.
			node = removeFromOpenQueue();
			
			// Could it be true, are we there?
			if (node.x == goal.x && node.y == goal.y) {
				// We found a solution!
				node.child = null;
				while (Std.is(node.parent, AStarNode) && node != start) {
					node.parent.child = node;
					node = node.parent;
				}
				node.parent = null;
				
				return node;
			}
			
			if ( Math.random() < 0.5 ) {
				if ( node.x > 0 ) considerNode( node.x - 1, node.y, node );
				if ( node.y > 0 ) considerNode( node.x, node.y - 1, node );
				if ( node.x < width-1 ) considerNode( node.x + 1, node.y, node );
				if ( node.y < height-1 ) considerNode( node.x, node.y + 1, node );
			} else {
				if ( node.y < height-1 ) considerNode( node.x, node.y + 1, node );
				if ( node.x < width-1 ) considerNode( node.x + 1, node.y, node );
				if ( node.y > 0 ) considerNode( node.x, node.y - 1, node );
				if ( node.x > 0 ) considerNode( node.x - 1, node.y, node );
			}
		}
		
		return null;
	}
}