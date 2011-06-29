package haxel;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.events.KeyboardEvent;

import haxel.HxlObject;
import data.Registery;

class HxlState extends Sprite {

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

	var keyboard:HxlKeyboard;
	var initialized:Int;
	//var loadingBox:LoadingBox;
	
	public function new() {

		super();
		defaultGroup = new HxlGroup();
		stackId = 0;
		stackRender = true;
		stackBlockRender = false;
		isStacked = false;
		eventListeners = new Array();
		if ( screen == null ) {
			screen = new HxlSprite();
			screen.createGraphic(HxlGraphics.width, HxlGraphics.height, 0, true);
			screen.origin.x = screen.origin.y = 0;
			screen.antialiasing = true;
			screen.exists = false;
			//screen.solid = false;
			//screen.fixed = true;
			keyboard = new HxlKeyboard();
		}
	}

	public function create() {
		initialized = -1;
	}
	
	public function add(obj:HxlObjectI):HxlObjectI {
		defaultGroup.add(obj);
		obj.onAdd(this);
		return obj;
	}
	
	public function remove(obj:HxlObjectI):HxlObjectI {
		obj.onRemove(this);
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
		defaultGroup.update();
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
				_addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown,false,0,true);
				_addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown,false,0,true);
				_addEventListener(MouseEvent.MOUSE_UP, onMouseUp,false,0,true);
				_addEventListener(MouseEvent.MOUSE_OVER, onMouseOver,false,0,true);
			}
			init();
			initialized = 1;
//			loadingBox.visible = false;
		} else {
			
		}
	}

	public function destroy() {
		//HxlGraphics.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		//HxlGraphics.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		clearEventListeners();
		defaultGroup.destroy();
	}
	
	function init() { }
	function onKeyUp(event:KeyboardEvent) { }
	function onKeyDown(event:KeyboardEvent) { }
	function onMouseDown(event:MouseEvent) { }
	function onMouseUp(event:MouseEvent) { }
	function onMouseOver(event:MouseEvent) { }

	public function getIsStacked():Bool {
		return _isStacked;
	}

	public function setIsStacked(Toggle:Bool):Bool {
		_isStacked = Toggle;
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

	function _removeEventListener(Type:String, Listener:Dynamic) {
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
		}
	}

	function pauseEventListeners() {
		for ( i in eventListeners ) {
			HxlGraphics.stage.removeEventListener(i.Type, i.Listener);
		}
	}

	function resumeEventListeners() {
		if ( HxlGraphics.stage == null ) return;
		for ( i in eventListeners ) {
			HxlGraphics.stage.addEventListener(i.Type, i.Listener, i.UseCapture,0,true);
		}
	}

}
