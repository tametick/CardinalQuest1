package cq;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Cubic;

import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import haxel.HxlGraphics;
import haxel.HxlText;

class CqFloatText extends HxlText {

	public function new(X:Float, Y:Float, Text:String=null, ?Color:Int=0xffffff,?Font:String, ?FontSize:Int=18,?Alignment:String = "center",?initDefaultTween:Bool = true) {
		super(X, Y, 500, Text);
		//note: hardcoded max width of 500
		setProperties(false, false, false);
		setFormat(Font, FontSize, Color, Alignment, 0x010101);
		width = (Alignment=="left"||Alignment=="center")?(_tf.getLineMetrics(0).width+10):500;
		_regen = true;
		calcFrame();
		x -= _pixels.width / 2;
		y -= _pixels.height / 2;
		if (initDefaultTween)
			InitDefaultTween();
	}
	public function InitDefaultTween()
	{
		var self = this;
		Actuate.tween(this, 0.8, {y: y - 20})
			.ease(Cubic.easeOut)
			.onComplete(function() {
				Actuate.update(function(params:Dynamic) {
					self.alpha = params.Alpha;
				}, 1.0, {Alpha: 1.0}, {Alpha: 0.0}).onComplete(function() { self.destroy(); });
			});
	}
	public function InitSemiCustomTween(duration:Float,additionalParams:Dynamic,onTweened:Void->Void)
	{
		var self = this;
		Actuate.tween(this, duration, additionalParams)
			.ease(Cubic.easeOut)
			.onComplete(function() {
				Actuate.update(function(params:Dynamic) {
					self.alpha = params.Alpha;
				}, 1.0, { Alpha: 1.0 }, { Alpha: 0.0 } ).onComplete(function() { self.destroy(); onTweened(); } );
			});
	}

}
