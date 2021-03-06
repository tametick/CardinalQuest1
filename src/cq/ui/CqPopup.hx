package cq.ui;

import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import haxel.HxlGraphics;
import haxel.HxlGroup;
import haxel.HxlPoint;
import haxel.HxlSprite;
import haxel.HxlState;
import haxel.HxlText;

import cq.CqResources;

class CqPopup extends HxlText{
	var parent:Dynamic;
	public var mouseBound:Bool;
	public var customBound:HxlPoint;
	
	public function new(Width:Int,Text:String,Parent:Dynamic) {
		parent = Parent;
		
		super(0, 0, Width, Text, true, FontAnonymousPro.instance.fontName);
		setFormat("FontAnonymousPro", 15, 0xC2AC30, "center", 1);
		mouseBound = true;
	}
	
	public override function onRemove(state:HxlState) {		
		super.onRemove(state);
	}
	
	override public function destroy() 	{
		onRemove(null);
		if (parent != null) {
			parent.remove(this);
			HxlGraphics.state.remove(this);
			parent.clearPopup();
			parent = null;
		}
		super.destroy();
	}
	
}