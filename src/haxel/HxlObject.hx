package haxel;

import cq.ui.CqPopup;
import flash.geom.Point;


/**
 * Base class for which most display objects.
 **/
interface HxlObjectI {
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;
	public var scrollFactor:HxlPoint;
	
	public function onAdd(state:HxlState):Void;
	public function onRemove(state:HxlState):Void;
}
 
class HxlObject extends HxlRect, implements HxlObjectI {

	public var solid(getSolid, setSolid) : Bool;

	/**
	 * A point that can store numbers from 0 to 1 (for X and Y independently)
	 * that governs how much this object is affected by the camera subsystem.
	 * 0 means it never moves, like a HUD element or far background graphic.
	 * 1 means it scrolls along a the same speed as the foreground layer.
	 * scrollFactor is initialized as (1,1) by default.
	 */
	public var scrollFactor:HxlPoint;
	
	public var popup:CqPopup;
	/**
	 * WARNING: The origin of the sprite will default to its center.
	 * If you change this, the visuals and the collisions will likely be
	 * pretty out-of-sync if you do any rotation.
	 */
	public var origin:HxlPoint;

	/**
	 * Dedicated internal flag for whether or not this class is a HxlGroup.
	 */
	public var _group:Bool;

	/**
	 * Dedicated internal flag for whether or not this class is a HxlDialog.
	 */
	public var _dialog:Bool;


	/**
	 * If an object is not visible, the game loop will not automatically call <code>render()</code> on it.
	 */
	public var visible:Bool;

	/**
	 * If true, object is not affected by autoVisible.
	 */
	public var alwaysVisible:Bool;
	
	/**
	 * If an object is not alive, the game loop will not automatically call <code>update()</code> on it.
	 */
	public var active:Bool;

	/**
	 * Kind of a global on/off switch for any objects descended from <code>FlxObject</code>.
	 */
	public var exists:Bool;
	/**
	 * Internal tracker for whether or not the object collides (see <code>solid</code>).
	 */
	var _solid:Bool;

	/**
	 * Handy for tracking gameplay or animations.
	 */
	public var dead:Bool;

	/**
	 * The basic speed of this object.
	 */
	public var velocity:HxlPoint;
	/**
	 * How fast the speed of this object is changing.
	 * Useful for smooth movement and gravity.
	 */
	public var acceleration:HxlPoint;
	/**
	 * This isn't drag exactly, more like deceleration that is only applied
	 * when acceleration is not affecting the sprite.
	 */
	public var drag:HxlPoint;
	/**
	 * If you are using <code>acceleration</code>, you can use <code>maxVelocity</code> with it
	 * to cap the speed automatically (very useful!).
	 */
	public var maxVelocity:HxlPoint;

	/**
	 * Set the angle of a sprite to rotate it.
	 * WARNING: rotating sprites decreases rendering
	 * performance for this sprite by a factor of 10x!
	 */
	public var angle:Float;

	/**
	 * This is how fast you want this sprite to spin.
	 */
	public var angularVelocity:Float;
	/**
	 * How fast the spin speed should change.
	 */
	public var angularAcceleration:Float;
	/**
	 * Like <code>drag</code> but for spinning.
	 */
	public var angularDrag:Float;
	/**
	 * Use in conjunction with <code>angularAcceleration</code> for fluid spin speed control.
	 */
	public var maxAngular:Float;

	/**
	 * If you want to do Asteroids style stuff, check out thrust,
	 * instead of directly accessing the object's velocity or acceleration.
	 */
	public var thrust:Float;
	/**
	 * Used to cap <code>thrust</code>, helpful and easy!
	 */
	public var maxThrust:Float;
	/**
	 * A handy "empty point" object
	 */
	static var _pZero:HxlPoint = new HxlPoint();

	/**
	 * Flag for whether the bounding box visuals need to be refreshed.
	 */
	public static var _refreshBounds:Bool;

	/**
	 * This is a pre-allocated Flash Point object, which is useful for certain Flash graphics API calls
	 */
	var _flashPoint:Point;

