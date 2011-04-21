package haxel;

import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import haxel.HxlGraphics;

#if flash9
import flash.text.AntiAliasType;
import flash.text.GridFitType;
#end

class HxlMenuItem extends HxlText
{

	var normalFormat:TextFormat;
	var hoverFormat:TextFormat;
	var showHover:Bool;
	var _mouseHover:Bool;

	public var itemCallback(getCallback, setCallback):Dynamic;
	var _itemCallback:Dynamic;

	public function new(X:Float, Y:Float, Width:Int, ?Text:String=null, ?EmbeddedFont:Bool=true, ?FontName:String=null) {
		super(X, Y, Width, Text, EmbeddedFont, FontName);
		normalFormat = dtfCopy();
		hoverFormat = dtfCopy();
		showHover = false;
		_itemCallback = function() {};
		_mouseHover = false;
	}

	public function setHover(Hover:Bool=false):Void {
		showHover = Hover;
		if ( !showHover ) {
			_tf.setTextFormat(normalFormat);
		} else {
			_tf.setTextFormat(hoverFormat);
		}
		_regen = true;
		calcFrame();
	}

	public function setNormalFormat(?Font:String=null,?Size:Int=8,?Color:Int=0xffffff,?Alignment:String=null,?ShadowColor:Int=0):Void {
		if ( Font == null ) Font = "";
		normalFormat.font = Font;
		normalFormat.size = Size;
		normalFormat.color = Color;
		Reflect.setField(normalFormat, "align", Alignment);
		_shadow = ShadowColor;
		setHover(showHover);
	}

	public function setHoverFormat(?Font:String=null,?Size:Int=8,?Color:Int=0xffffff,?Alignment:String=null,?ShadowColor:Int=0):Void {
		if ( Font == null ) Font = "";
		hoverFormat.font = Font;
		hoverFormat.size = Size;
		hoverFormat.color = Color;
		Reflect.setField(hoverFormat, "align", Alignment);
		_shadow = ShadowColor;
		setHover(showHover);
	}

	public function doCallback():Void {
		_itemCallback();
	}

	public function getCallback():Dynamic {
		return _callback;
	}
	
	public function setCallback(ItemCallback:Dynamic):Dynamic {
		_itemCallback = ItemCallback;
		return _itemCallback;
	}

	public override function update():Void {
		super.update();
		if ( visible && !_mouseHover && overlapsPoint(HxlGraphics.mouse.x, HxlGraphics.mouse.y) ) {
			HxlGraphics.mouse.set("button");
			_mouseHover = true;
		} else if ( !visible || (_mouseHover && !overlapsPoint(HxlGraphics.mouse.x, HxlGraphics.mouse.y)) ) {
			HxlGraphics.mouse.set("auto");
			_mouseHover = false;
		}
	}
}
