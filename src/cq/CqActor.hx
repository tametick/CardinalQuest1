package cq;

import haxel.HxlLog;
import haxel.HxlState;
import haxel.HxlUtil;
import haxel.HxlPoint;

import world.Mob;
import world.Actor;
import world.Player;
import world.GameObject;

import data.Registery;
import data.Configuration;

import cq.CqResources;
import cq.CqItem;
import cq.CqWorld;

import com.eclecticdesignstudio.motion.Actuate;

class CqActor extends CqObject, implements Actor {
	public var isMoving:Bool;
	public var moveSpeed:Float;	
	public var visionRadius:Float;
	public var faction:Int;
	
	public var actionPoints:Int;
	
	var attack:Int;
	var defense:Int;
	var damage:Range;// natural damage without weapon
	var speed:Int;
	
	var equippedWeapon:CqWeapon;
	var equippedSpell:CqSpell;
	
	// changes to basic abilities (attack, defense, speed, spirit) caused by equipped items or spells
	var buffs:Hash<Int>;
	// special effects caused by magical items or spells
	var specialEffects:Hash<Dynamic>;
	
	public function new(X:Float, Y:Float,attack:Int,defense:Int,damage:Range,speed:Int) {
		super(X, Y);
		actionPoints = 0;
		moveSpeed = 0.15;
		visionRadius = 8.2;
		this.attack = attack;
		this.defense = defense;
		this.damage = damage;
		this.speed = speed;
		initBuffs();
		specialEffects = new Hash();
	}
	
	function initBuffs(){
		buffs = new Hash<Int>();
		buffs.set("attack",0);
		buffs.set("defense",0);
		buffs.set("damageMultipler", 1);
		buffs.set("life", 0);
		buffs.set("speed",0);
	}
	
	public function moveToPixel(X:Float, Y:Float):Void {
		isMoving = true;
		Actuate.tween(this, moveSpeed, { x: X, y: Y } ).onComplete(moveStop);
	}
	
	public function moveStop():Void {
		isMoving = false;
	}
	
	public function attackObject(state:HxlState, other:GameObject) {
		var chest = cast(other, CqChest);
		chest.bust(state);
	}
	
	function injureActor(other:CqActor) {
		if (this == cast(Registery.player,CqPlayer)) {
			HxlLog.append("You hit");
			trace("You hit");
		} else {
			HxlLog.append("Hit you");
			trace("Hit you");
		}
	}
	
	function gainExperience(other:CqActor) {
		//todo
	}
	
	function killActor(state:HxlState, other:CqActor) {
		// todo
		if (this == cast(Registery.player, CqPlayer)) {
			var mob = cast(other, CqMob);
			
			HxlLog.append("You kill");
			trace("You kill");
			gainExperience(mob);
			// remove other
			Registery.world.currentLevel.removeMobFromLevel(state, mob);
		} else {
			HxlLog.append("kill you");
			trace("kill you");
		}
	}

	public function attackOther(state:HxlState, other:GameObject) {
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
				killActor(state,other);

		} else {
			// Miss
			if (this == cast(Registery.player,CqPlayer)) {
				HxlLog.append("You miss");//<b style='color: rgb("+other.vars.color.join()+");'>"+other.vars.description[0]+"</b>.");
				trace("You miss");
			} else {
				HxlLog.append("Misses you");//"<b style='color: rgb("+vars.color.join()+");'>"+vars.description[0]+"</b> misses you.");
				trace("Misses you");
			}
		}
	}
	
	public function act(state:HxlState, targetTile:HxlPoint) {
		var world = Registery.world;
		var tile = cast(world.currentLevel.getTile(tilePos.x + targetTile.x,  tilePos.y + targetTile.y),CqTile);
		
		if (tile.actors.length > 0) {
			var other = cast(tile.actors[tile.actors.length - 1],CqActor);
			
			// attack enemy actor
			if(other.faction != faction) {
				attackOther(state, other);
			}
			
			// end turn
			return;
		} else if (tile.loots.length > 0 && Std.is(this,CqPlayer)) {
			var loot = tile.loots[tile.loots.length - 1];
			if (Std.is(loot, CqChest)) {
				// bust chest & don't move
				attackObject(state, loot);
				
				// end turn
				return;
			} else {
				// pickup item
				var item = cast(loot, CqItem);
				cast(this,CqPlayer).pickup(state,item);
			}
		}
		
		isMoving = true;
		setTilePos(new HxlPoint(tilePos.x + targetTile.x, tilePos.y + targetTile.y));
		var positionOfTile:HxlPoint = world.currentLevel.getPixelPositionOfTile(Math.round(tilePos.x), Math.round(tilePos.y));
		moveToPixel(positionOfTile.x, positionOfTile.y);
	}
}


