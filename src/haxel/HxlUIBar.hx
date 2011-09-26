package haxel;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Cubic;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;

class HxlUIBar extends HxlDialog {

	var frame:HxlSprite;
	var interior:HxlSprite;
	var bar:HxlSprite;
	var tweenEnabled:Bool;
	var tweenSpeed:Float;

	override public function destroy()	{
		frame.destroy();
		frame = null;
		
		interior.destroy();
		interior = null;
		
		bar.destroy();
		bar = null;
		
		super.destroy();
	}
	
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

		tweenEnabled = true;
		tweenSpeed = 0.4;
	}

	public function setTween(Enabled:Bool=true, ?TweenSpeed:Float=0.0) {
		if ( TweenSpeed > 0.0 ) tweenSpeed = TweenSpeed;
		tweenEnabled = Enabled;
	}

	public function setPercent(Value:Float) {
		var newVal:Float = (width-2) * Value;
		if ( newVal < 0 ) newVal = 0;
		if ( newVal > width-2 ) newVal = width-2;
		if ( !tweenEnabled ) {
			bar.scale.x = newVal;
		} else {
			Actuate.update(percentChangeTweenCallback, tweenSpeed, {X: bar.scale.x}, {X: newVal}).ease(Cubic.easeOut);
		}
	}
	function percentChangeTweenCallback(params:Dynamic)
	{
		bar.scale.x = params.X;
	}

	public function setFrameColor(Color:Int, ?CornerRadius:Float=0.0) {
		if ( CornerRadius <= 0.0 ) {
			frame.createGraphic(Std.int(width), Std.int(height), Color);
		} else {
			createRounded(frame, width, height, Color, CornerRadius);
		}
	}

	public function setInteriorColor(Color:Int, ?CornerRadius:Float=0.0) {
		if ( CornerRadius <= 0 ) {
			interior.createGraphic(Std.int(width-2), Std.int(height-2), Color);
		} else {
			createRounded(interior, width-2, height-2, Color, CornerRadius);
		}
	}

	public function setBarColor(Color:Int, ?CornerRadius:Float=0.0) {
		if ( CornerRadius <= 0 ) {
			bar.createGraphic(1, Std.int(height-2), Color);
		} else {
			createRounded(bar, 1, height-2, Color, CornerRadius);
		}
		bar.origin.x = bar.origin.y = 0;
	}

	function createRounded(TargetSprite:HxlSprite, Width:Float, Height:Float, Color:Int, ?CornerRadius:Float=0.0) {
		var iWidth:Int = Std.int(Width);
		var iHeight:Int = Std.int(Height);
		if ( CornerRadius <= 0.0 ) {
			TargetSprite.createGraphic(iWidth, iHeight, Color);
			return;
		} else {
			var target:Shape = new Shape();
			target.graphics.beginFill(Color);
			target.graphics.drawRoundRect(0, 0, iWidth, iHeight, CornerRadius, CornerRadius);
			target.graphics.endFill();
			var bmp:BitmapData = new BitmapData(Std.int(iWidth), Std.int(iHeight), true, 0x0);
			bmp.draw(target);
			target = null;
			TargetSprite.pixels = bmp;
			
			target = null;
			bmp = null;
		}
	}
}
