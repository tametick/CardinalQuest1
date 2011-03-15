package com.baseoneonline.flash.astar
{
	import com.baseoneonline.flash.geom.IntPoint;
	
	
	
	public class AStar
	{
		// The dimensions of the entire map
		private var width:int;
		private var height:int;
		
		// Our start and goal nodes
		private var start:AStarNode;
		private var goal:AStarNode;
		
		// must be two-dimensional array containing AStarNodes;
		private var map:Array;
		
		// open set: nodes to be considered
		public var open:Array;
		
		// closed set: nodes not to consider anymore
		public var closed:Array;
		
		// This variable is not necessary,
		// it's just for debugging purposes,
		// delete it and all references to it.
		public var visited:Array = [];
		
		// Euclidian is better, but slower 
		private var dist:Function = distEuclidian;
		//private var dist:Function = distManhattan;	
	
		// Diagonal moves span a larger distance
		private static const COST_ORTHOGONAL:Number = 1;
		private static const COST_DIAGONAL:Number = 1.414;
		
		
		/**
		 * 
		 * @param 	map		The map to be searched, will not be modified
		 * @param	start	Guess what? The starting position!
		 * @param	goal	This is where we want to end up.
		 */
		function AStar(map:IAStarSearchable, start:IntPoint, goal:IntPoint)
		{
			width = map.getWidth();
			height = map.getHeight();
			
			this.start = new AStarNode(start.x, start.y);
			this.goal = new AStarNode(goal.x, goal.y); 
			this.map = createMap(map);
			
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
		public function solve():Array
		{
			trace("Starting to solve: "+start+" to "+goal);
			open = new Array();
			closed = new Array();
			visited = new Array();
			
			
			var node:AStarNode = start;
			node.h = dist(goal);
			open.push(node);
			
			var solved:Boolean = false;
			var i:int = 0;
			
			
			// Ok let's start
			while(!solved) {
				
				// This line can actually be removed
				if (i++ > 10000) throw new Error("Overflow");
				
				// Sort open list by cost
				open.sortOn("f",Array.NUMERIC);
				if (open.length <= 0) break;
				node = open.shift();
				closed.push(node);
				
				// Could it be true, are we there?
				if (node.x == goal.x && node.y == goal.y) {
					// We found a solution!
					solved = true;
					break;
				}
				
				for each (var n:AStarNode in neighbors(node)) {
					
					if (!hasElement(open,n) && !hasElement(closed,n)) {
						open.push(n);
						n.parent = node;
						n.h = dist(n);
						n.g = node.g;
					} else {
						var f:Number = n.g + node.g + n.h;
						if (f < n.f) {
							n.parent = node;
							n.g = node.g;
						}
					}
					visit (n);
				}
				
				
			}

			// The loop was broken,
			// see if we found the solution
			if (solved) {
				trace("Solved");
				// We did! Format the data for use.
				var solution:Array = new Array();
				// Start at the end...
				solution.push(new IntPoint(node.x, node.y));
				// ...walk all the way to the start to record where we've been...
				while (node.parent && node.parent!=start) {
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
		 * 	For debug only, remove to gain performance	
		 */
		private function visit(n:AStarNode):void
		{
			for each(var node:AStarNode in visited) {
				if (node == n) return;
			}
			visited.push(n);
		}
		
		/**
		 * 	Faster, more inaccurate heuristic method
		 */
		private function distManhattan(n1:AStarNode, n2:AStarNode=null):Number {
			if (n2 == null) n2 = goal;
			return Math.abs(n1.x-n2.x)+Math.abs(n1.y-n2.y);
		}
		
		/**
		 * 	Slower but much better heuristic method. Actually,
		 * 	this returns just the distance between 2 points.
		 */
		private function distEuclidian(n1:AStarNode, n2:AStarNode=null):Number {
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
		private function neighbors(node:AStarNode):Array
		{
			var x:int = node.x;
			var y:int = node.y;
			var n:AStarNode;
			var a:Array = [];
			
			
			// N
			if (x > 0) {
				
				n = map[x-1][y];
				if (n.walkable) {
					n.g += COST_ORTHOGONAL;
					a.push(n);
				}
			}
			// E
			if (x < width-1) {
				n = map[x+1][y];
				if (n.walkable) {
					n.g += COST_ORTHOGONAL;
					a.push(n);
				}
			} 
			// N
			if (y > 0) {
				n = map[x][y-1];
				if (n.walkable) {
					n.g += COST_ORTHOGONAL;
					a.push(n);
				}
			}
			// S
			if (y < height-1) {
				n = map[x][y+1];
				if (n.walkable) {
					n.g += COST_ORTHOGONAL;
					a.push(n);
				}
			}
			
			// Don't cut corners here,
			// but make diagonal travelling possible.
			
			// NW
			if (x > 0 && y > 0) {
				n = map[x-1][y-1];
				if (n.walkable 
					&& map[x-1][y].walkable 
					&& map[x][y-1].walkable
				) {						
					n.g += COST_DIAGONAL;
					a.push(n);
				}
			}
			// NE
			if (x < width-1 && y > 0) {
				n = map[x+1][y-1];
				if (n.walkable 
					&& map[x+1][y].walkable 
					&& map[x][y-1].walkable
				) {
					n.g += COST_DIAGONAL;
					a.push(n);
				}
			}
			// SW
			if (x > 0 && y < height-1) {
				n = map[x-1][y+1];
				if (n.walkable
					&& map[x-1][y].walkable 
					&& map[x][y+1].walkable
				) {
					n.g += COST_DIAGONAL;
					a.push(n);
				}
			}
			// SE
			if (x < width-1 && y < height-1) {
				n = map[x+1][y+1];
				if (n.walkable
					&& map[x+1][y].walkable
					&& map[x][y+1].walkable
				) {
					n.g += COST_DIAGONAL;
					a.push(n);
				}
			}
			
			
			return a;
			
		}
		
		
		
		
		
		
		
		/**
		 * 		CREATE MAP
		 * 
		 * Create a map with cost and heuristic values for each tile
		 * 
		 */
		private function createMap(map:IAStarSearchable):Array
		{
			var a:Array = new Array(width);
			for (var x:int=0; x<width; x++) {
				a[x] = new Array(height);
				for (var y:int=0; y<height; y++) {
					var node:AStarNode = new AStarNode(x,y,map.isWalkable(x,y));
					a[x][y] = node;
				}
			}
			
			return a;
		}
		
		
		
		
		
		
		
		
		
		
		/**
		 * 		HAS ELEMENT
		 * 
		 * Checks if a given array contains the object specified.
		 */
		private static function hasElement(a:Array, e:Object):Boolean
		{
			for each(var o:Object in a) {
				if (o == e) return true;
			}
			return false;
		}
		
		
		
		
		
		
		
		/**
		 * 		REMOVE FROM ARRAY
		 * 
		 * Remove an element from an array
		 */
		private static function removeFromArray(a:Array, e:Object):Boolean
		{
			for (var i:int=0; i<a.length; i++) {
				if (a[i] == e) {
					a.splice(i,1);
					return true;
				}
			}
			return false;
		}
		
	
		
		
		
	}



}




