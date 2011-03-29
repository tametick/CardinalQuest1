package haxel;

import flash.display.Sprite;
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

	public function create():Void {
		initialized = -1;
	}
	
	public function add(obj:HxlObjectI):HxlObjectI {
		defaultGroup.add(obj);
		obj.onAdd(this);
		return obj;
	}
	
	public function remove(obj:HxlObject):HxlObject {
		return defaultGroup.remove(obj);
	}

	public function preProcess():Void {
		screen.fill(bgColor);
		HxlGraphics.numRenders = 0;
	}

	public function render():Void {
		defaultGroup.render();
	}

	public function postProcess():Void {
	}

	public function update():Void {
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
				_addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				_addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			}
			init();
			initialized = 1;
//			loadingBox.visible = false;
		} else {
			
		}
	}

	public function destroy():Void {
		//HxlGraphics.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		//HxlGraphics.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		clearEventListeners();
		defaultGroup.destroy();
	}
	
	function init() { }
	function onKeyUp(event:KeyboardEvent) { }
	function onKeyDown(event:KeyboardEvent) { }

	public function getIsStacked():Bool {
		return _isStacked;
	}

	public function setIsStacked(Toggle:Bool):Bool {
		_isStacked = Toggle;
		if ( initialized > 0 ) {
			if ( _isStacked ) {
				// pause my own event listeners
				pauseEventListeners();
				// pause event listeners on defaultGroup
				defaultGroup.pauseEventListeners();
			} else {
				// resume my event listeners
				resumeEventListeners();
				// resume event listeners on defaultGroup
				defaultGroup.resumeEventListeners();
			}
		}
		return _isStacked;
	}

	function _addEventListener(Type:String, Listener:Dynamic, UseCapture:Bool=false, Priority:Int=0, UseWeakReference:Bool=false):Void { 
		HxlGraphics.stage.addEventListener(Type, Listener, UseCapture, Priority, UseWeakReference);
		eventListeners.push( {Type: Type, Listener: Listener, UseCapture: UseCapture} );
	}

	function _removeEventListener(Type:String, Listener:Dynamic):Void {
		HxlGraphics.stage.removeEventListener(Type, Listener);
		for ( i in 0...eventListeners.length ) {
			var ev:Dynamic = eventListeners[i];
			if ( ev.Type == Type && ev.Listener == Listener ) {
				eventListeners.splice(i, 1);
				break;
			}
		}
	}

	function clearEventListeners():Void {
		while ( eventListeners.length > 0 ) {
			var i:Dynamic = eventListeners.pop();
			HxlGraphics.stage.removeEventListener(i.Type, i.Listener);
		}
	}

	function pauseEventListeners():Void {
		for ( i in eventListeners ) {
			HxlGraphics.stage.removeEventListener(i.Type, i.Listener);
		}
	}

	function resumeEventListeners():Void {
		if ( HxlGraphics.stage == null ) return;
		for ( i in eventListeners ) {
			HxlGraphics.stage.addEventListener(i.Type, i.Listener, i.UseCapture);
		}
	}

}