class CqPlayer extends CqActor, implements Player {
	// fixme - use static method
	static var sprites = SpritePlayer.instance;
	
	public var inventory:Array<CqItem>;
	var pickupCallback:Dynamic;
	
	public function new(playerClass:CqClass, ?X:Float=-1, ?Y:Float=-1) {
		// fixme - correct attributes
		super(X, Y,1,1,new Range(1,1),5);
		loadGraphic(SpritePlayer, true, false, Configuration.tileSize, Configuration.tileSize, false, 2.0, 2.0);
		faction = 0;
		inventory = new Array<CqItem>();
		
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
	
	public function setPickupCallback(Callback:Dynamic):Void {
		pickupCallback = Callback;
	}

	public function pickup(state:HxlState, item:CqItem) {
		// remove item from map
		Registery.world.currentLevel.removeLootFromLevel(state, item);
		
		// add to actor inventory
		inventory.push(item);

		// perform pickup callback function (if set)
		if ( pickupCallback != null ) pickupCallback(item);
	}
	
}

class CqMob extends CqActor, implements Mob {
	static var sprites = SpriteMonsters.instance;
	public var type:CqMobType;
	
	public function new(X:Float, Y:Float, typeName:String) {
		// fixme - correct attribute according to typename
		super(X, Y,1,1,new Range(1,1),5);
		loadGraphic(SpriteMonsters, true, false, Configuration.tileSize, Configuration.tileSize, false, Configuration.zoom, Configuration.zoom);
		faction = 1;
		type = Type.createEnum(CqMobType,  typeName.toUpperCase());
		addAnimation("idle", [sprites.getSpriteIndex(typeName)], 0 );
		play("idle");
	}
	
	public function actUnaware() {
		// todo
	}
	
	public function actAware() {
		// todo
	}
}

class CqMobFactory {	
	public static function newMobFromLevel(X:Float, Y:Float, level:Int):CqMob {
		var typeName = null;
		switch(level+1) {
			case 1,2:
				typeName = HxlUtil.getRandomElement(SpriteMonsters.bandits);
			case 3:
				if(Math.random()<0.7)
					typeName = HxlUtil.getRandomElement(SpriteMonsters.bandits);
				else
					typeName = HxlUtil.getRandomElement(SpriteMonsters.kobolds);
			case 4:
				typeName = HxlUtil.getRandomElement(SpriteMonsters.kobolds);
			case 5:
				if(Math.random()<0.7)
					typeName = HxlUtil.getRandomElement(SpriteMonsters.kobolds);
				else
					typeName = HxlUtil.getRandomElement(SpriteMonsters.succubi);
			case 6:
				typeName = HxlUtil.getRandomElement(SpriteMonsters.succubi);
			case 7:
				if(Math.random()<0.7)
					typeName = HxlUtil.getRandomElement(SpriteMonsters.succubi);
				else
					typeName = HxlUtil.getRandomElement(SpriteMonsters.spiders);
			case 8:
				typeName = HxlUtil.getRandomElement(SpriteMonsters.spiders);
			case 9:
				if(Math.random()<0.7)
					typeName = HxlUtil.getRandomElement(SpriteMonsters.spiders);
				else
					typeName = HxlUtil.getRandomElement(SpriteMonsters.werewolves);
			case 10:
				typeName = HxlUtil.getRandomElement(SpriteMonsters.werewolves);
			case 11:
				if(Math.random()<0.7)
					typeName = HxlUtil.getRandomElement(SpriteMonsters.werewolves);
				else
					typeName = HxlUtil.getRandomElement(SpriteMonsters.minotauers);
			case 12:
				typeName = HxlUtil.getRandomElement(SpriteMonsters.minotauers);
		}
		
		return new CqMob(X, Y, typeName.toLowerCase());
	}
}

enum CqClass {
	FIGHTER;
	WIZARD;
	THIEF;
}

enum CqMobType {
	BANDIT_LONG_SWORDS; BANDIT_SHORT_SWORDS; BANDIT_SINGLE_LONG_SWORD; BANDIT_KNIVES;
	KOBOLD_SPEAR; KOBOLD_KNIVES; KOBOLD_MAGE;
	SUCCUBUS; SUCCUBUS_STAFF; SUCCUBUS_WHIP; SUCCUBUS_SCEPTER;
	SPIDER_YELLOW; SPIDER_RED; SPIDER_GRAY; SPIDER_GREEN;
	WEREWOLF_GRAY; WEREWOLF_BLUE; WEREWOLF_PURPLE;
	MINOTAUER; MINOTAUER_AXE; MINOTAUER_SWORD;
}
