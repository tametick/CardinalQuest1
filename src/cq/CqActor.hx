package cq;

import haxel.HxlLog;
import haxel.HxlUtil;

import world.Mob;
import world.Actor;
import world.Player;
import world.GameObject;

import data.Registery;

import cq.CqResources;
import cq.CqItem;

import com.eclecticdesignstudio.motion.Actuate;


class CqObject extends GameObjectImpl {
}

class CqActor extends CqObject, implements Actor {
	public var moveSpeed:Float;	
	public var visionRadius:Float;
	
	var attack:Int;
	var defense:Int;
	var faction:Int;
	
	// natural damage without weapon
	var damage:Range;
	
	var equippedWeapon:CqWeapon;
	var equippedSpell:CqSpell;
	
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
		initBuffs();
		specialEffects = new Hash();
	}
	
	function initBuffs(){
		var buffs = new Hash<Int>();
		buffs.set("attack",0);
		buffs.set("defense",0);
		buffs.set("damageMultipler", 1);
		buffs.set("life", 0);
	}
	
	public var isMoving:Bool;
	public function moveToPixel(X:Float, Y:Float):Void {
		isMoving = true;
		Actuate.tween(this, moveSpeed, { x: X, y: Y } ).onComplete(moveStop);
	}
	
	public function moveStop():Void {
		isMoving = false;
	}
	
	function attackObject(other:CqObject) {
		// todo = bust chests
	}
	
	function injureActor(other:CqActor) {
	}
	
	function killActor(other:CqActor) {
	}

	public function attackOther(other:GameObject) {
		if (!Std.is(other, CqActor)){
			attackObject(cast(other, CqObject));
			return;
		}
		var other = cast(other, CqActor);
		
		// attack & defense buffs
		var atk = Math.max(attack + buffs.get("attack"), 1);
		var def = Math.max(other.defense + other.buffs.get("defense"), 1);

		if (Math.random() < atk / (atk + def)) {
			// Hit

			if ( Std.is(other,CqMob) && other.equippedSpell!=null && Math.random() <= 0.25 ) {
				// Use my spell rather than apply attack damage
			  /*Special()[vars.special](this);
				if(vars.special == "berserk")
					messageLog.append("<b style='color: rgb("+vars.color.join()+");'>"+vars.description[0]+"</b> <i>"+vars.special+"s</i>!");
				else
					messageLog.append("<b style='color: rgb("+vars.color.join()+");'>"+vars.description[0]+"</b> <i>"+vars.special+"s</i> you!");
				return;*/
			}

			var dmgMultipler = buffs.get("damageMultipler");

			if (equippedWeapon!=null) {
				// With weapon
				var damageRange = equippedWeapon.damage;
				other.hp -= HxlUtil.randomIntInRange(damageRange.start * dmgMultipler, damageRange.end * dmgMultipler);
			} else {
				// With natural attack
				other.hp -= HxlUtil.randomIntInRange(damage.start * dmgMultipler, damage.end * dmgMultipler);
			}
			
			// life buffs
			var lif = other.hp + other.buffs.get("life");
			
			if (lif > 0)
				injureActor(other);
			else
				killActor(other);

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
		
		// fixme - use static method
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