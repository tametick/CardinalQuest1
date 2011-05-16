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

	public override function update():Void {
		super.update();		
	}

	public function updateValue(?dmgTotal:Int = 0) { 
		
	}
}

class CqHealthBar extends CqVitalBar {

	public function new(Actor:CqActor, ?X:Float=0, ?Y:Float=0, ?Width:Float=0, ?Height:Float=0) {
		super(Actor, X, Y, Width, Height);
		actor.healthBar = this;
		setFrameColor(0xff444444);
		setInteriorColor(0xff000000);
		setBarColor(0xffff0000);
		setPercentToHp();
	}

	public override function updateValue(?dmgTotal:Int=0) {
		setPercentToHp();
		if ( !Std.is(actor, CqPlayer) ) {
			// todo: huh??? what does this check suppose to mean?
			if ( actor.hp >= actor.maxHp ) {
				visible = false;
			} else {
				visible = true;
			}
		}
	}
	
	private function setPercentToHp() {
		setPercent((actor.hp + actor.buffs.get("life")) / 
				   (actor.maxHp + actor.buffs.get("life")));
	}
	
}
