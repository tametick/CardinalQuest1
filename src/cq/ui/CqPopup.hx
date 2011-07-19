package cq.ui;
import flash.display.BitmapData;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import haxel.HxlGraphics;
import haxel.HxlGroup;
import haxel.HxlSprite;
import haxel.HxlState;
import haxel.HxlText;

class CqPopup extends HxlText{
	var parent:Dynamic;
	public function new(Width:Int,Text:String,Parent:Dynamic) {
		parent = Parent;
		super(0, 0, Width, Text);
		setFormat("FontAnonymousPro", 15, 0xC2AC30, "left", 1);
	}
	
	public override function onRemove(state:HxlState) {
		parent.remove(this);
	}
	
}