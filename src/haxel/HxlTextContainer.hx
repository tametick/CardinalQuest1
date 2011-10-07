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
	public var reverseOrder:Bool;

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
		if ( DefaultFont == null ) DefaultFont = HxlGraphics._defaultFont;
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

		stepAlphaEffect = false;
		stepAlpha = 0.3;
	}

	public override function update() {
	    super.update();
		if ( fadeEffect &&  scrollTimer.delta() > 0 ) {
			if ( lines.length > 0 ) scrollText();
			scrollTimer.reset(scrollRate);
		}
	}

	public function setColorStep(Toggle:Bool, ?Colors:Array<Int>=null) {
		stepColorEffect = Toggle;
		if ( Colors != null ) {
			stepColors = Colors;
		} else {
			stepColors = new Array();
			stepColors.push(0x999999);
			stepColors.push(0xcccccc);
			stepColors.push(0xffffff);
		}
	}

	public function setFormat(?Font:String=null,?Size:Int=12,?Color:Int=0xffffff,?Alignment:String=null,?ShadowColor:Int=0) {
		if ( Font != null ) fontName = Font;
		fontSize = Size;
		fontColor = Color;
		fontAlignment = Alignment;
		shadowColor = ShadowColor;
		for ( line in lines ) {
			line.setFormat(fontName, fontSize, fontColor, fontAlignment, shadowColor);
		}
	}

	public function addText(Text:String) {
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
		enforceMaxHeight();
		add(line);
		updateLayout();
		if ( lines.length == 1 ) scrollTimer.reset(scrollRate);
	}

	public function enforceMaxHeight() {
		var totalHeight:Float = 0;
		var count:Int = 0;
		for ( line in lines ) {
			if ( count > 0 ) totalHeight += lineSpacing;
			totalHeight += line.height;
		}
		if ( totalHeight < height ) return;
		Actuate.stop(this, {}, false);
		var line:HxlText;
		while ( totalHeight > height ) {
			line = lines.pop();
			remove(line);
			totalHeight -= line.height;
			totalHeight -= lineSpacing;
		}
	}
	var line:HxlText;
	public function scrollText() {
		if ( lines.length > 0 ) {
			if ( fadeEffect && !isFading ) {
				line = lines.first();
				Actuate.update(scrollTweenUpdate, scrollRate, [1.0], [0.0]);
				isFading = true;
			} else {
				var line:HxlText = lines.pop();
				remove(line);
				updateLayout();
				isFading = false;
			}
		}
	}
	function scrollTweenUpdate(params:Dynamic) {
		if (params!= null)
			line.alpha = cast(params,Float);
	}
	function updateLayout() {
		if ( !reverseOrder  ) {
			var Y:Float = y + _padding;
			var X:Float = x + _padding;
			var count:Int = 0;
			for( line in lines ) {
				if ( count > 0 ) Y += fontSize + lineSpacing;
				line.x = X;
				line.y = Y;
				if ( stepColorEffect ) {
					if ( count < stepColors.length ) {
						line.color = stepColors[count];
					} else if ( stepColors.length > 0 ) {
						line.color = stepColors[stepColors.length-1];
					}
				}
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
				if ( stepColorEffect ) {
					if ( count < stepColors.length ) {
						line.color = stepColors[count];
					} else if ( stepColors.length > 0 ) {
						line.color = stepColors[stepColors.length-1];
					}
				}		
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
