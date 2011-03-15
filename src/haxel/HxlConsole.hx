package haxel;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.system.System;

#if flash9
import flash.text.AntiAliasType;
import flash.text.GridFitType;
#end

class HxlConsole extends Sprite {

	public var mtrUpdate:HxlMonitor;
	public var mtrRender:HxlMonitor;
	public var mtrTotal:HxlMonitor;

	var _max_lines : Int;

	var _console : Sprite;
	var _lines : Array<String>;
	var _text : TextField;
	var _fpsDisplay:TextField;
	var _extraDisplay:TextField;
	var _memDisplay:TextField;
	var _curFPS:Int;
	var _rendersDisplay:TextField;

	var _Y:Float;
	var _YT:Float;
	var _bx:Int;
	var _by:Int;
	var _byt:Int;

	/**
	 * Constructor
	 *
	 * @param	X	X position of the console
	 * @param	Y	Y position of the console
	 */
	public function new(X:Int, Y:Int, Zoom:Int, DefaultFont:String="system" ) {
		_max_lines = 256; 
		super();

		visible = false;
		x = X*Zoom;
		_by = Y*Zoom;
		_byt = _by - HxlGraphics.height*Zoom;
		_YT = _Y = y = _byt;

		var tmp:Bitmap = new Bitmap(new BitmapData(HxlGraphics.width*Zoom, HxlGraphics.height*Zoom, true, 0xAF000000));
		addChild(tmp);

		mtrUpdate = new HxlMonitor(8);
		mtrRender = new HxlMonitor(8);
		mtrTotal = new HxlMonitor(8);

		_text = new TextField();
		_text.width = tmp.width;
		_text.height = tmp.height;
		_text.multiline = true;
		_text.wordWrap = true;
		_text.selectable = false;
		#if flash9
		_text.embedFonts = true;
		_text.antiAliasType = AntiAliasType.NORMAL;
		_text.gridFitType = GridFitType.PIXEL;
		#else
		#end
		_text.defaultTextFormat = new TextFormat(DefaultFont,16,0xffffff);
		addChild(_text);

		_fpsDisplay = new TextField();
		_fpsDisplay.width = 100;
		_fpsDisplay.x = tmp.width-100;
		_fpsDisplay.height = 20;
		_fpsDisplay.multiline = true;
		_fpsDisplay.wordWrap = true;
		_fpsDisplay.selectable = false;
		#if flash9
		_fpsDisplay.embedFonts = true;
		_fpsDisplay.antiAliasType = AntiAliasType.NORMAL;
		_fpsDisplay.gridFitType = GridFitType.PIXEL;
		#else
		#end
		_fpsDisplay.defaultTextFormat = new TextFormat(DefaultFont,20,0xffffff,true,null,null,null,null,TextFormatAlign.RIGHT);
		addChild(_fpsDisplay);

		_rendersDisplay = new TextField();
		_rendersDisplay.width = 100;
		_rendersDisplay.x = tmp.width-100;
		_rendersDisplay.height = 20;
		_rendersDisplay.y = 20;
		_rendersDisplay.multiline = true;
		_rendersDisplay.wordWrap = true;
		_rendersDisplay.selectable = false;
		#if flash9
		_rendersDisplay.embedFonts = true;
		_rendersDisplay.antiAliasType = AntiAliasType.NORMAL;
		_rendersDisplay.gridFitType = GridFitType.PIXEL;
		#else
		#end
		_rendersDisplay.defaultTextFormat = new TextFormat(DefaultFont,18,0xffffff,true,null,null,null,null,TextFormatAlign.RIGHT);
		addChild(_rendersDisplay);

		_memDisplay = new TextField();
		_memDisplay.width = 200;
		_memDisplay.x = tmp.width-200;
		_memDisplay.height = 20;
		_memDisplay.y = 40;
		_memDisplay.multiline = true;
		_memDisplay.wordWrap = true;
		_memDisplay.selectable = false;
		#if flash9
		_memDisplay.embedFonts = true;
		_memDisplay.antiAliasType = AntiAliasType.NORMAL;
		_memDisplay.gridFitType = GridFitType.PIXEL;
		#else
		#end
		_memDisplay.defaultTextFormat = new TextFormat(DefaultFont,18,0xffffff,true,null,null,null,null,TextFormatAlign.RIGHT);
		addChild(_memDisplay);

		_extraDisplay = new TextField();
		_extraDisplay.width = 100;
		_extraDisplay.x = tmp.width-100;
		_extraDisplay.height = 128;
		_extraDisplay.y = 60;
		_extraDisplay.alpha = 0.5;
		_extraDisplay.multiline = true;
		_extraDisplay.wordWrap = true;
		_extraDisplay.selectable = false;
		#if flash9
		_extraDisplay.embedFonts = true;
		_extraDisplay.antiAliasType = AntiAliasType.NORMAL;
		_extraDisplay.gridFitType = GridFitType.PIXEL;
		#else
		#end
		_extraDisplay.defaultTextFormat = new TextFormat(DefaultFont,16,0xffffff,true,null,null,null,null,TextFormatAlign.RIGHT);
		addChild(_extraDisplay);


		_lines = new Array();
	}

	public function toggle() {
		if ( _YT == _by ) {
			_YT = _byt;
		} else {
			_YT = _by;
			visible = true;
		}
	}

	/**
	 * Logs a string to the console
	 *
	 * @param	Text	String of text to log to the console
	 */
	public function log(Text : String) : Void {
		if ( Text == null ) Text = "NULL";
		_lines.push(Text);
		if ( _lines.length > _max_lines ) {
			_lines.shift();
			var newText:String = "";
			for ( i in 0 ... _lines.length ) {
				newText += _lines[i]+"\n";
			}
			_text.text = newText;
		} else {
			#if flash9
			_text.appendText(Text+"\n");
			#else
			_text.text = _text.text + Text + "\n";
			#end
		}
		_text.scrollV = Math.floor(_text.height);
	}

	public function update():Void {
		var total:Int = Math.floor(mtrTotal.average());
		_fpsDisplay.text = Math.floor(1000/total) + " fps";
		
		var up:Int = Math.floor(mtrUpdate.average());
		var rn:Int = Math.floor(mtrRender.average());
		var fx:Int = up+rn;
		var tt:Int = Math.floor(total);
		_extraDisplay.text = up + "ms update\n" + rn + "ms render\n" + fx + "ms flixel\n" + (tt-fx) + "ms flash\n" + tt + "ms total";

		_rendersDisplay.text = "Renders: "+HxlGraphics.numRenders;

		var memoryUsedInKb = (System.totalMemory/1024);
		_memDisplay.text = "Memory: " + memoryUsedInKb + "kb"; 

		if (_Y < _YT) {
			_Y += HxlGraphics.height*10*HxlGraphics.elapsed;
		} else if (_Y > _YT) {
			_Y -= HxlGraphics.height*10*HxlGraphics.elapsed;
		}
		if (_Y > _by) {
			_Y = _by;
		} else if (_Y < _byt) {
			_Y = _byt;
			visible = false;
		}
		y = Math.floor(_Y);
	}

}
