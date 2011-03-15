package com.baseoneonline.haxe.utils;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.getTimer;

/**
 * 	Very simple fps counter for everyday use.
 * 
 */
public class FPSMeter extends Sprite
{
	
	var tf:TextField;
	var bmp:BitmapData;
	var tbmp:BitmapData;

	var otime:Int = 0;
	
	var barWidth:Int = 200;
	var barHeight:Int = 13;
	var scrollWidth:Int = 1;
	
	public function FPSMeter()
	{
		super();
		
		createAssets();
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	function createAssets():void
	{
		bmp = new BitmapData(barWidth, barHeight, false, 0x00FF00);
		addChild(new Bitmap(bmp));	
		
		tbmp = new BitmapData(scrollWidth,barHeight, false);
		
		tf = new TextField();
		tf.autoSize = TextFieldAutoSize.LEFT;
		tf.y = -4;
		addChild(tf);
	}
	
	
	function onEnterFrame(e:Event):void
	{
		var ntime:Int = getTimer();
		var ms:Int = ntime - otime;
		otime = ntime;
		var fps:Number = 1000/ms;
		
		// Update the scroller
		bmp.scroll(-scrollWidth,0);
		var err:Int = barHeight-Math.round((fps/stage.frameRate)*barHeight);
		var x:Int; 
		var y:Int;
		for (x=barWidth-scrollWidth; x<barWidth; x++) {
			for (y=0; y<err-1; y++) {
				bmp.setPixel(x,y,0xFF5500);	
			}
			for (y=err; y<barHeight; y++) {
				bmp.setPixel(x,y,0x00FF00);
			}
		}
		
		
		
		// Update text
		tf.text = "ms: "+ms+" | fps: "+fps.toFixed(1)+" / "+stage.frameRate;
		var fmt:TextFormat = new TextFormat();
		fmt.font = "_sans";
		tf.setTextFormat(fmt);
		
	}
	
}