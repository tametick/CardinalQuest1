package cq;
import world.Actor;
import world.Player;
import world.GameObject;

import cq.CqResources;

import com.eclecticdesignstudio.motion.Actuate;

class CqActor extends GameObjectImpl, implements Actor {
	public var moveSpeed:Float;	
	public var visionRadius:Float;
	public function new(?X:Float=-1, ?Y:Float=-1) {
		super(X, Y);
		moveSpeed = 0.25;
		visionRadius = 5.2;
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
	public function new(playerClass:CqClass, ?X:Float=-1, ?Y:Float=-1) {
		super(X, Y);
		loadGraphic(SpritePlayer, true, false, 16, 16, false, 2.0, 2.0);
		
		var sprites = new SpritePlayer();
		switch(playerClass) {
			case FIGHTER:
				addAnimation("idle", [sprites.getSpriteIndex("fighter")], 0 );
			case WIZARD:
				addAnimation("idle", [sprites.getSpriteIndex("wizard")], 0 );
			case THIEF:
				addAnimation("idle", [sprites.getSpriteIndex("thief")], 0 );
		}
		play("idle");
	}
}

enum CqClass {
	FIGHTER;
	WIZARD;
	THIEF;
}