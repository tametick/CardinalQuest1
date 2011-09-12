package cq.ui;

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
			.onComplete(onCompleteCallBack);
	}
	
	function onCompleteCallBack():Void 
	{
		Actuate.update(onCompleteUpdate, 1.0, {Alpha: 1.0}, {Alpha: 0.0}).onComplete(onCompleteSecondCallBack);
	}
	function onCompleteUpdate(params:Dynamic)
	{
		alpha = params.Alpha;
	}
	function onCompleteSecondCallBack()
	{
		destroy();
	}
	var onTweened:Void->Void;
	public function InitSemiCustomTween(duration:Float,additionalParams:Dynamic,onTweened:Void->Void)
	{
		this.onTweened = onTweened;
		Actuate.tween(this, duration, additionalParams)
			.ease(Cubic.easeOut)
			.onComplete(onCompleteTweenCallBack);
	}
	function onCompleteTweenCallBack()
	{
		Actuate.update(onCompleteFadeOutCallBack, 0.5, { Alpha: 1.0 }, { Alpha: 0.0 } ).onComplete(onFadedOutCallBack );
	}
	function onCompleteFadeOutCallBack(params:Dynamic)
	{
		alpha = params.Alpha;
	}
	function onFadedOutCallBack() {
		destroy();
		onTweened();
	}

}
