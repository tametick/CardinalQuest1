package cq;

import cq.CqActor;

import haxel.HxlUIBar;

class CqVitalBar extends HxlUIBar {

	var actor:CqActor;

	public function new(Actor:CqActor, ?X:Float=0, ?Y:Float=0, ?Width:Float=0, ?Height:Float=0) {
		actor = Actor;
		super(X, Y, Width, Height);
		scrollFactor.x = scrollFactor.y = 1;
		zIndex = 5;
		mount(Actor);
		Actor.addOnInjure(updateValue);
		Actor.addOnKill(destroy);
		Actor.addOnDestroy(destroy);
		updateValue();
	}

	public function updateValue(?dmgTotal:Int=0):Void {
		setPercent(actor.hp / actor.maxHp);
		if ( !Std.is(actor, CqPlayer) ) {
			if ( actor.hp >= actor.maxHp ) {
				visible = false;
			} else {
				visible = true;
			}
		}
	}

	public override function update():Void {
		super.update();		
	}

}

class CqHealthBar extends CqVitalBar {

	public function new(Actor:CqActor, ?X:Float=0, ?Y:Float=0, ?Width:Float=0, ?Height:Float=0) {
		super(Actor, X, Y, Width, Height);
		setFrameColor(0xff444444);
		setInteriorColor(0xff000000);
		setBarColor(0xffff0000);
		setPercent(1.0);
	}

}
