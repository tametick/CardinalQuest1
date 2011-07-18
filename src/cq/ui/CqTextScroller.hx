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
/**
 * ...
 * @author joris
 */

class CqTextScroller extends HxlGroup
{
	static var To_Y:Int = 10;
	inline static var Duration:Int = 10;
	inline static var MinimumDuration:Float = 0.3;
	
	var withTitle:Bool;
	var title:String;
	var cols:Array<HxlText>;
	var clicks:Int;
	var tweens:Array<GenericActuator>;
	var OnComplete:Void->Void;
	var to_y:Int;
	var respondInput:Bool;//so you wouldnt accidentally close the window
	public function new(bg:Class<Bitmap>, scrollDuration:Float, ?Title:String = "", ?TitleColor:Int = 0xFFFFFF) 
	{
		super();
		clicks = 0;
		respondInput = false;
		cols = new Array<HxlText>();
		tweens = new Array<GenericActuator>();
		title = Title;
		to_y = To_Y;
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
		if (title.length > 0)
		{
			var titleTxt:HxlText = new HxlText(0, To_Y, 640, Title);
			titleTxt.setFormat(null, 72, TitleColor, "center");
			to_y += Std.int(titleTxt.height+10);
			add(titleTxt);
		}
		Actuate.timer(MinimumDuration).onComplete(afterMinimum);
		HxlGraphics.stage.addEventListener(MouseEvent.CLICK, onAction);
		HxlGraphics.stage.addEventListener(KeyboardEvent.KEY_UP, onAction);
	}
	private function afterMinimum() { respondInput = true; } 
	private function onAction(e:Event):Void 
	{
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
	
	private function finishTweens():Void 
	{
		if (cols.length == 0) 
			return;
		Actuate.pauseAll();
		for (col in cols)
		{
			col.y = to_y;
		}
	}
	public function addColumn(X:Int, W:Int, text:String,?embeddedfont:Bool = true,?fontName:String = "",?fontSize:Int = 20,?color:Int = 0xFFFFFF)
	{
		var text:HxlText = new HxlText(X, 0, W, text, embeddedfont, fontName);
		text.setFormat(fontName, fontSize, color, "left");
		add(text);
		cols.push(text);
		text.y = HxlGraphics.stage.stageHeight;
	}
	public function startScroll()
	{
		if (cols.length == 0) 
			return;
		for (col in cols)
		{
			tweens.push( Actuate.tween(col, Duration, { y:to_y } , true));
		}
	}
	
	public function onComplete(handler:Void->Void):Void 
	{
		OnComplete = handler;
	}
}