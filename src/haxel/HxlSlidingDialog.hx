package haxel;

import com.eclecticdesignstudio.motion.Actuate;

class HxlSlidingDialog extends HxlDialog
{

	public static var TOP:Int = 0;
	public static var RIGHT:Int = 1;
	public static var BOTTOM:Int = 2;
	public static var LEFT:Int = 3;
	
	var direction:Int;
	var dropSpeed:Float;
	var isDropping:Bool;
	var isDropped:Bool;
	
	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?Direction:Int=0)
	{
		super(X, Y, Width, Height);
		
		direction = Direction;
		dropSpeed = 0.3;
		isDropping = false;
		isDropped = false;
		visible = false;
		active = false;
		setHiddenPosition();
	}
	
	private function setHiddenPosition():Void {
		switch (direction) {
			case TOP:
				y = 0 - height;
			case BOTTOM:
				y = HxlGraphics.height + height;
			case LEFT:
				x = 0 - width;
			case RIGHT:
				x = HxlGraphics.width + width;
		}
		reset(x, y);		
	}
	
	public function show():Void {
		if ( isDropping || isDropped ) return;
		visible = true;
		active = true;
		var duration:Float = dropSpeed;
		if ( isDropping ) {
			switch (direction) {
				case TOP:
					duration = (y / -height);
			}
			trace(duration);
		}
		isDropping = true;
		//Actuate.tween(this, duration, { y: 0 } ).onComplete(shown);
		Actuate.update(posTween, duration, { X: x, Y: y }, { X: x, Y: 0 } ).onComplete(shown);
	}
	
	public function hide():Void {
		if ( !visible ) return;
		active = true;
		var duration:Float = dropSpeed;
		isDropping = true;
		//Actuate.tween(this, duration, { y: -height } ).onComplete(hidden);
		Actuate.update(posTween, duration, { X: x, Y: y }, { X: x, Y: -height } ).onComplete(hidden);
	}

	private function posTween(params:Dynamic):Void {
		x = params.X;
		y = params.Y;
		//reset(x, y);
		HxlGraphics.log("X: " + x + ", Y: " + y);
	}
	
	private function shown() {
		trace("x: " + x + ", y: " + y);
		trace("width: " + width + ", height: " + height);
		isDropping = false;
		isDropped = true;
	}
	
	private function hidden() {
		isDropping = false;
		isDropped = false;
		visible = false;
		active = false;
	}
}