package haxel;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.events.KeyboardEvent;
import flash.ui.Mouse;

import haxel.HxlObject;
import data.Registery;
import data.Configuration;

import cq.GameUI;

class HxlState extends Sprite {
	public static var musicOn:Bool;
	public static var sfxOn:Bool;
	public static var screen:HxlSprite;
	public static var bgColor:Int;
	public var defaultGroup:HxlGroup;

	public var stackId:Int;
	public var stackRender:Bool;
	public var stackBlockRender:Bool;
	var _isStacked:Bool;
	public var isStacked(getIsStacked, setIsStacked):Bool;
	var eventListeners:Array<Dynamic>;
	var _followTarget:HxlObjectI;
	var _followLead:Point;
	var _followLerp:Float;
	var _followMin:Point;
	var _followMax:Point;
	var _scroll:Point;

	//For mobile only, public because HxlGraphics needs access to it
	public var touchX:Int;
	public var touchY:Int;

	public var destroyed:Bool;

	//var keyboard:HxlKeyboard;
	var initialized:Int;
	//var loadingBox:LoadingBox;

	var cursor(getCursor, setCursor):HxlSprite;

	static var _cursor:HxlSprite;
	function getCursor() { return _cursor; }
	function setCursor(c:HxlSprite) { return _cursor=c; }

	public function new() {
		super();
		stackId = 0;
		stackRender = true;
		stackBlockRender = false;
		isStacked = false;
	}

	public function create() {
		destroyed = false;
		if(defaultGroup ==null)
			defaultGroup = new HxlGroup();
		else
			throw "defaultGroup should be null!";

		if(eventListeners == null)
			eventListeners = new Array();
		else
			throw "eventListeners should be null!";

		if ( screen == null ) {
			screen = new HxlSprite();
			screen.createGraphic(HxlGraphics.width, HxlGraphics.height, 0, true);
			screen.origin.x = screen.origin.y = 0;
			screen.antialiasing = true;
			screen.exists = false;
			//screen.solid = false;
			//screen.fixed = true;
		}


		if(cursor!=null){
			Mouse.hide();
			cursor.zIndex = 100;
			add(cursor);
		}

		initialized = -1;
	}

	public function add(obj:HxlObjectI):HxlObjectI {
		defaultGroup.add(obj);
		obj.onAdd(this);
		return obj;
	}

	public function remove(obj:HxlObjectI):HxlObjectI {
		obj.onRemove(this);
		if (defaultGroup == null)
			return null;
		else
			return defaultGroup.remove(obj);
	}

	public function preProcess() {
		screen.fill(bgColor);
		HxlGraphics.numRenders = 0;
	}

	public function render() {
		if ( _isStacked ) {
			var oldScroll:Point = HxlGraphics.scroll;
			HxlGraphics.scroll = _scroll;
			defaultGroup.render();
			HxlGraphics.scroll = oldScroll;
		} else {
			defaultGroup.render();
		}
	}

	public function postProcess() {
	}

