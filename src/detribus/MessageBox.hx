package detribus;

import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.display.Bitmap;

import haxel.HxlGroup;
import haxel.HxlGraphics;
import haxel.HxlSprite;
import haxel.HxlText;

#if flash9
import flash.text.AntiAliasType;
import flash.text.GridFitType;
#end

class MessageBox extends HxlGroup {

	private var background:HxlSprite;
	//public var messageText:HxlText;
	public var messageText:TextField;
	private var textOffset:Int;

	public function new(X:Int, Y:Int, Width:Int, Height:Int) {
		super();
		x = X;
		y = Y;
		width = Width;
		height = Height;
		scrollFactor.x = 0;
		scrollFactor.y = 0;
		background = new HxlSprite(0, 0);
		background.createGraphic(Width, Height, 0xaa000000);
		add(background);
		textOffset = 5;

		messageText = new TextField();
		messageText.width = Std.int(width - (textOffset*2));
		messageText.height = Std.int(height - (textOffset*2));
		messageText.x = x + textOffset;
		messageText.y = y + textOffset;
		messageText.multiline = true;
		messageText.wordWrap = true;
		messageText.selectable = false;
		#if flash9
		messageText.embedFonts = true;
		messageText.antiAliasType = AntiAliasType.NORMAL;
		messageText.gridFitType = GridFitType.PIXEL;
		#else
		#end
		messageText.defaultTextFormat = new TextFormat(null,16,0x000000);

		HxlGraphics.state.addChild(messageText);
	}

	public override function render():Void {
		messageText.x = x + textOffset;
		messageText.y = y + textOffset;
		messageText.visible = true;
		super.render();
	}

	public function setBackground(Enabled:Bool, ?Color:Int=0xffffff):Void {
		if ( !Enabled ) {
			background.visible = false;
			return;
		} else {
			background.visible = true;
			background.createGraphic(Std.int(width), Std.int(height), Color);
		}
	}

	public function setAlign(Align:String):String {
		var tf:TextFormat = messageText.defaultTextFormat;
		Reflect.setField(tf, "align", Align);
		messageText.defaultTextFormat = tf;
		messageText.setTextFormat(tf);
		return Align;
	}
	
	public function setFontSize(Size:Int):Int {
		var tf:TextFormat = messageText.defaultTextFormat;
		Reflect.setField(tf, "size", Size);
		messageText.defaultTextFormat = tf;
		messageText.setTextFormat(tf);
		return Size;		
	}
	
	public function setFontColor(Color:Int):Int {
		var tf:TextFormat = messageText.defaultTextFormat;
		Reflect.setField(tf, "color", Color);
		messageText.defaultTextFormat = tf;
		messageText.setTextFormat(tf);
		return Color;		
	}	
	
	public override function destroy():Void {
		HxlGraphics.state.removeChild(messageText);
		super.destroy();
	}

}
