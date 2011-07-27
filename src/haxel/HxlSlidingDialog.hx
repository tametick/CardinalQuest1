package haxel;

import flash.media.Sound;
import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Quad;

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
	var showCallback:Dynamic;
	var hideCallback:Dynamic;
	var showSound:HxlSound;
	var hideSound:HxlSound;
	public var isBlockingInput:Bool;
	
	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?Direction:Int=0, ?IsBlockingInput=true)
	{
		super(X, Y, Width, Height);
		
		direction = Direction;
		dropSpeed = 0.3;
		isDropping = false;
		isDropped = false;
		visible = false;
		active = false;
		setHiddenPosition();
		showCallback = null;
		hideCallback = null;
		showSound = null;
		hideSound = null;
		isBlockingInput = IsBlockingInput;
	}
	
	private function setHiddenPosition() {
		switch (direction) {
			case TOP:
				y = 0 - height;
			case BOTTOM:
				y = HxlGraphics.height;
			case LEFT:
				x = 0 - width;
			case RIGHT:
				x = HxlGraphics.width;
		}
		targetX = x;
		targetY = y;
	}
	
	public function show(?ShowCallback:Dynamic=null) {
		if ( isDropped ) return;
		visible = true;
		active = true;
		var duration:Float = dropSpeed;
		if ( isDropping ) {
			switch (direction) {
				case TOP:
					duration = dropSpeed * Math.abs( Math.abs(0 - y) / height );
				case BOTTOM:
					duration = dropSpeed * Math.abs( Math.abs((HxlGraphics.height - height) - y) / height );
				case LEFT:
					duration = dropSpeed * Math.abs( Math.abs(0 - x) / width);
				case RIGHT:
					duration = dropSpeed * Math.abs( Math.abs((HxlGraphics.width - width) - x) / width );
			}
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
		if ( ShowCallback ) showCallback = ShowCallback;
		Actuate.stop(this, {}, false);
		Actuate.update(posTween, duration, { X: x, Y: y }, { X: targetX, Y: targetY } )
			.onComplete(shown)
			.ease(Quad.easeOut);
		if ( showSound != null ) showSound.play();
	}
	
	/** override this to do special updating before showing the dialog */
	public function updateDialog() {
		
	}
	
	public function hide(?HideCallback:Dynamic=null) {
		if ( !visible ) return;
		active = true;
		var duration:Float = dropSpeed;
		if ( isDropping ) {
			switch (direction) {
				case TOP:
					duration = dropSpeed * Math.abs( Math.abs((0-height) - y) / height );
				case BOTTOM:
					duration = dropSpeed * Math.abs( Math.abs((HxlGraphics.height - height) - y) / height );
				case LEFT:
					duration = dropSpeed * Math.abs( Math.abs((0-width) - x) / width);
				case RIGHT:
					duration = dropSpeed * Math.abs( Math.abs((HxlGraphics.width - width) - x) / width );
			}
		}
		duration = duration * 0.5;
		isDropping = true;
		isDropped = false;
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
		if ( HideCallback ) hideCallback = HideCallback;
		Actuate.stop(this, {}, false);
		Actuate.update(posTween, duration, { X: x, Y: y }, { X: targetX, Y: targetY } ).onComplete(hidden);
		if ( hideSound != null ) hideSound.play();
	}

	private function posTween(params:Dynamic) {
		targetX = params.X;
		targetY = params.Y;
	}
	
	private function shown() {
		isDropping = false;
		isDropped = true;
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
		if ( showCallback ) {
			showCallback();
			showCallback = null;
		}
	}
	
	private function hidden() {
		isDropping = false;
		isDropped = false;
		visible = false;
		active = false;
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
		if ( hideCallback ) {
			hideCallback();
			//hideCallback = null;
		}
	}

	public override function update() {
		super.update();
	}

	public function setShowCallback(ShowCallback:Dynamic) {
		showCallback = ShowCallback;
	}
	public function setHideCallback(HideCallback:Dynamic) {
		hideCallback = HideCallback;
	}

	public function setHideSound(HideSound:Class<Sound>):HxlSound {
		if ( hideSound == null ) hideSound = new HxlSound();
		hideSound.loadEmbedded(HideSound, false);
		return hideSound;
	}

	public function setShowSound(ShowSound:Class<Sound>):HxlSound {
		if ( showSound == null ) showSound = new HxlSound();
		showSound.loadEmbedded(ShowSound, false);
		return showSound;
	}

}
