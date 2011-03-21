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
	var dropX:Float;
	var dropY:Float;
	
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
		dropX = x;
		dropY = y;
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
		var targetX:Float = x;
		var targetY:Float = y;
		switch (direction) {
			case TOP:
				targetY = 0;
			case BOTTOM:
				targetY = HxlGraphics.height - height;
			case LEFT:
				targetX = 0;
			case RIGHT:
				targetX = HxlGraphics.width - width;
		}
		Actuate.update(posTween, duration, { X: x, Y: y }, { X: targetX, Y: targetY } ).onComplete(shown);
	}
	
	public function hide():Void {
		if ( !visible ) return;
		active = true;
		var duration:Float = dropSpeed;
		isDropping = true;
		var targetX:Float = x;
		var targetY:Float = y;
		switch (direction) {
			case TOP:
				targetY = 0 - height;
			case BOTTOM:
				targetY = HxlGraphics.height + height;
			case LEFT:
				targetX = 0 - width;
			case RIGHT:
				targetX = HxlGraphics.width + width;
		}
		Actuate.update(posTween, duration, { X: x, Y: y }, { X: targetX, Y: targetY } ).onComplete(hidden);
	}

	private function posTween(params:Dynamic):Void {
		dropX = params.X;
		dropY = params.Y;
	}
	
	private function shown() {
		isDropping = false;
		isDropped = true;
		switch (direction) {
			case TOP:
				dropY = 0;
			case BOTTOM:
				dropY = HxlGraphics.height - height;
			case LEFT:
				dropX = 0;
			case RIGHT:
				dropX = HxlGraphics.width - width;
		}
	}
	
	private function hidden() {
		isDropping = false;
		isDropped = false;
		visible = false;
		active = false;
		switch (direction) {
			case TOP:
				dropY = 0 - height;
			case BOTTOM:
				dropY = HxlGraphics.height + height;
			case LEFT:
				dropX = 0 - width;
			case RIGHT:
				dropX = HxlGraphics.width + width;
		}
	}

	public override function update():Void {
		saveOldPosition();
		if ( x != dropX || y != dropY ) {
			x = dropX;
			y = dropY;
		}
		updateMotion();
		updateMembers();
	}
}
