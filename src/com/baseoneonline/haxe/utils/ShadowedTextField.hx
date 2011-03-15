package com.baseoneonline.haxe.utils;

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

class ShadowedTextField extends Sprite
{
	
	var fgColor:UInt;
	var bgColor:UInt;
	var xoff:Float;
	var yoff:Float;
	
	var tfFore:TextField;
	var tfBack:TextField;
	var fmtFore:TextFormat;
	var fmtBack:TextFormat;
	
	public function new()
	{
		bgColor = 0x000000;
		fgColor = 0xDC5E13;
		xoff = 1;
		yoff = 1;
		
		mouseChildren = false;
		mouseEnabled = false;

		tfBack = new TextField();
		tfBack.autoSize = TextFieldAutoSize.LEFT;
		tfBack.selectable = false;
		tfBack.x = xoff;
		tfBack.y = yoff;
		addChild(tfBack);
		
		tfFore = new TextField();
		tfFore.autoSize = TextFieldAutoSize.LEFT;
		tfFore.selectable = false;
		addChild(tfFore);

		fmtFore = new TextFormat();
		fmtFore.color = fgColor;

		fmtBack = new TextFormat();
		fmtBack.color = bgColor;
		
		super();
	}
	
	public function setText(n:String):Void
	{
		tfFore.text = n;
		tfFore.setTextFormat(fmtFore);

		tfBack.text = n;
		tfBack.setTextFormat(fmtBack);
	}
	
}