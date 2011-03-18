package haxel;

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
		scrollRate = 1.0;
		scrollTimer = new HxlTimer(scrollRate);
	}

	public override function update():Void {
	    super.update();
		if ( scrollTimer.delta() > 0 ) {
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
			remove(oldLine);
		}
		lines.add(line);
		line.zIndex = 1;
		add(line);
		updateLayout();
	}

	public function scrollText():Void {
		if ( lines.length > 0 ) {
			var line:HxlText = lines.first();
		}
	}

	function updateLayout():Void {
		var Y:Float = y + _padding;
		var X:Float = x + _padding;
		var count:Int = 0;
		for( line in lines ) {
			if ( count > 0 ) Y += fontSize + lineSpacing;
			line.x = X;
			line.y = Y;
			count++;
		}
		reset(x, y);
	}
}
