package haxel;

import flash.net.URLRequest;
import flash.Lib;

import haxel.HxlTilemap;

class Range {
	public function new(start:Int, end:Int) { 
		this.start = start;
		this.end = end;
	}
	public var start:Int;
	public var end:Int;
}

class HxlUtil {

	public function new() { }

	public static var roundingError:Float = 0.0000001;

	/**
	 * The global quad tree (stored here since it is used primarily by HxlUtil functions).
	 * Set this to null to force it to refresh on the next collide.
	 */
	public static var quadTree:HxlQuadTree;
	/**
	 * This variable stores the dimensions of the root of the quad tree.
	 * This is the eligible game collision space.
	 */
	public static var quadTreeBounds:HxlRect;
	/**
	 * Controls the granularity of the quad tree.  Default is 3 (decent performance on large and small worlds).
	 */
	public static var quadTreeDivisions:Int = 3;

	/**
	 * Internal random number calculation helpers.
	 */
	static var _seed:Float;

	public static function colorRGB(Color:Int):Array<Int> {
		var rgb:Array<Int> = new Array();
		rgb[0] = Color >> 16 & 0xFF;
		rgb[1] = Color >> 8 & 0xFF;
		rgb[2] = Color & 0xFF;
		return rgb;
	}

	public static function colorInt(Red:Int, Green:Int, Blue:Int):Int {
		return (Math.round(Red) << 16) | (Math.round(Green) << 8) | Math.round(Blue);
	}

	public static function floor(N:Float):Int {
		var n:Int = Math.floor(N);
		return (N>0)?(n):((n!=N)?(n-1):(n));
	}

	public static function ceil(N:Float):Int {
		var n:Int = Math.floor(N);
		return (N>0)?((n!=N)?(n+1):(n)):(n);
	}

	/**
	 * Generate a pseudo-random number.
	 * 
	 * @param	UseGlobalSeed		Whether or not to use the stored HxlUtil.seed value to calculate it.
	 * 
	 * @return	A pseudo-random Number object.
	 */
	public static function random(?UseGlobalSeed:Bool=true):Float {
		if (UseGlobalSeed && !Math.isNaN(_seed)) {
			var random:Float = randomize(_seed);
			_seed = mutate(_seed,random);
			return random;
		} else {
			return Math.random();
		}
	}

	/**
	 * Generate a pseudo-random number.
	 * 
	 * @param	Seed		The number to use to generate a new random value.
	 * 
	 * @return	A pseudo-random Number object.
	 */
	public static function randomize(Seed:Float):Float {
		return ((69621 * Math.floor(Seed * 0x7FFFFFFF)) % 0x7FFFFFFF) / 0x7FFFFFFF;
	}

	/**
	 * Mutates a seed or other number, useful when combined with <code>randomize()</code>.
	 * 
	 * @param	Seed		The number to mutate.
	 * @param	Mutator		The value to use in the mutation.
	 * 
	 * @return	A predictably-altered version of the Seed.
	 */
	public static function mutate(Seed:Float,Mutator:Float):Float {
		Seed += Mutator;
		if (Seed > 1) Seed -= Math.floor(Seed);
		return Seed;
	}

	/**
	 * Call this function to specify a more efficient boundary for your game world.
	 * This boundary is used by <code>overlap()</code> and <code>collide()</code>, so it
	 * can't hurt to have it be the right size!  Flixel will invent a size for you, but
	 * it's pretty huge - 256x the size of the screen, whatever that may be.
	 * Leave width and height empty if you want to just update the game world's position.
	 * 
	 * @param	X			The X-coordinate of the left side of the game world.
	 * @param	Y			The Y-coordinate of the top of the game world.
	 * @param	Width		Desired width of the game world.
	 * @param	Height		Desired height of the game world.
	 * @param	Divisions	Pass a non-zero value to set <code>quadTreeDivisions</code>.  Default value is 3.
	 */
	public static function setWorldBounds(?X:Float=0, ?Y:Float=0, ?Width:Float=0, ?Height:Float=0, ?Divisions:Int=3):Void {
		if (quadTreeBounds == null) {
			quadTreeBounds = new HxlRect();
		}
		quadTreeBounds.x = X;
		quadTreeBounds.y = Y;
		if (Width > 0) {
			quadTreeBounds.width = Width;
		}
		if (Height > 0) {
			quadTreeBounds.height = Height;
		}
		if (Divisions > 0) {
			quadTreeDivisions = Divisions;
		}
	}

