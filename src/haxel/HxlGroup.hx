package haxel;

class HxlGroup extends HxlObject {

	public var members:Array<Dynamic>;

	var _last:HxlPoint;
	var _first:Bool;

	public function new() {
		super();
		_group = true;
		members = new Array<HxlObject>();
		_last = new HxlPoint();
		_first = true;
	}

	/**
	 * Adds a new <code>HxlObject</code> subclass (HxlSprite, HxlBlock, etc) to the list of children
	 *
	 * @param	Object			The object you want to add
	 * @param	ShareScroll		Whether or not this HxlCore should sync up with this layer's scrollFactor
	 *
	 * @return	The same <code>HxlCore</code> object that was passed in.
	 */
	public function add(Object:HxlObject,?ShareScroll:Bool=false):HxlObject {
		members.push(Object);
		if(ShareScroll) {
			Object.scrollFactor = scrollFactor;
		}
		if ( HxlGraphics.autoZSort ) sortMembersByZIndex();
		return Object;
	}

	/**
	 * Replaces an existing <code>HxlObject</code> with a new one.
	 * 
	 * @param	OldObject	The object you want to replace.
	 * @param	NewObject	The new object you want to use instead.
	 * 
	 * @return	The new object.
	 */
	public function replace(OldObject:HxlObject,NewObject:HxlObject):HxlObject {
		var index:Int = -1;
		for (i in 0 ... members.length) {
			if (members[i] == OldObject) {
				index = i;
				break;
			}
		}
		if ((index < 0) || (index >= members.length)) {
			return null;
		}
		members[index] = NewObject;
		if ( HxlGraphics.autoZSort ) sortMembersByZIndex();
		return NewObject;
	}

	/**
	 * Removes an object from the group.
	 * 
	 * @param	Object	The <code>HxlObject</code> you want to remove.
	 * @param	Splice	Whether the object should be cut from the array entirely or not.
	 * 
	 * @return	The removed object.
	 */
	public function remove(Object:HxlObject,?Splice:Bool=true):HxlObject {
		var index:Int = -1;
		for (i in 0 ... members.length) {
			if (members[i] == Object) {
				index = i;
				break;
			}
		}
		if ((index < 0) || (index >= members.length)) {
			return null;
		}
		if (Splice) {
			members.splice(index,1);
		} else {
			members[index] = null;
		}
		if ( HxlGraphics.autoZSort ) sortMembersByZIndex();
		return Object;
	}

	/**
	 * Call this function to retrieve the first object with exists == false in the group.
	 * This is handy for recycling in general, e.g. respawning enemies.
	 * 
	 * @return	A <code>HxlObject</code> currently flagged as not existing.
	 */
	public function getFirstAvail():HxlObject {
		var o:HxlObject;
		var ml:Int = members.length;
		for (i in 0...ml) {
			o = cast( members[i], HxlObject);
			if ((o != null) && !o.exists) {
				return o;
			}
		}
		return null;
	}

	/**
	 * Call this function to retrieve the first index set to 'null'.
	 * Returns -1 if no index stores a null object.
	 * 
	 * @return	An <code>int</code> indicating the first null slot in the group.
	 */
	public function getFirstNull():Int {
		var ml:Int = members.length;
		for (i in 0...ml) {
			if (members[i] == null) {
				return i;
			}
		}
		return -1;
	}

	/**
	 * If the group's position is reset, we want to reset all its members too.
	 * 
	 * @param	X	The new X position of this object.
	 * @param	Y	The new Y position of this object.
	 */
	public override function reset(X:Float,Y:Float):Void
	{
		saveOldPosition();
		super.reset(X,Y);
		var mx:Float = Math.NaN;
		var my:Float = Math.NaN;
		var moved:Bool = false;
		if((x != _last.x) || (y != _last.y))
		{
			moved = true;
			mx = x - _last.x;
			my = y - _last.y;
		}
		var o:HxlObject;
		var l:Int = members.length;
		for(i in 0...l)	{
			o = cast( members[i], HxlObject);
			if ((o != null) && o.exists) {
				if (moved) {
					if (o._group) {
						o.reset(o.x+mx,o.y+my);
					} else {
						o.x += mx;
						o.y += my;
						/*
						if(solid)
						{
							o.colHullX.width += ((mx>0)?mx:-mx);
							if(mx < 0)
								o.colHullX.x += mx;
							o.colHullY.x = x;
							o.colHullY.height += ((my>0)?my:-my);
							if(my < 0)
								o.colHullY.y += my;
							o.colVector.x += mx;
							o.colVector.y += my;
						}
						*/
					}
				}
			}
		}
	}

