package cq;
import world.Actor;
import world.Player;
import world.GameObject;

import com.eclecticdesignstudio.motion.Actuate;

class CqActor extends GameObjectImpl, implements Actor {
	public var moveSpeed:Float;	
	public function new(?X:Float, ?Y:Float) {
		super(X, Y);
		moveSpeed = 0.25;
	}
	
	public var isMoving:Bool;
	public function moveToPixel(X:Float, Y:Float):Void {
		isMoving = true;
		Actuate.tween(this, moveSpeed, { x: X, y: Y } ).onComplete(moveStop);
	}
	
	public function moveStop():Void {
		isMoving = false;
	}
}


class CqPlayer extends CqActor, implements Player {

}