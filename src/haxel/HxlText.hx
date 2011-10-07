package haxel;

import flash.display.BitmapData;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import haxel.HxlSprite;

#if flash9
import flash.text.AntiAliasType;
import flash.text.GridFitType;
#end
class HxlTextBMPData extends HxlSpriteBMPData {
	public function new(width : Int, height : Int, transparent : Bool = true, fillColor : UInt = 0xFFFFFFFF) {
		super(width, height, transparent, fillColor);
	}
}
/**
 * Extends <code>HxlSprite</code> to support rendering text.
 * Can tint, fade, rotate and scale just like a sprite.
 * Doesn't really animate though, as far as I know.
 * Also does nice pixel-perfect centering on pixel fonts
 * as long as they are only one liners.
 */
class HxlText extends HxlSprite {

  public var alignment(getAlignment, setAlignment) : String;
  override public var color(getColor, setColor) : Int;
  public var font(getFont, setFont) : String;
  public var shadow(getShadow, setShadow) : Int;
  public var size(getSize, setSize) : Float;
  public var text(getText, setText) : String;
  var _tf:TextField;
  var _regen:Bool;
  var _shadow:Int;

  //added boldness support
  var AddBold:Bool;
  var boldStart:Int;
  var boldEnd:Int;
  var boldFont:String;

  
  override public function destroy() {
	if(_framePixels!=null)
		_framePixels.dispose();
	if(_pixels!=null)
		_pixels.dispose();
	
	if(_bbb!=null)
		_bbb.dispose();


	super.destroy();
	_tf = null;
  }
  
  /**
   * Creates a new <code>HxlText</code> object at the specified position.
   *
   * @param	X				The X position of the text.
   * @param	Y				The Y position of the text.
   * @param	Width			The width of the text object (height is determined automatically).
   * @param	Text			The actual text you would like to display initially.
   * @param	EmbeddedFont	Whether this text field uses embedded fonts or not
   * @param 	FontName 		Name of the font to use
   */
  public function new(X:Float, Y:Float, Width:Int, ?Text:String=null, ?EmbeddedFont:Bool=true, ?FontName:String=null,?Size:Int=12,?Color:Int=0xffffff,?Alignment:String=null) {
    super(Math.floor(X),Math.floor(Y));
    createGraphic(Width,1,0);
    //antialiasing = false;
    if (Text == null) {
      Text = "";
    }
    _tf = new TextField();
    _tf.width = Width;
    #if flash9
    _tf.embedFonts = EmbeddedFont;
    _tf.antiAliasType = AntiAliasType.NORMAL;
    _tf.sharpness = 100;
    #else
    #end
    _tf.selectable = false;
    _tf.multiline = true;
    _tf.wordWrap = true;
    _tf.text = Text;
    if ( FontName == null ) FontName = HxlGraphics._defaultFont;
    var tf:TextFormat = new TextFormat(FontName,8,0xffffff);
    _tf.defaultTextFormat = tf;
    _tf.setTextFormat(tf);
    if (Text.length <= 0) {
      _tf.height = 1;
    } else {
      _tf.height = 10;
    }
    _regen = true;
    _shadow = 0;
    //solid = false;
    calcFrame();
    setFormat(FontName, Size, Color, Alignment);
  }

  public function setProperties(?Multiline:Bool=true, ?Wordwrap:Bool=true, ?Selectable:Bool=false) {
    _tf.selectable = Multiline;
    _tf.multiline = Wordwrap;
    _tf.wordWrap = Selectable;
  }

  /**
   * You can use this if you have a lot of text parameters
   * to set instead of the individual properties.
   *
   * @param	Font		The name of the font face for the text display.
   * @param	Size		The size of the font (in pixels essentially).
   * @param	Color		The color of the text in traditional flash 0xRRGGBB format.
   * @param	Alignment	A string representing the desired alignment ("left,"right" or "center").
   * @param	ShadowColor	A Int representing the desired text shadow color in flash 0xRRGGBB format.
   *
   * @return	This HxlText instance (nice for chaining stuff together, if you're into that).
   */
  public function setFormat(?Font:String=null,?Size:Int=12,?Color:Int=0xffffff,?Alignment:String=null,?ShadowColor:Int=0x010101):HxlText {
    if (Font == null) {
      Font = "";
    }
    var tf:TextFormat = dtfCopy();
    tf.font = Font;
    tf.size = Size;
    tf.color = Color;
    Reflect.setField(tf, "align", Alignment);
    _tf.defaultTextFormat = tf;
    _tf.setTextFormat(tf);
    _shadow = ShadowColor;
    _regen = true;
    calcFrame();
    return this;
  }
  /**
   * The text being displayed.
   */
  public function getText():String {
    return _tf.text;
  }