	/**
	 * Finds the first object with exists == false and calls reset on it.
	 * 
	 * @param	X	The new X position of this object.
	 * @param	Y	The new Y position of this object.
	 * 
	 * @return	Whether a suitable <code>HxlObject</code> was found and reset.
	 */
	public function resetFirstAvail(?X:Int=0, ?Y:Int=0):Bool {
		var o:HxlObject = getFirstAvail();
		if(o == null) {
			return false;
		}
		o.reset(X,Y);
		return true;
	}

	/**
	 * Call this function to retrieve the first object with exists == true in the group.
	 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
	 * 
	 * @return	A <code>HxlObject</code> currently flagged as existing.
	 */
	public function getFirstExtant():HxlObject {
		var o:HxlObject;
		var ml:Int = members.length;
		for (i in 0...ml) {
			o = cast( members[i], HxlObject);
			if ((o != null) && o.exists) {
				return o;
			}
		}
		return null;
	}
	
	/**
	 * Call this function to retrieve the first object with dead == false in the group.
	 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
	 * 
	 * @return	A <code>HxlObject</code> currently flagged as not dead.
	 */
	public function getFirstAlive():HxlObject {
		var o:HxlObject;
		var ml:Int = members.length;
		for (i in 0...ml) {
			o = cast( members[i], HxlObject);
			if ((o != null) && o.exists && !o.dead) {
				return o;
			}
		}
		return null;
	}
	
	/**
	 * Call this function to retrieve the first object with dead == true in the group.
	 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
	 * 
	 * @return	A <code>HxlObject</code> currently flagged as dead.
	 */
	public function getFirstDead():HxlObject {
		var o:HxlObject;
		var ml:Int = members.length;
		for (i in 0...ml) {
			o = cast( members[i], HxlObject);
			if ((o != null) && o.dead) {
				return o;
			}
		}
		return null;
	}
	
	/**
	 * Call this function to find out how many members of the group are not dead.
	 * 
	 * @return	The number of <code>HxlObject</code>s flagged as not dead.  Returns -1 if group is empty.
	 */
	public function countLiving():Int {
		var o:HxlObject;
		var count:Int = -1;
		var ml:Int = members.length;
		for (i in 0...ml) {
			o = cast( members[i], HxlObject);
			if (o != null) {
				if (count < 0) {
					count = 0;
				}
				if (o.exists && !o.dead) {
					count++;
				}
			}
		}
		return count;
	}
	
	/**
	 * Call this function to find out how many members of the group are dead.
	 * 
	 * @return	The number of <code>HxlObject</code>s flagged as dead.  Returns -1 if group is empty.
	 */
	public function countDead():Int {
		var o:HxlObject;
		var count:Int = -1;
		var ml:Int = members.length;
		for (i in 0...ml) {
			o = cast( members[i], HxlObject);
			if (o != null) {
				if(count < 0) {
					count = 0;
				}
				if (o.dead) {
					count++;
				}
			}
		}
		return count;
	}
	
	/**
	 * Returns a count of how many objects in this group are on-screen right now.
	 * 
	 * @return	The number of <code>HxlObject</code>s that are on screen.  Returns -1 if group is empty.
	 */
	public function countOnScreen():Int {
		var o:HxlObject;
		var count:Int = -1;
		var ml:Int = members.length;
		for (i in 0...ml) {
			o = cast( members[i], HxlObject);
			if (o != null) {
				if (count < 0) {
					count = 0;
				}
				if (o.onScreen()) {
					count++;
				}
			}
		}
		return count;
	}		

	/**
	 * Returns a count of how many objects in this group have visible set to true.
	 *
	 * @return Int
	 */
	public function countVisible():Int {
		var o:HxlObject;
		var count:Int = -1;
		var ml:Int = members.length;
		for (i in 0...ml) {
			o = cast( members[i], HxlObject);
			if (o != null) {
				if (count < 0) {
					count = 0;
				}
				if (o.visible) {
					count++;
				}
			}
		}
		return count;

	}

