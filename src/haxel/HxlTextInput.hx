package haxel;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.text.TextFieldType;

class HxlTextInput extends HxlText {

	static public var NO_FILTER:Int = 0;
	static public var ONLY_ALPHA:Int = 1;
	static public var ONLY_NUMERIC:Int = 2;
	static public var ONLY_ALPHANUMERIC:Int = 3;
	static public var CUSTOM_FILTER:Int = 4;
	public var filterMode:Int;
	public var customFilterPattern:EReg;
	public var backgroundColor(getBackgroundColor, setBackgroundColor):Int;
	public var borderColor(getBorderColor, setBorderColor):Int;
	public var backgroundVisible(getBackgroundVisible, setBackgroundVisible):Bool;
	public var borderVisible(getBorderVisible, setBorderVisible):Bool;

	public var forceUpperCase:Bool;
	var nextFrameHide:Bool;

	public function new(X:Float, Y:Float, Width:Int, ?Text:String=null, ?EmbeddedFont:Bool=true) {
		super(X, Y, Width, Text, EmbeddedFont);
		var tmpColor = 0xffffff;
		_tf.selectable = true;
		_tf.type = TextFieldType.INPUT;
		_tf.background = true;
		_tf.backgroundColor = (~tmpColor) & 0xffffff;
		_tf.border = true;
		_tf.borderColor = tmpColor;
		_tf.visible = false;
		_tf.multiline = false;
		filterMode = NO_FILTER;
		nextFrameHide = false;
		forceUpperCase = false;
		customFilterPattern = ~/[]*/g;
		_tf.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		_tf.addEventListener(Event.REMOVED_FROM_STAGE, onInputFieldRemoved);
		_tf.addEventListener(Event.CHANGE, onTextChange);
		_tf.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		alwaysVisible = true;
		HxlGraphics.state.addChild(_tf);
	}

	public override function render():Void	{
		_tf.x = x;
		_tf.y = y;
		_tf.visible = true;
		nextFrameHide = false;
	}

	function onInputFieldRemoved(event:Event):Void {
		//Clean up after ourselves
		_tf.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		_tf.removeEventListener(Event.REMOVED, onInputFieldRemoved);
		_tf.removeEventListener(Event.CHANGE, onTextChange);
		_tf.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}

	function onEnterFrame(event:Event):Void {
		if (nextFrameHide) {
			_tf.visible = false;
		}
		nextFrameHide = true;
	}

	function onKeyDown(event:KeyboardEvent):Void {
		if ( event.charCode == 13 ) {
			event.preventDefault();
		}
	}

	function onTextChange(event:Event):Void {
		if (forceUpperCase) {
			_tf.text = _tf.text.toUpperCase();
		}

		if (filterMode != NO_FILTER) {
			var pattern;
			switch (filterMode) {
				case ONLY_ALPHA:
					pattern = ~/[^a-zA-Z]*/g;
				case ONLY_NUMERIC:
					pattern = ~/[^0-9]* /g;
				case ONLY_ALPHANUMERIC:
					pattern = ~/[^a-zA-Z0-9]* /g;
				case CUSTOM_FILTER:
					pattern = customFilterPattern;
				default:
					 //throw new Error("FlxInputText: Unknown filterMode ("+filterMode+")");
					return;
			}
			_tf.text = pattern.replace(_tf.text, "");
		}
		
	}

	public function setMaxLength(Length:Int):Void {
		_tf.maxChars = Length;
	}

	public function getBackgroundColor():Int {
		return _tf.backgroundColor;
	}

	public function setBackgroundColor(Color:Int):Int {
		_tf.backgroundColor = Color;
		return Color;
	}

	public function getBorderColor():Int {
		return _tf.borderColor;
	}

	public function setBorderColor(Color:Int):Int {
		_tf.borderColor = Color;
		return Color;
	}

	public function getBackgroundVisible():Bool {
		return _tf.background;
	}

	public function setBackgroundVisible(Enabled:Bool):Bool {
		_tf.background = Enabled;
		return Enabled;
	}

	public function getBorderVisible():Bool {
		return _tf.border;
	}

	public function setBorderVisible(Enabled:Bool):Bool {
		_tf.border = Enabled;
		return Enabled;
	}
}
