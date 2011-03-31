package cq;

import haxel.HxlLog;
import world.Mob;

import world.Actor;
import world.Player;
import world.GameObject;

import data.Registery;

import cq.CqResources;
import cq.CqItem;

import com.eclecticdesignstudio.motion.Actuate;

class CqActor extends GameObjectImpl, implements Actor {
	public var moveSpeed:Float;	
	public var visionRadius:Float;
	
	var attack:Int;
	var defense:Int;
	var faction:Int;
	var weapon:CqWeapon;
	
	// changes to basic abilities (attack, defense, speed, spirit) caused by equipped items or spells
	var buffs:Hash<Int>;
	// special effects caused by magical items or spells
	var specialEffects:Hash<Dynamic>;
	
	public function new(?X:Float=-1, ?Y:Float=-1,?attack:Int=1,?defense:Int=1) {
		super(X, Y);
		moveSpeed = 0.25;
		visionRadius = 8.2;
		this.attack = attack;
		this.defense = defense;
		buffs = new Hash<Int>();
		specialEffects = new Hash();
	}
	
	public var isMoving:Bool;
	public function moveToPixel(X:Float, Y:Float):Void {
		isMoving = true;
		Actuate.tween(this, moveSpeed, { x: X, y: Y } ).onComplete(moveStop);
	}
	
	public function moveStop():Void {
		isMoving = false;
	}
	
	public function attackOther(other:Actor) {
		var other = cast(other, CqActor);
		
		// attack & defense buffs
		var atk = Math.max(attack + buffs.get("attack"), 1);
		var def = Math.max(other.defense + other.buffs.get("defense"), 1);

		if (Math.random() < atk / (atk + def)) {
			// Hit
			/*
			if ( faction > 0 && vars.special != undefined && Math.random() <= 0.25 ) {
				// Use my special rather than apply attack damage
				Special()[vars.special](this);
				if(vars.special == "berserk")
					messageLog.append("<b style='color: rgb("+vars.color.join()+");'>"+vars.description[0]+"</b> <i>"+vars.special+"s</i>!");
				else
					messageLog.append("<b style='color: rgb("+vars.color.join()+");'>"+vars.description[0]+"</b> <i>"+vars.special+"s</i> you!");
				return;
			}
/*
			var dmgMultipler = 1;
			if(vars.buffs && vars.buffs.damageMultipler && vars.buffs.damageMultipler!=0)
				dmgMultipler = vars.buffs.damageMultipler * 1;

			if (vars.weapon && vars.weapon.wielded.length > 0) {
				// With weapon
				var damageRange = vars.weapon.wielded[0].vars.damage;

				other.vars.life -= utils.randInt(damageRange[0] * dmgMultipler, damageRange[1] * dmgMultipler);
			} else {
				// With natural attack
				other.vars.life -= utils.randInt(vars.damage[0] * dmgMultipler, vars.damage[1] * dmgMultipler);
			}
			
			// life buffs
			var lif = other.vars.life + (other.vars.buffs ? (other.vars.buffs.life ? other.vars.buffs.life : 0) : 0);
			
			if (lif > 0)
				injure(other);
			else
				kill(other);
*/
		} else {
			// Miss
			if (this == cast(Registery.player,CqPlayer)) {
				HxlLog.append("You miss");//<b style='color: rgb("+other.vars.color.join()+");'>"+other.vars.description[0]+"</b>.");
			} else {
				HxlLog.append("Misses you");//"<b style='color: rgb("+vars.color.join()+");'>"+vars.description[0]+"</b> misses you.");
			}
		}
	}
}


class CqPlayer extends CqActor, implements Player {
	public function new(playerClass:CqClass, ?X:Float=-1, ?Y:Float=-1) {
		super(X, Y);
		loadGraphic(SpritePlayer, true, false, 16, 16, false, 2.0, 2.0);
		faction = 0;
		
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

class CqMob extends CqActor, implements Mob {
	public function new(mobType:CqMobType, ?X:Float=-1, ?Y:Float=-1) {
		super(X, Y);
		loadGraphic(SpriteMonsters, true, false, 16, 16, false, 2.0, 2.0);
		faction = 1;
		
		var sprites = new SpriteMonsters();
		switch(CqMobType) {

		}
		//play("idle");
	}
}

enum CqClass {
	FIGHTER;
	WIZARD;
	THIEF;
}

enum CqMobType {
	KOBOLD;
	BANDIT;
	SUCCUBUS;
	GIANT_SPIDER;
	WEREWOLF;
	MINOTAUR;
}