	/**
	 * Returns a member at random from the group.
	 * 
	 * @return	A <code>HxlObject</code> from the members list.
	 */
	public function getRandom():HxlObject {
		var c:Int = 0;
		var o:HxlObject = null;
		var l:Int = members.length;
		var i:Int = Math.floor(HxlUtil.random()*l);
		while ((o == null) && (c < members.length)) {
			o = cast(members[Math.floor((++i)%l)], HxlObject);
			c++;
		}
		return o;
	}
	
	/**
	 * Internal function, helps with the moving/updating of group members.
	 */
	function saveOldPosition():Void {
		if (_first) {
			_first = false;
			_last.x = 0;
			_last.y = 0;
			return;
		}
		_last.x = x;
		_last.y = y;
	}

	/**
	 * Internal function that actually goes through and updates all the group members.
	 * Depends on <code>saveOldPosition()</code> to set up the correct values in <code>_last</code> in order to work properly.
	 */
	function updateMembers():Void {
		var mx:Float = Math.NaN;
		var my:Float = Math.NaN;
		var moved:Bool = false;
		if ((x != _last.x) || (y != _last.y)) {
			moved = true;
			mx = x - _last.x;
			my = y - _last.y;
		}
		var o:HxlObject;
		var l:Int = members.length;
		for (i in 0...l) {
			o = cast( members[i], HxlObject);
			if ((o != null) && o.exists) {
				if (moved) {
					if (o._group) {
						o.reset(o.x+mx,o.y+my);
					} else {
						o.x += mx;
						o.y += my;
					}
				}
				if (o.active) {
					o.update();
					HxlGraphics.numUpdates++;
				}
				/*
				if (moved && o.solid) {
					o.colHullX.width += ((mx>0)?mx:-mx);
					if ( mx < 0) {
						o.colHullX.x += mx;
					}
					o.colHullY.x = x;
					o.colHullY.height += ((my>0)?my:-my);
					if (my < 0) {
						o.colHullY.y += my;
					}
					o.colVector.x += mx;
					o.colVector.y += my;
				}
				*/
			}
		}
	}
	/**
	 * Automatically goes through and calls update on everything you added,
	 * override this function to handle custom input and perform collisions.
	 */
	public override function update():Void {
		saveOldPosition();
		updateMotion();
		updateMembers();
		//updateFlickering();
	}

	/**
	 * Internal function that actually loops through and renders all the group members.
	 */
	function renderMembers():Void {
		var o:HxlObject;
		var l:Int = members.length;
		for (i in 0...l) {
			o = cast( members[i], HxlObject);
			if ((o != null) && o.exists && o.visible) {
				if ( !HxlGraphics.autoVisible || o.alwaysVisible || o.onScreen() ) {
					o.render();
					HxlGraphics.numRenders++;
				}
			}
		}
	}

	/**
	 * Internal function that actually loops through and destroys each member.
	 */
	function destroyMembers():Void {
		//trace("destroyMembers called!");
		var o:HxlObject;
		var l:Int = members.length;
		for (i in 0...l) {
			o = cast( members[i], HxlObject);
			if (o != null) {
				o.destroy();
			}
		}
		members = new Array();
	}
	
	/**
	 * Override this function to handle any deleting or "shutdown" type operations you might need,
	 * such as removing traditional Flash children like Sprite objects.
	 */
	public override function destroy():Void {
		destroyMembers();
		super.destroy();
	}

	/**
	 * Automatically goes through and calls render on everything you added,
	 * override this loop to control render order manually.
	 */
	public override function render():Void {
		renderMembers();
	}

	/**
	 * Internal function that calls kill on all members.
	 */
	function killMembers():Void {
		var o:HxlObject;
		var l:Int = members.length;
		for (i in 0...l) {
			o = cast( members[i], HxlObject);
			if (o != null) {
				o.kill();
			}
		}
	}
	
	/**
	 * Calls kill on the group and all its members.
	 */
	public override function kill():Void {
		killMembers();
		super.kill();
	}

	/**
	 * Sorting function for zIndex.
	 **/
	public static function zIndexSort(obj1:HxlObject, obj2:HxlObject):Int {
		if ( obj1 == null ) return -1;
		if ( obj2 == null ) return 1;
		if ( obj1.zIndex > obj2.zIndex ) return 1;
		else if ( obj1.zIndex < obj2.zIndex ) return -1;
		return 0;
	}

	public function sortMembersByZIndex():Void {
		if ( members.length == 0 ) return;
		members.sort(zIndexSort);
	}
}