  public function setUnderlined() {
	  var tf:TextFormat = dtfCopy();
	  tf.underline = true;
	  _tf.defaultTextFormat = tf;
      _tf.setTextFormat(tf);
	  _regen = true;
	  calcFrame();
  }
  
  /**
   * @private
   */
  public function setText(Text:String):String {
    if (Text == null)
      Text = "";

    var ot:String = _tf.text;
    _tf.text = Text;
    if (_tf.text != ot) {
      _regen = true;
      calcFrame();
    }
    return Text;
  }

  /**
   * The size of the text being displayed.
   */
   public function getSize():Float {
    return cast( _tf.defaultTextFormat.size, Float);
  }

  /**
   * @private
   */
  public function setSize(Size:Float):Float {
    var tf:TextFormat = dtfCopy();
    tf.size = Size;
    _tf.defaultTextFormat = tf;
    _tf.setTextFormat(tf);
    _regen = true;
    calcFrame();
    return Size;
  }

  /**
   * The color of the text being displayed.
   */
  public override function getColor():Int {
    return Math.floor(_tf.defaultTextFormat.color);
  }

  /**
   * @private
   */
  public override function setColor(Color:Int):Int {
    var tf:TextFormat = dtfCopy();
    tf.color = Color;
    _tf.defaultTextFormat = tf;
    _tf.setTextFormat(tf);
    _regen = true;
    calcFrame();
    return Color;
  }

  /**
   * The font used for this text.
   */
  public function getFont():String {
    return _tf.defaultTextFormat.font;
  }

  /**
   * @private
   */
  public function setFont(Font:String):String {
    var tf:TextFormat = dtfCopy();
    tf.font = Font;
    _tf.defaultTextFormat = tf;
    _tf.setTextFormat(tf);
    _regen = true;
    calcFrame();
    return Font;
  }
  /**
   * makes an area of the text bold(actually just changes the font in an area)
   * @param	beginChar boldness beginning character number
   * @param	endChar boldness ending character number
   * @param	boldFontName
   */
  public function setBold(beginChar:Int,endChar:Int,boldFontName:String):Void
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
    boldFont = boldFontName;
    boldStart = beginChar;
    boldEnd   = endChar;
    _regen = true;
    calcFrame();
    _regen = false;
  }
  /**
   * The alignment of the font ("left", "right", or "center").
   */
  public function getAlignment():String {
    return cast(_tf.defaultTextFormat.align, String);
  }

  /**
   * @private
   */
  public function setAlignment(Alignment:String):String {
    var tf:TextFormat = dtfCopy();
    Reflect.setField(tf, "align", Alignment);
    _tf.defaultTextFormat = tf;
    _tf.setTextFormat(tf);
    calcFrame();
    return Alignment;
  }

  public function getShadow():Int {
    return _shadow;
  }

  /**
   * @private
   */
  public function setShadow(Color:Int):Int {
    _shadow = Color;
    calcFrame();
    return Color;
  }

  /**
   * Internal function to update the current animation frame.
   */
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
      _bbb = new HxlTextBMPData(Math.floor(width),Math.floor(height),true,0);
      frameHeight = Math.floor(height);
      _tf.height = height*1.2;
      _flashRect.x = 0;
      _flashRect.y = 0;
      _flashRect.width = width;
      _flashRect.height = height;
      _regen = false;
    } else {	//Else just clear the old buffer before redrawing the text
		if (_pixels == null || _flashRect==null)
			return;
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
                //Not sure boldness will work with NME..
                #if flash
                    tfa = _tf.getTextFormat();
                    tfa.font = boldFont;
                #end
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

  /**
   * A helper function for updating the <code>TextField</code> that we use for rendering.
   *
   * @return	A writable copy of <code>TextField.defaultTextFormat</code>.
   */
  function dtfCopy():TextFormat {
    var dtf:TextFormat = _tf.defaultTextFormat;
    return new TextFormat(dtf.font,dtf.size,dtf.color,dtf.bold,dtf.italic,dtf.underline,dtf.url,dtf.target,dtf.align);
  }
  override public function kill() {
    super.kill();
	destroy();
  }
}