	/**
	 * Call this function to see if one <code>HxlObject</code> overlaps another.
	 * Can be called with one object and one group, or two groups, or two objects,
	 * whatever floats your boat!  It will put everything into a quad tree and then
	 * check for overlaps.  For maximum performance try bundling a lot of objects
	 * together using a <code>HxlGroup</code> (even bundling groups together!)
	 * NOTE: does NOT take objects' scrollfactor into account.
	 * 
	 * @param	Object1		The first object or group you want to check.
	 * @param	Object2		The second object or group you want to check.  If it is the same as the first, flixel knows to just do a comparison within that group.
	 * @param	Callback	A function with two <code>HxlObject</code> parameters - e.g. <code>myOverlapFunction(Object1:HxlObject,Object2:HxlObject);</code>  If no function is provided, <code>HxlQuadTree</code> will call <code>kill()</code> on both objects.
	 */
	public static function overlap(Object1:HxlObject,Object2:HxlObject,?Callback:Dynamic=null):Bool {
		if ( (Object1 == null) || !Object1.exists ||(Object2 == null) || !Object2.exists ) {
			return false;
		}
		quadTree = new HxlQuadTree(quadTreeBounds.x,quadTreeBounds.y,quadTreeBounds.width,quadTreeBounds.height);
		quadTree.add(Object1,HxlQuadTree.A_LIST);
		if (Object1 == Object2) {
			return quadTree.overlap(false,Callback);
		}
		quadTree.add(Object2,HxlQuadTree.B_LIST);
		return quadTree.overlap(true,Callback);
	}

	/**
	 * A tween-like function that takes a starting velocity
	 * and some other factors and returns an altered velocity.
	 * 
	 * @param	Velocity		Any component of velocity (e.g. 20).
	 * @param	Acceleration	Rate at which the velocity is changing.
	 * @param	Drag			Really kind of a deceleration, this is how much the velocity changes if Acceleration is not set.
	 * @param	Max				An absolute value cap for the velocity.
	 * 
	 * @return	The altered Velocity value.
	 */
	public static function computeVelocity(Velocity:Float, ?Acceleration:Float=0, ?Drag:Float=0, ?Max:Float=10000):Float {
		if (Acceleration != 0) {
			Velocity += Acceleration*HxlGraphics.elapsed;
		} else if (Drag != 0) {
			var d:Float = Drag*HxlGraphics.elapsed;
			if (Velocity - d > 0) {
				Velocity -= d;
			} else if (Velocity + d < 0) {
				Velocity += d;
			} else {
				Velocity = 0;
			}
		}
		if ((Velocity != 0) && (Max != 10000)) {
			if (Velocity > Max) {
				Velocity = Max;
			} else if (Velocity < -Max) {
				Velocity = -Max;
			}
		}
		return Velocity;
	}

	/**
	 * Rotates a point in 2D space around another point by the given angle.
	 * 
	 * @param	X		The X coordinate of the point you want to rotate.
	 * @param	Y		The Y coordinate of the point you want to rotate.
	 * @param	PivotX	The X coordinate of the point you want to rotate around.
	 * @param	PivotY	The Y coordinate of the point you want to rotate around.
	 * @param	Angle	Rotate the point by this many degrees.
	 * @param	P		Optional <code>HxlPoint</code> to store the results in.
	 * 
	 * @return	A <code>HxlPoint</code> containing the coordinates of the rotated point.
	 */
	public static function rotatePoint(X:Float, Y:Float, PivotX:Float, PivotY:Float, Angle:Float,?P:HxlPoint=null):HxlPoint {
		if (P == null) P = new HxlPoint();
		var radians:Float = -Angle / 180 * Math.PI;
		var dx:Float = X-PivotX;
		var dy:Float = PivotY-Y;
		P.x = PivotX + Math.cos(radians)*dx - Math.sin(radians)*dy;
		P.y = PivotY - (Math.sin(radians)*dx + Math.cos(radians)*dy);
		return P;
	}
	
	public static inline function distance(src:HxlPoint, dest:HxlPoint):Float {
		return Math.sqrt(Math.pow(src.x - dest.x, 2) + Math.pow(src.y - dest.y, 2));
	}
	
