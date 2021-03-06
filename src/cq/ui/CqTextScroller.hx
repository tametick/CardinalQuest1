package cq.ui;
import com.eclecticdesignstudio.motion.easing.Cubic;
import com.eclecticdesignstudio.motion.easing.Linear;
import flash.display.Bitmap;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import haxel.HxlGraphics;
import haxel.HxlGroup;
import haxel.HxlPoint;
import haxel.HxlSprite;
import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.actuators.GenericActuator;
import haxel.HxlText;

import data.Configuration;


class CqTextScroller extends HxlGroup {
	static var Duration:Int = 10;
	static var MinimumDuration:Float = 0.3;
	
	public var scrolling:Bool;
	var splash:HxlSprite;
	var titleText:HxlText; 
	
	var withTitle:Bool;
	var cols:Array<HxlText>;
	var clicks:Int;
	var tweens:Array<IGenericActuator>;
	var tweenStatus:Array<Bool>;
	var OnComplete:Void->Void;
	var WhileScrolling:Array < Void->Void > ;
	var minimumDuration:Float;

	var columns_height:Int;
	var initial_y:Int;
	var final_y:Int;
	
	var respondInput:Bool;//so you won't accidentally close the window
	public function new(bg:Class<Bitmap>, scrollDuration:Float, ?Title:String = "", ?TitleColor:Int = 0xFFFFFF, ?ShadowColor:Int = 0x010101, ?scale:Float=1.0) {
		super();
		clicks = 0;
		scrolling = false;
		respondInput = false;
		cols = new Array<HxlText>();
		tweens = new Array<IGenericActuator>();
		tweenStatus = new Array<Bool>();
	
		// default
		initial_y = HxlGraphics.stage.stageHeight;
		final_y = 0;
		columns_height = 0;
		
		minimumDuration = MinimumDuration;
		setSplash(bg, scale);
		setTitle(Title, TitleColor, ShadowColor);
		
		HxlGraphics.stage.addEventListener(MouseEvent.CLICK, onAction);
		HxlGraphics.stage.addEventListener(KeyboardEvent.KEY_UP, onAction);
		
		WhileScrolling = [];
	}
	
	public function setSplash(bg:Class<Bitmap>, ?scale:Float=1.0):Void {
		if (splash != null)
			remove(splash);
		
		if(bg != null){
			splash = new HxlSprite(0, 0, bg);
			add(splash);
			splash.scaleFullscreen();
		}
	}
	
	public function setTitle(?Title:String = "", ?TitleColor:Int = 0xFFFFFF, ?ShadowColor:Int = 0x010101):Void {
		if (titleText != null)
			remove(titleText);
		
		if (Title.length > 0) {
			titleText = new HxlText(0, 0, Configuration.app_width, Title);
			titleText.setFormat(null, 72, TitleColor, "center", ShadowColor);
			
			add(titleText);
		}
	}	
	
	
	public function setMinimumTime(value:Float):Void
	{
		minimumDuration = value;
	}
	private function afterMinimum() { respondInput = true; } 
	private function onAction(e:Event){
		if (!respondInput)
			return;
			
		if (clicks == 0) {
			finishTweens();
		} else {
			//end this
			HxlGraphics.stage.removeEventListener(MouseEvent.CLICK, onAction);
			HxlGraphics.stage.removeEventListener(KeyboardEvent.KEY_UP, onAction);
			
			if (splash != null) {
				remove(splash);
				splash = null;
			}
			
			callWhileScrolling(true);
			if (OnComplete != null) OnComplete();
		}
		clicks++;
	}

	public function addColumn(X:Int, W:Int, text:String, ?embeddedfont:Bool = true, ?fontName:String = "", ?fontSize:Int = 16, ?color:Int = 0xFFFFFF, ?shadowColor:Int = 0x010101) {
		if (HxlGraphics.width != 640) { // the scroller is hardcoded to 640, so if we're at a different resolution, scale it
			X = Math.floor(X * HxlGraphics.width / 640);
			W = Math.floor(W * HxlGraphics.width / 640);
			
			if (HxlGraphics.width <= 480) {
				fontSize -= 2; // for small screens, shrink the font and make some extra room!
				
				X -= 25;
				W += 50;
			}
		}
		
		var text:HxlText = new HxlText(X, initial_y, W, text, embeddedfont, fontName);
		text.setFormat(fontName, fontSize, color, "left", shadowColor);
		
		if (text.height > columns_height) {
			columns_height = Std.int(text.height);
		}
		
		add(text);
		cols.push(text);
		tweenStatus.push(false);
	}
	public function startScroll(?duration:Int = -1) {
		if (duration > 0)
			Duration = duration;
			
		if (cols.length == 0) 
			return;
			
		Actuate.timer(minimumDuration).onComplete(afterMinimum);
		for (col in cols) {
			var to_y:Int = Std.int((HxlGraphics.stage.stageHeight - col.height) / 2);
			
			scrolling = true;
			tweens.push(
				Actuate.tween(col, Duration, { y:to_y } , true)
					.onUpdate(callWhileScrolling)
					.onComplete(oncolumnScrolled, [col]
				)
			);
		}
	}
	
	private function oncolumnScrolled(column:HxlText):Void 	{
		var allFinished:Bool = true;
		for (i in 0...cols.length)
		{
			if (cols[i] == column) tweenStatus[i] = true;
			if (tweenStatus[i] == false) allFinished = false;
		}
		if (allFinished) finishTweens();
	}
	
	public function finishTweens() {
		if (cols.length == 0) 
			return;
		Actuate.pauseAll();
		clicks++;
		scrolling = false;
		
		for (col in cols) {
			var to_y:Int = Std.int((HxlGraphics.stage.stageHeight - col.height) / 2);
			
			col.y = to_y;
		}
		
		// give flash a moment to refresh the text before continuing
		Actuate.timer(.01).onComplete(callWhileScrolling, [true]);
	}	
		
	public function onComplete(handler:Void->Void):Void {
		scrolling = false;
		OnComplete = handler;
	}
	
	private function callWhileScrolling(?finishUp:Bool = false) {
		while (WhileScrolling.length > 0) {
			if (finishUp) { // || Math.random() < .05) { // 
				var cb = WhileScrolling[0];
				WhileScrolling.splice(0, 1);
				cb();
			}
			if (!finishUp) break;
		}
	}
	
	public function whileScrolling(calls:Array<Void->Void>):Void {
		for (fn in calls) {
			WhileScrolling.push(fn);
		}
	}
}