	public function update() {
		if(defaultGroup!=null)
			defaultGroup.update();

		if(cursor!=null) {
			cursor.x = HxlGraphics.mouse.screenX;
			cursor.y = HxlGraphics.mouse.screenY;
		}

		if ( initialized == -1 ) {
//			loadingBox.visible = true;
			initialized = 0;
		} else if ( initialized == 0 ){
			//HxlGraphics.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			//HxlGraphics.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			if ( eventListeners.length > 0 ) {
				resumeEventListeners();
			} else {
				_addEventListener(KeyboardEvent.KEY_UP, onKeyUp,false,0,true);
				_addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
				_addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown,false,0,true);
				_addEventListener(MouseEvent.MOUSE_UP, onMouseUp,false,0,true);
				_addEventListener(MouseEvent.MOUSE_OVER, onMouseOver,false,0,true);
				_addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
				if ( Configuration.mobile ) {
					_addEventListener(TouchEvent.TOUCH_TAP , onTap,false,0,true);
				}
//				if(Configuration.air) {
//					_addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown, false, 0, true);
//				}
			}
			init();
			initialized = 1;
//			loadingBox.visible = false;
		} else {

		}
	}

	public function destroy() {
		destroyed = true;
		clearEventListeners();
		defaultGroup.destroy();
		defaultGroup = null;

		// defualt values
		stackId = 0;
		stackRender = true;
		stackBlockRender = false;
		isStacked = false;
	}

	function init() { }
	function onKeyUp(event:KeyboardEvent) { }
	function onKeyDown(event:KeyboardEvent) {
		//No escape key on mobile
		#if flash
			if (event.charCode == 27) {
				event.preventDefault();
			}
		#end
	}
	
	// a silly multiplication of different handlers -- purely historical
	function onTap(event: TouchEvent){ updateTouchLocation(event.localX, event.localY);  }
	function onMouseDown(event:MouseEvent) { updateTouchLocation(event.localX, event.localY); }
	function onRightMouseDown(event:MouseEvent) {
		//No right clicking on mobile
		#if flash
			event.preventDefault();
			Mouse.hide();
		#end
		updateTouchLocation(event.localX, event.localY);
	}
	function onMouseUp(event:MouseEvent) { updateTouchLocation(event.localX, event.localY); }
	function onMouseOver(event:MouseEvent) { updateTouchLocation(event.localX, event.localY); }
	function onMouseMove(event:MouseEvent) { updateTouchLocation(event.localX, event.localY); }
	
	function updateTouchLocation(x:Float, y:Float) {
		if (Configuration.mobile && x < 6000 && y < 6000) {
			touchX = Std.int(x);
			touchY = Std.int(y);
			
			// I need this logic to work, though:
			// mouseX = touchX;
			// mouseY = touchY;
		}
	}

	public function getIsStacked():Bool {
		return _isStacked;
	}

	public function setIsStacked(Toggle:Bool):Bool {
		_isStacked = Toggle;

		if (eventListeners == null || defaultGroup == null)
			return _isStacked;

		if ( initialized > 0 ) {
			if ( _isStacked ) {
				pauseEventListeners();
				defaultGroup.pauseEventListeners();
				_followTarget = HxlGraphics.followTarget;
				_followLead = HxlGraphics.followLead;
				_followLerp = HxlGraphics.followLerp;
				_followMin = HxlGraphics.followMin;
				_followMax = HxlGraphics.followMax;
				_scroll = new Point(HxlGraphics.scroll.x,HxlGraphics.scroll.y);
			} else {
				resumeEventListeners();
				defaultGroup.resumeEventListeners();
				if ( _followTarget != null ) {
					HxlGraphics.follow(_followTarget, _followLerp);
				}
				HxlGraphics.followLead = _followLead;
				if ( _followMin != null && _followMax != null ) {
					HxlGraphics.followMin = _followMin;
					HxlGraphics.followMax = _followMax;
					HxlGraphics.doFollow();
				}
			}
		}
		return _isStacked;
	}

	function _addEventListener(Type:String, Listener:Dynamic, UseCapture:Bool=false, Priority:Int=0, UseWeakReference:Bool=true) {
		HxlGraphics.stage.addEventListener(Type, Listener, UseCapture, Priority, UseWeakReference);
		eventListeners.push( {Type: Type, Listener: Listener, UseCapture: UseCapture} );
	}

	function clearEventListeners() {
		var i:Dynamic;
		while ( eventListeners.length > 0 ) {
			i  = eventListeners.pop();
			HxlGraphics.stage.removeEventListener(i.Type, i.Listener);
			i = null;
		}
		eventListeners = null;
	}

	function pauseEventListeners() {
		for ( i in eventListeners ) {
			HxlGraphics.stage.removeEventListener(i.Type, i.Listener);
		}
	}

	function resumeEventListeners() {
		if ( HxlGraphics.stage == null )
			return;
		for ( i in eventListeners ) {
			HxlGraphics.stage.addEventListener(i.Type, i.Listener, i.UseCapture,0,true);
		}
	}

}