	public static function markFieldOfView(position:HxlPoint, radius:Float, map:HxlTilemap, ?radial:Bool=true) {
		var bottom = Std.int(Math.min(map.heightInTiles - 1, position.y + radius));
		var top = Std.int(Math.max(0, position.y - radius));
		var right = Std.int(Math.min(map.widthInTiles - 1, position.x + radius));
		var left = Std.int(Math.max(0, position.x - radius));
		
		var isBlocking = function(p:HxlPoint):Bool { 
			if ( p.x < 0 || p.y < 0 || p.x >= map.widthInTiles || p.y >= map.heightInTiles ) return true;
			return map.getTile(Math.round(p.x), Math.round(p.y)).isBlockingView();
		}
		var apply = function(p:HxlPoint):Void { 
			map.getTile(Math.round(p.x), Math.round(p.y)).visibility = Visibility.IN_SIGHT ; 
		}

		for (dx in left...right+1) {
			travrseLine(position, new HxlPoint(dx, top), isBlocking, apply, radial?radius:-1);
			travrseLine(position, new HxlPoint(dx, bottom), isBlocking, apply, radial?radius:-1);
		}
		for (dy in top...bottom+1) {
			travrseLine(position, new HxlPoint(left, dy), isBlocking, apply, radial?radius:-1);
			travrseLine(position, new HxlPoint(right, dy), isBlocking, apply, radial?radius:-1);
		}
	}
	
	public static function travrseLine(src:HxlPoint, dest:HxlPoint, ?isBlocking:HxlPoint->Bool=null, apply:HxlPoint->Void, ?maxDist:Float=-1) {
		for (pos in getLine(src, dest, isBlocking)) {
			if(maxDist<0 || distance(src,pos) <= maxDist)
				apply(pos);
		}
	}
	
	public static function getLine(src:HxlPoint, dest:HxlPoint, ?isBlocking:HxlPoint->Bool=null):Array<HxlPoint> {
		var line:Array<HxlPoint> = new Array();
		var steepness = (dest.x - src.x) / (dest.y - src.y);
		var x = src.x;
		var y = src.y;
		var pos:HxlPoint;
		if (Math.abs(steepness) < 1) {
			
			if(dest.y>y){
				while (y < dest.y + 1) {
					pos = new HxlPoint(x, y);
					line.push(pos);
					if (isBlocking(pos))
						break;
					x += steepness;
					y++;
				}
			} else {
				while (y > dest.y-1) {
					pos = new HxlPoint(x, y);
					line.push(pos);
					if (isBlocking(pos))
						break;
					x -= steepness;
					y--;
				}
			}
		} else {
			steepness = 1 / steepness;
			if(dest.x>x){
				while (x < dest.x + 1) {
					pos = new HxlPoint(x, y);
					line.push(pos);
					if (isBlocking(pos))
						break;
					y += steepness;
					x++;
				}
			} else {
				while (x > dest.x - 1) {
					pos = new HxlPoint(x, y);
					line.push(pos);
					if (isBlocking(pos))
						break;
					y -= steepness;
					x--;
				}
			}
		}
		return line;
	}
	
	public static function contains<T>(array:Array<T>, element:T):Bool {
		for (e in array)
			if (e == element)
				return true;
		return false;
	}
	
	public static function randomInt(max:Int):Int {
		return Math.floor(random() * max);
	}
	
	public static function randomIntInRange(min:Int, max:Int):Int {
		return Math.floor(random() * (max-min))+min;
	}
	
	public static function getRandomTile<T>(width:Int, height:Int, map:Array<Array<T>>, tileTypesToGet:Array<T>):HxlPoint {
		var x , y = 0;
		do {
			x = randomInt(width);
			y = randomInt(height);
		} while ( !contains(tileTypesToGet, map[y][x]) );
		
		return new HxlPoint(x,y);
	}
	
	public static function cloneMap<T>(map:Array<Array<T>>):Array<Array<T>> {
		var newMap = new Array<Array<T>>();
		for (y in 0...map.length) {
			newMap[y] = new Array<T>();
			for (x in 0...map[0].length)
				newMap[y][x] = map[y][x];
		}
		return newMap;
	}
	
	public static function copyMap<T>(srcMap:Array<Array<T>>, destMap:Array<Array<T>>) {
		for (y in 0...srcMap.length)
			for (x in 0...srcMap[0].length)
				destMap[y][x] = srcMap[y][x];
	}
	
	public static function getRandomElement<T>(arr:Array<T>):T {
		return arr[randomInt(arr.length)];
	}
	
	public static function countTiles(width:Int, height:Int, map:Array<Array<Int>>, tilesToCount:Array<Int>):Int {
		var n = 0;
		for (y in 1...height-1)
			for (x in 1...width-1)
				if (HxlUtil.contains(tilesToCount, map[y][x]))
					n++;
		
		return n;
	}
	
	public static function repalceAllTiles(width:Int, height:Int, map:Array<Array<Int>>, tileToReplace:Int, replacement:Int) {
		for (y in 1...height-1)
			for (x in 1...width-1)
				if (map[y][x] == tileToReplace)
					map[y][x] = replacement;
	}
}
