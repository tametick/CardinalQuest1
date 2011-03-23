package haxel;

import flash.events.MouseEvent;
import flash.media.Sound;

class HxlButton extends HxlGroup {
	public var on(getOn, setOn) : Bool;
	/**
	 * Used for checkbox-style behavior.
	 */
	var _onToggle:Bool;
	/**
	 * Stores the 'off' or normal button state graphic.
	 */
	var _off:HxlSprite;
	/**
	 * Stores the 'on' or highlighted button state graphic.
	 */
	var _on:HxlSprite;
	/**
	 * Stores the 'off' or normal button state label.
	 */
	var _offT:HxlText;
	/**
	 * Stores the 'on' or highlighted button state label.
	 */
	var _onT:HxlText;
	/**
	 * This function is called when the button is clicked.
	 */
	var _callback:Dynamic;
	/**
	 * Tracks whether or not the button is currently pressed.
	 */
	var _pressed:Bool;
	/**
	 * Whether or not the button has initialized itself yet.
	 */
	var _initialized:Bool;
	/**
	 * Helper variable for correcting its members' <code>scrollFactor</code> objects.
	 */
	var _sf:HxlPoint;

	// Sounds for various events
	var clickSound:HxlSound;
	
	/**
	 * Creates a new <code>HxlButton</code> object with a gray background
	 * and a callback function on the UI thread.
	 * 
	 * @param	X			The X position of the button.
	 * @param	Y			The Y position of the button.
	 * @param	Callback	The function to call whenever the button is clicked.
	 */
	public function new(X:Int,Y:Int,?Width:Int=100,?Height:Int=20,?Callback:Dynamic=null) {
		super();
		x = X;
		y = Y;
		width = Width;
		height = Height;
		_off = new HxlSprite().createGraphic(Math.floor(width),Math.floor(height),0xff7f7f7f);
		//_off.solid = false;
		add(_off,true);
		_on  = new HxlSprite().createGraphic(Math.floor(width),Math.floor(height),0xffffffff);
		//_on.solid = false;
		add(_on,true);
		_offT = null;
		_onT = null;
		_callback = Callback;
		_onToggle = false;
		_pressed = false;
		_initialized = false;
		_sf = null;
		clickSound = null;
	}

	public function setClickSound(ClickSound:Class<Sound>):HxlSound {
		if ( clickSound == null ) clickSound = new HxlSound();
		clickSound.loadEmbedded(ClickSound, false);
		return clickSound;
	}

	public function setCallback(?Callback:Dynamic=null) {
		_callback = Callback;
	}

	public function setBackgroundColor(ColorNormal:Int, ColorHover:Int, ?Width:Int=0, ?Height:Int=0):Void {
		if ( Width > 0 ) width = Width;
		if ( Height > 0 ) height = Height;
		remove(_on, true);
		remove(_off, true);
		_on = new HxlSprite().createGraphic(Math.floor(width), Math.floor(height), ColorHover);
		add(_on, true);
		_off = new HxlSprite().createGraphic(Math.floor(width), Math.floor(height), ColorNormal);
		add(_off, true);
	}

	/**
	 * Set your own image as the button background.
	 * 
	 * @param	Image				A HxlSprite object to use for the button background.
	 * @param	ImageHighlight		A HxlSprite object to use for the button background when highlighted (optional).
	 * 
	 * @return	This HxlButton instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadGraphic(Image:HxlSprite,?ImageHighlight:HxlSprite=null):HxlButton {
		Image.x = _off.x;
		Image.y = _off.y;
		trace("x: "+_off.x+", y: "+_off.y);
		//remove(_on, true);
		_off = cast( replace(_off,Image), HxlSprite);
		if (ImageHighlight == null) {
			if (_on != _off) {
				remove(_on);
			}
			_on = _off;
		} else {
			_on = cast( replace(_on,ImageHighlight), HxlSprite);
		}
		//_on.solid = _off.solid = false;
		_off.scrollFactor = scrollFactor;
		_on.scrollFactor = scrollFactor;
		width = _off.width;
		height = _off.height;
		//refreshHulls();
		_off.reset(_off.x, _off.y);
		_on.reset(_on.x, _on.y);
		return this;
	}

	/**
	 * Add a text label to the button.
	 * 
	 * @param	Text				A HxlText object to use to display text on this button (optional).
	 * @param	TextHighlight		A HxlText object that is used when the button is highlighted (optional).
	 * 
	 * @return	This HxlButton instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadText(Text:HxlText,?TextHighlight:HxlText=null):HxlButton {
		if (Text != null) {
			if (_offT == null) {
				_offT = Text;
				add(_offT);
			} else {
				_offT = cast( replace(_offT,Text), HxlText);
			}
		}
		if (TextHighlight == null) {
			_onT = _offT;
		} else {
			if (_onT == null) {
				_onT = TextHighlight;
				add(_onT);
			} else {
				_onT = cast( replace(_onT,TextHighlight), HxlText);
			}
		}
		_offT.scrollFactor = scrollFactor;
		_onT.scrollFactor = scrollFactor;
		return this;
	}

	/**
	 * Called by the game loop automatically, handles mouseover and click detection.
	 */
	public override function update():Void {
		if (!_initialized) {
			if (HxlGraphics.stage != null) {
				HxlGraphics.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				_initialized = true;
			}
		}
		
		super.update();

		visibility(false);
		if (overlapsPoint(HxlGraphics.mouse.x,HxlGraphics.mouse.y)) {
			if (!HxlGraphics.mouse.pressed()) {
				_pressed = false;
			} else if (!_pressed) {
				_pressed = true;
			}
			visibility(!_pressed);
		}
		if (_onToggle) visibility(_off.visible);
	}

	/**
	 * Use this to toggle checkbox-style behavior.
	 */
	public function getOn():Bool {
		return _onToggle;
	}
	
	/**
	 * @private
	 */
	public function setOn(On:Bool):Bool {
		_onToggle = On;
		return On;
	}

	/**
	 * Called by the game state when state is changed (if this object belongs to the state)
	 */
	public override function destroy():Void {
		if (HxlGraphics.stage != null) {
			HxlGraphics.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
	}
	
	/**
	 * Internal function for handling the visibility of the off and on graphics.
	 * 
	 * @param	On		Whether the button should be on or off.
	 */
	function visibility(On:Bool):Void {
		if (On) {
			_off.visible = false;
			if (_offT != null) _offT.visible = false;
			_on.visible = true;
			if (_onT != null) _onT.visible = true;
		} else {
			_on.visible = false;
			if (_onT != null) _onT.visible = false;
			_off.visible = true;
			if (_offT != null) _offT.visible = true;
		}
	}

	/**
	 * Internal function for handling the actual callback call (for UI thread dependent calls like <code>FlxU.openURL()</code>).
	 */
	function onMouseUp(event:MouseEvent):Void {
		if (!exists || !visible || !active || !HxlGraphics.mouse.justReleased() || (_callback == null)) return;
		if (overlapsPoint(HxlGraphics.mouse.x,HxlGraphics.mouse.y)) {
			_callback();
			if ( clickSound != null ) clickSound.play();
		}
	}

}
