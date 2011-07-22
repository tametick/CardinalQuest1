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


class CqTextScroller extends HxlGroup {
	static var To_Y:Int = 10;
	static var Duration:Int = 10;
	static var MinimumDuration:Float = 0.3;
	
	public var scrolling:Bool;
	
	var withTitle:Bool;
	var cols:Array<HxlText>;
	var clicks:Int;
	var tweens:Array<GenericActuator>;
	var OnComplete:Void->Void;
	var minimumDuration:Float;
	var to_y:Int;
	var respondInput:Bool;//so you wouldnt accidentally close the window
	public function new(bg:Class<Bitmap>, scrollDuration:Float, ?Title:String = "", ?TitleColor:Int = 0xFFFFFF) {
		super();
		clicks = 0;
		scrolling = false;
		respondInput = false;
		cols = new Array<HxlText>();
		tweens = new Array<GenericActuator>();
		to_y = To_Y;
		minimumDuration = MinimumDuration;
		if(bg != null){
			var splash:HxlSprite = new HxlSprite(0, 0, bg);
			add(splash);
			//fullscreen stretch
			var sx:Float = HxlGraphics.stage.stageWidth/splash.width;
			var sy:Float = HxlGraphics.stage.stageHeight/splash.height;
			//( sx > sy ) ? sy = sx : sy = sx; //proportional scaling
			splash.x = (splash.width*sx)-splash.width;
			splash.scale = new HxlPoint(sx * 1.1, sy * 1.1);
		}
		if (Title.length > 0)
		{
			var titleTxt:HxlText = new HxlText(0, To_Y, 640, Title);
			titleTxt.setFormat(null, 72, TitleColor, "center");
			to_y += Std.int(titleTxt.height+10);
			add(titleTxt);
		}
		HxlGraphics.stage.addEventListener(MouseEvent.CLICK, onAction);
		HxlGraphics.stage.addEventListener(KeyboardEvent.KEY_UP, onAction);
	}
	public function setMinimumTime(value:Float):Void
	{
		minimumDuration = value;
	}
	private function afterMinimum() { respondInput = true; } 
	private function onAction(e:Event){
		if (!respondInput)
			return;
		if (clicks == 0)
		{
			finishTweens();
		}else
		{
			//end this
			HxlGraphics.stage.removeEventListener(MouseEvent.CLICK, onAction);
			HxlGraphics.stage.removeEventListener(KeyboardEvent.KEY_UP, onAction);
			if (OnComplete != null)
				OnComplete();
		}
		clicks++;
	}
	
	public function finishTweens() {
		if (cols.length == 0) 
			return;
		Actuate.pauseAll();
		scrolling = false;
		for (col in cols)
		{
			col.y = to_y;
		}
	}
	public function addColumn(X:Int, W:Int, text:String,?embeddedfont:Bool = true,?fontName:String = "",?fontSize:Int = 16,?color:Int = 0xFFFFFF) {
		var text:HxlText = new HxlText(X, 0, W, text, embeddedfont, fontName);
		text.setFormat(fontName, fontSize, color, "left");
		add(text);
		cols.push(text);
		text.y = HxlGraphics.stage.stageHeight;
	}
	public function startScroll(?PosY:Int = -1,?duration:Int = -1) {
		if (PosY != -1)
			to_y = PosY;
		if (duration != -1)
			Duration = duration;
		if (cols.length == 0) 
			return;
		Actuate.timer(minimumDuration).onComplete(afterMinimum);
		for (col in cols)
		{
			scrolling = true;
			tweens.push( Actuate.tween(col, Duration, { y:to_y } , true));
		}
	}
	
	public function onComplete(handler:Void->Void):Void {
		scrolling = false;
		OnComplete = handler;
	}
}