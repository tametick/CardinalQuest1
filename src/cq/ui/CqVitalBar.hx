package cq.ui;

import cq.CqActor;

import data.Registery;

import haxel.HxlUIBar;

enum BarType {
	DEFAULT;
	INFO;
	CENTRAL;
}

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
	
	override public function destroy() 	{
		super.destroy();
		actor = null;
	}
}

class CqXpBar extends CqVitalBar {

	public function new(Player:CqPlayer, ?X:Float=0, ?Y:Float=0, ?Width:Float=0, ?Height:Float=0, ?barType:BarType) {
		if (barType == null)
			barType = DEFAULT;
		
		super(Player, X, Y, Width, Height,barType==BarType.DEFAULT);
		if (Std.is( actor, CqPlayer)) {
			var player = cast(actor, CqPlayer);
			if(barType==BarType.INFO)
				player.infoViewXpBar = this;
			else
				player.centralXpBar = this;
			player = null;
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
		var player:CqPlayer = Registery.player;
		var percent:Float = (player.xp - player.currentLevel()) / (player.nextLevel() - player.currentLevel());
		setPercent( percent );
		
		player = null;
	}
}


class CqHealthBar extends CqVitalBar {

	public function new(Actor:CqActor, ?X:Float = 0, ?Y:Float = 0, ?Width:Float = 0, ?Height:Float = 0, ?barType:BarType) {
		if (barType == null)
			barType = DEFAULT;
		
		super(Actor, X, Y, Width, Height,barType==BarType.DEFAULT);
		
		actor.addOnInjure(updateValue);
		
		// actor already destroys bars by itself
		//actor.addOnDestroy(destroy);
		
		if(barType==BarType.DEFAULT){
			actor.healthBar = this;
		} else if (Std.is( actor, CqPlayer)) {
			var player = cast(actor, CqPlayer);
			if(barType==BarType.INFO)
				player.infoViewHealthBar = this;
			else
				player.centralHealthBar = this;
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
	
	public function setPercentToHp() {
		if (actor.hp + actor.buffs.get("life") == 0)
			// fixme - should not happen
			visible = false;
		
		setPercent((actor.hp + actor.buffs.get("life")) / 
				   (actor.maxHp + actor.buffs.get("life")));
	}
	
}
