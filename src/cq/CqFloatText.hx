package cq;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Cubic;

import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import haxel.HxlGraphics;
import haxel.HxlText;

class CqFloatText extends HxlText {

	public function new(X:Float, Y:Float, Text:String=null, ?Color:Int=0xffffff, ?FontSize:Int=18) {
		super(X, Y, 232, Text);
		setProperties(false, false, false);
		setFormat(null, FontSize, Color, "left", 0x010101);
		width =  _tf.getLineMetrics(0).width;
		_regen = true;
		calcFrame();
		x -= _pixels.width / 2;
		y -= _pixels.height / 2;
		var self = this;
		Actuate.tween(this, 0.8, {y: y - 20})
			.ease(Cubic.easeOut)
			.onComplete(function() {
				Actuate.update(function(params:Dynamic) {
					self.alpha = params.Alpha;
				}, 1.0, {Alpha: 1.0}, {Alpha: 0.0}).onComplete(function() { self.destroy(); });
			});
	}

}