	/**
	 * The z-index of this object. Objects are rendered in order of z-index, lowest to highest.
	 **/
	public var zIndex:Int;

	var _point:HxlPoint;

	/**
	 * Set this to false if you want to skip the automatic motion/movement stuff (see <code>updateMotion()</code>).
	 * FlxObject and FlxSprite default to true.
	 * FlxText, FlxTileblock, FlxTilemap and FlxSound default to false.
	 */
	public var moves:Bool;

	/**
	 * An array of objects which represent event listeners assigned to this HxlObject.
	 **/
	var eventListeners:Array<Dynamic>;

	var mountObject:HxlObject;
	var mountOffsetX:Float;
	var mountOffsetY:Float;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=0, ?Height:Float=0) {
		super(X, Y, Width, Height);
		scrollFactor = new HxlPoint(1,1);
		exists = true;
		active = true;
		visible = true;
		alwaysVisible = false;
		_solid = true;
		moves = true;

		velocity = new HxlPoint();
		acceleration = new HxlPoint();
		drag = new HxlPoint();
		maxVelocity = new HxlPoint(10000,10000);
		
		angle = 0;
		angularVelocity = 0;
		angularAcceleration = 0;
		angularDrag = 0;
		maxAngular = 10000;
		
		thrust = 0;

		_point = new HxlPoint();
		origin = new HxlPoint();
		_flashPoint = new Point();
		_group = false;
		_dialog = false;

		zIndex = 0;
		eventListeners = new Array();

		mountObject = null;
		mountOffsetX = 0;
		mountOffsetY = 0;
		
		_mp = new HxlPoint();
	}

	/**
	 * Call this function to figure out the on-screen position of the object.
	 * 
	 * @param	P	Takes a <code>Pt</code> object and assigns the post-scrolled X and Y values of this object to it.
	 * 
	 * @return	The <code>Pt</code> you passed in, or a new <code>Pt</code> if you didn't pass one, containing the screen X and Y position of this object.
	 */
	public function getScreenXY(?Pt:HxlPoint=null):HxlPoint {
		if (Pt == null) Pt = new HxlPoint();
		if ( scrollFactor == null ) {	
			var scrollFactor = new HxlPoint(1,1);
		}
		if (HxlGraphics.scroll == null ) {
			HxlGraphics.scroll = new Point(0,0);
		}

		Pt.x = HxlUtil.floor(x + HxlUtil.roundingError)+HxlUtil.floor(HxlGraphics.scroll.x*scrollFactor.x);
		Pt.y = HxlUtil.floor(y + HxlUtil.roundingError)+HxlUtil.floor(HxlGraphics.scroll.y*scrollFactor.y);
		return Pt;
	}

	/**
	 * Check and see if this object is currently on screen.
	 * 
	 * @return	Whether the object is on screen or not.
	 */
	public function onScreen():Bool
	{
		if (_point == null)
			return false;
		
		getScreenXY(_point);
		if ((_point.x + width < 0) || (_point.x > HxlGraphics.width) || (_point.y + height < 0) || (_point.y > HxlGraphics.height)) {
			return false;
		} else {
			return true;
		}
	}

	/**
	 * override these function if you want to do something after the object is added or removed
	 */
	public function onAdd(state:HxlState) {}
	public function onRemove(state:HxlState) {
		clearEventListeners();
	}
	
	/**
	 * Call this function to "kill" a sprite so that it no longer 'exists'.
	 */
	public function kill() {
		exists = false;
		dead = true;
		
		if (popup != null)
			popup.onRemove(HxlGraphics.state);
		popup = null;
		
		HxlGraphics.state.remove(this);
		clearEventListeners();
	}

	/**
	 * Handy function for reviving game objects.
	 * Resets their existence flags and position, including LAST position.
	 * 
	 * @param	X	The new X position of this object.
	 * @param	Y	The new Y position of this object.
	 */
	public function reset(X:Float,Y:Float) {
		x = X;
		y = Y;
		exists = true;
		dead = false;
	}

	/**
	 * Called by <code>FlxGroup</code>, commonly when game states are changed.
	 */
	public function destroy() {
		dead = true;
		active = false;
		exists = false;
		
		if (popup != null){
			popup.onRemove(HxlGraphics.state);
			popup.destroy();
			popup = null;
		}
		clearEventListeners();

		scrollFactor = null;
		acceleration = null;
		drag = null;
		maxVelocity = null;
		origin = null;
		velocity = null;
		_point = null;
		mountObject = null;
	}

	/**
	 * Set <code>solid</code> to true if you want to collide this object.
	 */
	public function getSolid():Bool {
		return _solid;
	}
	
	/**
	 * @private
	 */
	public function setSolid(Solid:Bool):Bool {
		_solid = Solid;
		return Solid;
	}

	/**
	 * Internal function for updating the position and speed of this object.
	 * Useful for cases when you need to update this but are buried down in too many supers.
	 */
	function updateMotion() {
		if (!moves) {
			return;
		}
		
		/*
		if (_solid) {
			refreshHulls();
		}
		onFloor = false;
		*/
		var vc:Float;

		vc = (HxlUtil.computeVelocity(angularVelocity,Math.floor(angularAcceleration),Math.floor(angularDrag),Math.floor(maxAngular)) - angularVelocity)/2;
		angularVelocity += vc; 
		angle += angularVelocity*HxlGraphics.elapsed;
		angularVelocity += vc;
		
		var thrustComponents:HxlPoint;
		if (thrust != 0) {
			thrustComponents = HxlUtil.rotatePoint(-thrust,0,0,0,angle);
			var maxComponents:HxlPoint = HxlUtil.rotatePoint(-maxThrust,0,0,0,angle);
			var max:Float = ((maxComponents.x>0)?maxComponents.x:-maxComponents.x);
			if (max > ((maxComponents.y>0)?maxComponents.y:-maxComponents.y)) {
				maxComponents.y = max;
			} else {
				max = Math.floor(((maxComponents.y>0)?maxComponents.y:-maxComponents.y));
			}
			maxVelocity.x = maxVelocity.y = ((max>0)?max:-max);
		} else {
			thrustComponents = _pZero;
		}
		
		vc = (HxlUtil.computeVelocity(velocity.x,acceleration.x+thrustComponents.x,drag.x,maxVelocity.x) - velocity.x)/2;
		velocity.x += vc;
		var xd:Float = velocity.x*HxlGraphics.elapsed;
		velocity.x += vc;
		vc = (HxlUtil.computeVelocity(velocity.y,Math.floor(acceleration.y+thrustComponents.y),Math.floor(drag.y),Math.floor(maxVelocity.y)) - velocity.y)/2;
		velocity.y += vc;
		var yd:Float = velocity.y*HxlGraphics.elapsed;
		velocity.y += vc;
		
		x += xd;
		y += yd;
		
		//Update collision data with new movement results
		/*
		if (!_solid)
			return;
		colVector.x = xd;
		colVector.y = yd;
		colHullX.width += ((colVector.x>0)?colVector.x:-colVector.x);
		if(colVector.x < 0)
			colHullX.x += colVector.x;
		colHullY.x = x;
		colHullY.height += ((colVector.y>0)?colVector.y:-colVector.y);
		if(colVector.y < 0)
			colHullY.y += colVector.y;
		*/
	}

	/**
	 * Called by the main game loop, handles motion/physics and game logic
	 */
	var _mp:HxlPoint;
	public function update() {
		updateMotion();
		//updateFlickering();
		if ( mountObject != null ) {
			x = mountObject.x + mountOffsetX;
			y = mountObject.y + mountOffsetY;
		}
		if ( popup != null)
		{
			var m:HxlMouse = HxlGraphics.mouse;
			if ( (overlapsPoint(m.x, m.y) || !popup.mouseBound) && visible)	{
				popup.visible = true;
				if(popup.mouseBound){
					_mp.x = m.screenX; 
					_mp.y = m.screenY;
					popup.x = _mp.x-20;
					popup.y = _mp.y + 20;
				} else {
					popup.x = (HxlGraphics.stage.stageWidth - popup.width)/2;
					popup.y = (HxlGraphics.stage.stageHeight - popup.height)/2;
				}
				if ( popup.x + popup.width > HxlGraphics.stage.stageWidth)	{
					popup.x = HxlGraphics.stage.stageWidth - popup.width;
				} else if (popup.x < 5)
					popup.x = 5;
				if ( popup.y + popup.height > HxlGraphics.stage.stageHeight){
					popup.y = HxlGraphics.stage.stageHeight - popup.height;
				} else if (popup.y < 5)
					popup.y = 5;
			}else {
				popup.visible = false;
			}
		}
	}
	
	public function clearPopup() {
		popup = null;
	}
	
	public function setPopup(Popup:CqPopup)	{
		popup = Popup;
		popup.visible = false;
	}
	
	public function getPopup() {
		return popup;
	}
	
	/**
	 * Override this function to draw graphics (see <code>HxlSprite</code>).
	 */
	public function render() {
		//Objects don't have any visual logic/display of their own.
	}

	/**
	 * Returns the appropriate color for the bounding box depending on object state.
	 */
	public function getBoundingColor():Int {
		if (solid) {
			//if (fixed) {
				return 0x7f00f225;
			//else
			//	return 0x7fff0012;
		}
		else return 0x7fff0112;
	}

	/**
	 * Checks to see if a point in 2D space overlaps this <code>HxlObject</code> object.
	 * 
	 * @param	X			The X coordinate of the point.
	 * @param	Y			The Y coordinate of the point.
	 * @param	PerPixel	Whether or not to use per pixel collision checking (only available in <code>HxlSprite</code> subclass).
	 * 
	 * @return	Whether or not the point overlaps this object.
	 */
	public function overlapsPoint(X:Float,Y:Float,?PerPixel:Bool = false):Bool {
		X += HxlUtil.floor(HxlGraphics.scroll.x);
		Y += HxlUtil.floor(HxlGraphics.scroll.y);
		getScreenXY(_point);
		if ((X <= _point.x) || (X >= _point.x+width) || (Y <= _point.y) || (Y >= _point.y+height)) {
			return false;
		}
		return true;
	}
	
	function addEventListener(Type:String, Listener:Dynamic, UseCapture:Bool=false, Priority:Int=0, UseWeakReference:Bool=true) { 
		HxlGraphics.stage.addEventListener(Type, Listener, UseCapture, Priority, UseWeakReference);
		eventListeners.push( {Type: Type, Listener: Listener, UseCapture: UseCapture, Priority: Priority} );
	}

	function removeEventListener(Type:String, Listener:Dynamic) {
		HxlGraphics.stage.removeEventListener(Type, Listener);
		for ( i in 0...eventListeners.length ) {
			var ev:Dynamic = eventListeners[i];
			if ( ev.Type == Type && ev.Listener == Listener ) {
				eventListeners.splice(i, 1);
				break;
			}
		}
	}

	function clearEventListeners() {
		while ( eventListeners.length > 0 ) {
			var i:Dynamic = eventListeners.pop();
			HxlGraphics.stage.removeEventListener(i.Type, i.Listener);
			i = null;
		}
	}

	public function pauseEventListeners() {
		for ( i in eventListeners ) {
			HxlGraphics.stage.removeEventListener(i.Type, i.Listener);
		}
	}

	public function resumeEventListeners() {
		if ( HxlGraphics.stage == null ) return;
		for ( i in eventListeners ) {
			HxlGraphics.stage.addEventListener(i.Type, i.Listener, i.UseCapture, i.Priority, true);
		}
	}

	/**
	 * Mounts this HxlObject to another HxlObject, causing it to follow the target object's movement.
	 * Uses the current position relative to the target object as the offset.
	 **/
	public function mount(Other:HxlObject) {
		mountObject = Other;
		mountOffsetX = x - Other.x;
		mountOffsetY = y - Other.y;
	}

	/**
	 * Unmounts from the currently mounted HxlObject.
	 **/
	public function unmount() {
		mountObject = null;
	}
}
