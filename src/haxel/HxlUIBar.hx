package haxel;

class HxlUIBar extends HxlDialog {

	var frame:HxlSprite;
	var interior:HxlSprite;
	var bar:HxlSprite;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=0, ?Height:Float=0) {
		super(X, Y, Width, Height);

		frame = new HxlSprite(0, 0);
		frame.createGraphic(Std.int(Width), Std.int(Height), 0xff666666);
		frame.zIndex = 0;
		add(frame);

		interior = new HxlSprite(1, 1);
		interior.createGraphic(Std.int(Width-2), Std.int(Height-2), 0xff000000);
		interior.zIndex = 1;
		add(interior);

		bar = new HxlSprite(1, 1);
		bar.createGraphic(1, Std.int(Height-2), 0xffff0000);
		bar.origin.x = bar.origin.y = 0;
		bar.zIndex = 2;
		add(bar);
	}

	public function setPercent(Value:Float):Void {
		var newVal:Float = (width-2) * Value;
		if ( newVal < 0 ) newVal = 0;
		if ( newVal > width-2 ) newVal = width-2;
		bar.scale.x = newVal;
	}

	public function setFrameColor(Color:Int):Void {
		frame.createGraphic(Std.int(width), Std.int(height), Color);
	}

	public function setInteriorColor(Color:Int):Void {
		interior.createGraphic(Std.int(width-2), Std.int(height-2), Color);
	}

	public function setBarColor(Color:Int):Void {
		bar.createGraphic(1, Std.int(height-2), Color);
		bar.origin.x = bar.origin.y = 0;
	}

}
