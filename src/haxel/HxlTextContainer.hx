package haxel;

import com.eclecticdesignstudio.motion.Actuate;

class HxlTextContainer extends HxlDialog {

	var lines:List<HxlText>;
	var lineSpacing:Int;
	var fontName:String;
	var fontSize:Int;
	var fontColor:Int;
	var fontAlignment:String;
	var shadowColor:Int;
	var scrollTimer:HxlTimer;
	public var scrollRate:Float;
	public var maxLines:Int;
	var reverseOrder:Bool;

	var fadeEffect:Bool;
	var isFading:Bool;

	var stepColorEffect:Bool;
	var stepColors:Array<Int>;

	var stepAlphaEffect:Bool;
	var stepAlpha:Float;

	/**
	 * Amount of space (in pixels) between edges of container and text.
	 **/
	var _padding:Float;
	//public var padding(setPadding, getPadding):Float;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?DefaultFont:String=null, ?Padding:Int=10) {
		super(X, Y, Width, Height);

		_padding = Padding;
		if ( DefaultFont == null ) DefaultFont = HxlGraphics.defaultFont;
		fontName = DefaultFont;
		fontSize = 10;
		fontColor = 0xffffff;
		fontAlignment = "left";
		shadowColor = 0x000000;
		maxLines = 3;
		lineSpacing = 3;
		lines = new List();
		reverseOrder = true;

		scrollRate = 1.0;
		scrollTimer = new HxlTimer(scrollRate);

		fadeEffect = false;
		isFading = false;

		stepColorEffect = false;
		stepColors = new Array();

		stepAlphaEffect = true;
		stepAlpha = 0.3;
	}

	public override function update():Void {
	    super.update();
		if ( fadeEffect &&  scrollTimer.delta() > 0 ) {
			if ( lines.length > 0 ) scrollText();
			scrollTimer.reset(scrollRate);
		}
	}

	public function setFormat(?Font:String=null,?Size:Int=8,?Color:Int=0xffffff,?Alignment:String=null,?ShadowColor:Int=0):Void {
		if ( Font != null ) fontName = Font;
		fontSize = Size;
		fontColor = Color;
		fontAlignment = Alignment;
		shadowColor = ShadowColor;
		for ( line in lines ) {
			line.setFormat(fontName, fontSize, fontColor, fontAlignment, shadowColor);
		}
	}

	public function addText(Text:String):Void {
		var line:HxlText = new HxlText(0, 0, Std.int(width - (_padding * 2)), Text, true, fontName);
		line.setFormat(fontName, fontSize, fontColor, fontAlignment, shadowColor);
		if ( lines.length == maxLines ) {
			var oldLine:HxlText = lines.pop();
			Actuate.stop(this, {}, false);
			remove(oldLine);
			isFading = false;
		}
		lines.add(line);
		line.zIndex = 1;
		add(line);
		updateLayout();
		if ( lines.length == 1 ) scrollTimer.reset(scrollRate);
	}

	public function scrollText():Void {
		if ( lines.length > 0 ) {
			if ( fadeEffect && !isFading ) {
				var line:HxlText = lines.first();
				Actuate.update(function(params:Dynamic) {
					line.alpha = params.Alpha;
				}, scrollRate, {Alpha: 1.0}, {Alpha: 0.0});
				isFading = true;
			} else {
				var line:HxlText = lines.pop();
				remove(line);
				updateLayout();
				isFading = false;
			}
		}
	}

	function updateLayout():Void {
		if ( !reverseOrder  ) {
			var Y:Float = y + _padding;
			var X:Float = x + _padding;
			var count:Int = 0;
			for( line in lines ) {
				if ( count > 0 ) Y += fontSize + lineSpacing;
				line.x = X;
				line.y = Y;
				count++;
				if ( stepAlphaEffect ) {
					line.alpha = Math.max(0.0, 1.0 - (stepAlpha * (lines.length - count)));
				}
			}
		} else {
			var Y:Float = y + _padding;
			var X:Float = x + _padding;
			var count:Int = 0 ;
			var lineNum:Int = lines.length - 1;
			for ( line in lines ) {
				line.x = X;
				line.y = Y + (lineNum * fontSize);
				count++;
				lineNum--;
				if ( stepAlphaEffect ) {
					line.alpha = Math.max(0.0, 1.0 - (stepAlpha * (lines.length - count)));
				}		
			}
		}
		reset(x, y);
	}
}
