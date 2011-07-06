package cq.ui;
import flash.display.BitmapData;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import haxel.HxlGraphics;
import haxel.HxlGroup;
import haxel.HxlSprite;
import haxel.HxlState;
import haxel.HxlText;

/**
 * ...
 * @author joris
 */

class CqPopup extends HxlText
{
	var AddBold:Bool;
	var boldStart:Int;
	var boldEnd:Int;
	var parent:HxlGroup;
	public function new(Width:Int,Text:String,Parent:HxlGroup) 
	{
		parent = Parent;
		super(0, 0, Width, Text);
		setFormat("FontAnonymousPro", 15, 0xC2AC30, "left", 1);
	}
	public function setBold(beginChar:Int,endChar:Int):Void
	{
		//return to bounds
		if (beginChar >= endChar)
			return;
		if (beginChar < 0)
			beginChar = 0;
		if (endChar < 0)
			endChar = 0;
		if (endChar >= text.length)
			endChar = text.length - 1;
			
		AddBold = true;
		boldStart = beginChar;
		boldEnd   = endChar;
		_regen = true;
		calcFrame();
		_regen = false;
	}
	override function onRemove(state:HxlState):Void
	{
		parent.remove(this);
	}
	override function calcFrame() {
		if (_regen) {
			//Need to generate a new buffer to store the text graphic
			height = 0;
			#if flash9
			var nl:Int = _tf.numLines;
			for (i in 0 ... nl) {
				height += _tf.getLineMetrics(i).height;
			}
			#else
			var nl:Int = 1;
			#end
			height += 4; //account for 2px gutter on top and bottom
			_pixels = new BitmapData(Math.floor(width),Math.floor(height),true,0);
			_bbb = new BitmapData(Math.floor(width),Math.floor(height),true,0);
			frameHeight = Math.floor(height);
			_tf.height = height*1.2;				
			_flashRect.x = 0;
			_flashRect.y = 0;
			_flashRect.width = width;
			_flashRect.height = height;
			_regen = false;
		} else {	//Else just clear the old buffer before redrawing the text
			_pixels.fillRect(_flashRect,0);
		}
		
		if ((_tf != null) && (_tf.text != null) && (_tf.text.length > 0)) {
			//Now that we've cleared a buffer, we need to actually render the text to it
			var tf:TextFormat = _tf.defaultTextFormat;
			var tfa:TextFormat = tf;
			_mtx.identity();
			//If it's a single, centered line of text, we center it ourselves so it doesn't blur to hell
			#if flash9
			if ((tf.align == TextFormatAlign.CENTER) && (_tf.numLines == 1))
			#else
			if (tf.align == TextFormatAlign.CENTER)
			#end
			{
				tfa = new TextFormat(tf.font,tf.size,tf.color,null,null,null,null,null,TextFormatAlign.LEFT);
				_tf.setTextFormat(tfa);				
				#if flash9
				_mtx.translate(Math.floor((width - _tf.getLineMetrics(0).width)/2),0);
				#else
				_mtx.translate(Math.floor((width - 0)/2),0);
				#end
			}
			//Render a single pixel shadow beneath the text
			if (_shadow > 0) {
				_tf.setTextFormat(new TextFormat(tfa.font,tfa.size,_shadow,null,null,null,null,null,tfa.align));				
				_mtx.translate(1,1);
				_pixels.draw(_tf,_mtx,_ct);
				_mtx.translate(-1,-1);
				_tf.setTextFormat(new TextFormat(tfa.font,tfa.size,tfa.color,null,null,null,null,null,tfa.align));
				var tmpHeight:Float = _tf.textHeight;
			}
			//addboldness
			if (AddBold)
			{
				tfa = _tf.getTextFormat();
				tfa.font = "FontAnonymousProB";
				_tf.setTextFormat(tfa, boldStart, boldEnd);
			}
			//Actually draw the text onto the buffer
			_pixels.draw(_tf,_mtx,_ct);
			_tf.setTextFormat(new TextFormat(tf.font, tf.size, tf.color, null, null, null, null, null, tf.align));
		}
		//Finally, update the visible pixels
		if ((_framePixels == null) || (_framePixels.width != _pixels.width) || (_framePixels.height != _pixels.height)) {
			_framePixels = new BitmapData(_pixels.width,_pixels.height,true,0);
		}
		_framePixels.copyPixels(_pixels,_flashRect,_flashPointZero);
		if (HxlGraphics.showBounds) {
			drawBounds();
		}
		/*
		if (solid) {
			refreshHulls();
		}
		*/
	}
}