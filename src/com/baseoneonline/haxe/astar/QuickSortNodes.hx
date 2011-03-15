/*************************
This is basically Disktree.net's haXe Quicksort
slightly modified to add the Node distance "f"
http://blog.disktree.net/?p=27
**************************/
package com.baseoneonline.haxe.astar;

class QuickSortNodes {
	public static function run<T>( a:Array<AStarNode> ) : Array<AStarNode> {
		quicksort( a, 0, a.length-1 );
		return a;
	}
	static function quicksort( a:Array<AStarNode>, lo:Int, hi:Int ):Void{
		var i:Int = lo;
		var j:Int = hi;
		var p = a[Math.floor((lo+hi)/2)].f;
		while( i <= j ){
			while( a[i].f < p ) i++;
			while( a[j].f > p ) j--;
			if( i <= j ){
				var t:AStarNode = a[i];
				a[i++] = a[j];
				a[j--] = t;
			}
		}
		if( lo < j ) quicksort( a, lo, j);
		if( i < hi ) quicksort( a, i, hi);
	}
}