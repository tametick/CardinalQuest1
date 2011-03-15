package com.baseoneonline.flash.utils
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class ShadowedTextField extends Sprite
	{
		
		private var fgColor:uint = 0xFFFFFF;
		private var bgColor:uint = 0x000000;
		private var xoff:Number = 1;
		private var yoff:Number = 1;
		
		private var tfFore:TextField;
		private var tfBack:TextField;
		private var fmtFore:TextFormat;
		private var fmtBack:TextFormat;
		
		public function ShadowedTextField()
		{
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
		}
		
		public function setText(n:String):void
		{
			tfFore.text = n;
			tfFore.setTextFormat(fmtFore);

			tfBack.text = n;
			tfBack.setTextFormat(fmtBack);
		}
		
	}
}