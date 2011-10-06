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
	var splash:HxlSprite;
	var titleText:HxlText; 
	
	var withTitle:Bool;
	var cols:Array<HxlText>;
	var clicks:Int;
	var tweens:Array<IGenericActuator>;
	var tweenStatus:Array<Bool>;
	var OnComplete:Void->Void;
	var minimumDuration:Float;
	var to_y:Int;
	var respondInput:Bool;//so you wouldnt accidentally close the window
	public function new(bg:Class<Bitmap>, scrollDuration:Float, ?Title:String = "", ?TitleColor:Int = 0xFFFFFF, ?ShadowColor:Int = 0x010101, ?scale:Float=1.0) {
		super();
		clicks = 0;
		scrolling = false;
		respondInput = false;
		cols = new Array<HxlText>();
		tweens = new Array<IGenericActuator>();
		tweenStatus = new Array<Bool>();
		to_y = To_Y;
		minimumDuration = MinimumDuration;
		setSplash(bg,scale);
		setTitle(Title, TitleColor, ShadowColor);
		
		HxlGraphics.stage.addEventListener(MouseEvent.CLICK, onAction);
		HxlGraphics.stage.addEventListener(KeyboardEvent.KEY_UP, onAction);
	}
	
	public function setSplash(bg:Class<Bitmap>, ?scale:Float=1.0):Void {
		if (splash != null)
			remove(splash);
		
		if(bg != null){
			splash = new HxlSprite(0, 0, bg);
			add(splash);
			//fullscreen stretch
			var sx:Float = scale * HxlGraphics.stage.stageWidth/splash.width;
			var sy:Float = scale * HxlGraphics.stage.stageHeight/splash.height;
			//( sx > sy ) ? sy = sx : sy = sx; //proportional scaling
			splash.x = scale*((splash.width*sx)-splash.width);
			splash.scale = new HxlPoint(sx * 1.1, sy * 1.1);
		}
	}
	
	public function setTitle(?Title:String = "", ?TitleColor:Int = 0xFFFFFF, ?ShadowColor:Int = 0x010101):Void {
		if (titleText != null)
			remove(titleText);
		
		if (Title.length > 0)		{
			titleText = new HxlText(0, To_Y, 640, Title);
			titleText.setFormat(null, 72, TitleColor, "center",ShadowColor);
			to_y += Std.int(titleText.height+10);
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
		if (clicks == 0)
		{
			finishTweens();
		} else {
			//end this
			HxlGraphics.stage.removeEventListener(MouseEvent.CLICK, onAction);
			HxlGraphics.stage.removeEventListener(KeyboardEvent.KEY_UP, onAction);
			
			if (splash != null) {
				remove(splash);
				splash = null;
			}
			
			if (OnComplete != null)
				OnComplete();
		}
		clicks++;
	}
	
	public function finishTweens() {
		if (cols.length == 0) 
			return;
		Actuate.pauseAll();
		clicks++;
		scrolling = false;
		for (col in cols)
		{
			col.y = to_y;
		}
	}
	public function addColumn(X:Int, W:Int, text:String,?embeddedfont:Bool = true,?fontName:String = "",?fontSize:Int = 16,?color:Int = 0xFFFFFF, ?shadowColor:Int = 0x010101) {
		var text:HxlText = new HxlText(X, 0, W, text, embeddedfont, fontName);
		text.setFormat(fontName, fontSize, color, "left",shadowColor);
		add(text);
		cols.push(text);
		tweenStatus.push(false);
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
			tweens.push( Actuate.tween(col, Duration, { y:to_y } , true).onComplete(oncolumnScrolled,[col]));
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
		
	public function onComplete(handler:Void->Void):Void {
		scrolling = false;
		OnComplete = handler;
	}
}