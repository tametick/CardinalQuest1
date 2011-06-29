package cq;

import cq.CqActor;

import haxel.HxlUIBar;

class CqVitalBar extends HxlUIBar {

	var actor:CqActor;

	public function new(Actor:CqActor, ?X:Float=0, ?Y:Float=0, ?Width:Float=0, ?Height:Float=0,?isFollowingActor:Bool=true) {
		actor = Actor;
		super(X, Y, Width, Height);
		
		if(isFollowingActor){
			mount(actor);
		}
		
		scrollFactor.x = scrollFactor.y = 1;
		zIndex = 5;

		updateValue();
	}

	public override function update() {
		super.update();		
	}

	public function updateValue(?dmgTotal:Int = 0) { 
		
	}
}

class CqXpBar extends CqVitalBar {

	public function new(Player:CqPlayer, ?X:Float=0, ?Y:Float=0, ?Width:Float=0, ?Height:Float=0, ?isDefaultBar:Bool=true) {
		super(Player, X, Y, Width, Height,isDefaultBar);
		if(isDefaultBar){
			Player.xpBar = this;
		} else if (Std.is( actor, CqPlayer)) {
			var player = cast(actor, CqPlayer);
			player.infoViewXpBar = this;
		}
		
		setFrameColor(0xff444444);
		setInteriorColor(0xff000000);
		
		setBarColor(0xff59C65E);
		
		setPercentToXp();
		visible = true;

	}

	public override function updateValue(?xpTotal:Int=0) {
		setPercentToXp();
	}
	function setPercentToXp() {
		var player:CqPlayer = cast(actor, CqPlayer);
		var percent:Float = (player.xp - player.currentLevel()) / (player.nextLevel() - player.currentLevel());
		setPercent( percent );
	}
}


class CqHealthBar extends CqVitalBar {

	public function new(Actor:CqActor, ?X:Float = 0, ?Y:Float = 0, ?Width:Float = 0, ?Height:Float = 0, ?isDefaultBar:Bool=true) {
		super(Actor, X, Y, Width, Height,isDefaultBar);
		
		actor.addOnInjure(updateValue);
		actor.addOnDestroy(destroy);
		if(isDefaultBar){
			actor.healthBar = this;
		} else if (Std.is( actor, CqPlayer)) {
			var player = cast(actor, CqPlayer);
			player.infoViewHealthBar = this;
		}

		
		setFrameColor(0xff444444);
		setInteriorColor(0xff000000);
		setBarColor(0xffff0000);
		setPercentToHp();
	}

	public override function updateValue(?dmgTotal:Int=0) {
		setPercentToHp();
		if ( !Std.is(actor, CqPlayer) ) {
			// only show hp bar if mob is hurt
			if ( actor.hp >= actor.maxHp ) {
				visible = false;
			} else {
				visible = true;
			}
		}
	}
	
	function setPercentToHp() {
		setPercent((actor.hp + actor.buffs.get("life")) / 
				   (actor.maxHp + actor.buffs.get("life")));
	}
	
}
