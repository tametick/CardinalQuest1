package cq;

import haxel.HxlLog;
import haxel.HxlState;
import haxel.HxlUtil;
import haxel.HxlPoint;
import haxel.HxlUIBar;

import world.Mob;
import world.Actor;
import world.Player;
import world.GameObject;
import world.Tile;


import data.Registery;
import data.Resources;
import data.Configuration;

import cq.CqResources;
import cq.CqItem;
import cq.CqWorld;

import com.eclecticdesignstudio.motion.Actuate;

class CqTimer {
	public var ticks:Int;
	public var buffName:String;
	public var buffValue:Int;
}

class CqActor extends CqObject, implements Actor {
	public var isMoving:Bool;
	public var moveSpeed:Float;	
	public var visionRadius:Float;
	public var faction:Int;
	
	public var actionPoints:Int;
	public var spiritPoints:Int;
	
	public var attack:Int;
	public var defense:Int;
	public var speed:Int;
	public var spirit:Int;
	public var vitality:Int;
	
	// natural damage without weapon
	public var damage:Range;
	
	var equippedWeapon:CqItem;
	var equippedSpell:CqSpell;
	
	// changes to basic abilities (attack, defense, speed, spirit) caused by equipped items or spells
	public var buffs:Hash<Int>;
	// special effects caused by magical items or spells
	public var specialEffects:Hash<CqSpecialEffect>;
	// visible effects from buffs & specialEffects
	public var visibleEffects:Array<String>;
	
	public var timers:Array<CqTimer>;

	// callbacks
	var onInjure:List<Dynamic>;
	var onKill:List<Dynamic>;
	var onEquip:List<Dynamic>;
	var onUnequip:List<Dynamic>;
	var onAttackMiss:List<Dynamic>;
	
	public function new(X:Float, Y:Float,attack:Int,defense:Int,speed:Int,spirit:Int,vitality:Int,damage:Range) {
		super(X, Y);
		actionPoints = 0;
		moveSpeed = 0.15;
		visionRadius = 8.2;
		this.attack = attack;
		this.defense = defense;
		this.damage = damage;
		this.speed = speed;
		this.spirit = spirit;
		this.vitality = vitality;
		
		maxHp = vitality;
		hp = maxHp;
		
		initBuffs();
		specialEffects = new Hash();
		visibleEffects = new Array<String>();
		timers = new Array<CqTimer>();

		onInjure = new List();
		onKill = new List();
		onEquip = new List();
		onUnequip = new List();
		onAttackMiss = new List();
	}
	
	function initBuffs(){
		buffs = new Hash<Int>();
		buffs.set("attack",0);
		buffs.set("defense",0);
		buffs.set("damageMultipler", 1);
		buffs.set("life", 0);
		buffs.set("speed", 0);
		buffs.set("spirit",0);
	}

	public function addOnInjure(Callback:Dynamic):Void {
		onInjure.add(Callback);
	}

	public function addOnKill(Callback:Dynamic):Void {
		onKill.add(Callback);
	}

	public function addOnEquip(Callback:Dynamic):Void {
		onEquip.add(Callback);
	}

	public function addOnUnequip(Callback:Dynamic):Void {
		onUnequip.add(Callback);
	}

	public function addOnAttackMiss(Callback:Dynamic):Void {
		onAttackMiss.add(Callback);
	}

	public function moveToPixel(state:HxlState, X:Float, Y:Float):Void {
		isMoving = true;
		Actuate.tween(this, moveSpeed, { x: X, y: Y } ).onComplete(moveStop,[state]);
	}
	
	public function moveStop(state:HxlState):Void {
		isMoving = false;
	}
	
	public function attackObject(state:HxlState, other:GameObject) {
		var chest = cast(other, CqChest);
		chest.bust(state);
	}
	
	public function doInjure(?dmgTotal:Int=0):Void {
		for ( Callback in onInjure ) Callback(dmgTotal);
	}

	function injureActor(other:CqActor, dmgTotal:Int) {
		if (this == cast(Registery.player,CqPlayer)) {
			HxlLog.append("You hit");
			trace("You hit");
		} else {
			HxlLog.append("Hit you");
			trace("Hit you");
		}
		other.doInjure(dmgTotal);
	}
	
	public function doKill(?dmgTotal:Int=0):Void {
		doInjure(dmgTotal);
		for ( Callback in onKill ) Callback();
	}

	function killActor(state:HxlState, other:CqActor, dmgTotal:Int) {
		other.doKill(dmgTotal);
		// todo
		if (Std.is(this, CqPlayer)) {
			var mob = cast(other, CqMob);
			
			HxlLog.append("You kill");
			trace("You kill");
			cast(this, CqPlayer).gainExperience(mob);
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
			var dmgTotal:Int;

			if (equippedWeapon!=null) {
				// With weapon
				var damageRange = equippedWeapon.damage;
				dmgTotal = HxlUtil.randomIntInRange(damageRange.start * dmgMultipler, damageRange.end * dmgMultipler);
				other.hp -= dmgTotal;

			} else {
				// With natural attack
				dmgTotal = HxlUtil.randomIntInRange(damage.start * dmgMultipler, damage.end * dmgMultipler);
				other.hp -= dmgTotal;
			}
			
			// life buffs
			var lif = other.hp + other.buffs.get("life");
			
			if (lif > 0)
				injureActor(other, dmgTotal);
			else
				killActor(state,other,dmgTotal);

		} else {
			// Miss
			if (this == cast(Registery.player,CqPlayer)) {
				HxlLog.append("You miss");//<b style='color: rgb("+other.vars.color.join()+");'>"+other.vars.description[0]+"</b>.");
				trace("You miss");
			} else {
				HxlLog.append("Misses you");//"<b style='color: rgb("+vars.color.join()+");'>"+vars.description[0]+"</b> misses you.");
				trace("Misses you");
			}
			for ( Callback in onAttackMiss ) Callback(this, other);
		}
	}
	
	public function actInDirection(state:HxlState, targetTile:HxlPoint):Bool {
		var targetX = tilePos.x + targetTile.x;
		var targetY = tilePos.y + targetTile.y;
		var world = Registery.world;
		
		var tile = cast(world.currentLevel.getTile(targetX,  targetY),CqTile);
		
		if (world.currentLevel.isBlockingMovement(Math.round(targetX),  Math.round(targetY)))
			return false;
		
		if (tile.actors.length > 0) {
			var other = cast(tile.actors[tile.actors.length - 1],CqActor);
			
			// attack enemy actor
			if(other.faction != faction) {
				attackOther(state, other);
				// end turn
				return true;
			} else
				return false;
			

		} else if (tile.loots.length > 0 && Std.is(this,CqPlayer)) {
			var loot = tile.loots[tile.loots.length - 1];
			if (Std.is(loot, CqChest)) {
				// bust chest & don't move
				attackObject(state, loot);
				
				// end turn
				return true;
			} else {
				// pickup item
				var item = cast(loot, CqItem);
				cast(this, CqPlayer).pickup(state, item);
			}
		}
		
		isMoving = true;
		setTilePos(new HxlPoint(targetX, targetY));
		var positionOfTile:HxlPoint = world.currentLevel.getPixelPositionOfTile(Math.round(tilePos.x), Math.round(tilePos.y));
		moveToPixel(state, positionOfTile.x, positionOfTile.y);
		
		return true;
	}

}


class CqPlayer extends CqActor, implements Player {
	// fixme - use static method
	static var sprites = SpritePlayer.instance;
	
	public var inventory:Array<CqItem>;
	
	public var xp:Int;
	public var level:Int;

	var onPickup:List<Dynamic>;
	var onGainXP:List<Dynamic>;

	public function new(playerClass:CqClass, ?X:Float=-1, ?Y:Float=-1) {
		// fixme - accorrect attributes
		super(X, Y, 1, 1, 5, 5,5,new Range(1, 1));
		
		xp = 0;
		level = 1;
		
		onGainXP = new List();
		onPickup = new List();

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

	public function addOnGainXP(Callback:Dynamic):Void {
		onGainXP.add(Callback);
	}

	public function addOnPickup(Callback:Dynamic):Void {
		onPickup.add(Callback);
	}

	public function pickup(state:HxlState, item:CqItem) {
		// remove item from map
		Registery.world.currentLevel.removeLootFromLevel(state, item);
		item.doPickupEffect();	
		// add to actor inventory
		inventory.push(item);

		// perform pickup callback functions
		for ( Callback in onPickup ) Callback(item);
	}
	
	public function gainExperience(other:CqMob) {
		// todo: the amount of xp gained should be passed to this method
		var xpGained:Int = 1;
		trace("gained " + other.xpValue + " xp");
		cast(this, CqPlayer).xp += xpGained;
		
		if (xp >= nextLevel())
			gainLevel();

		for ( Callback in onGainXP ) Callback(xpGained);
	}
	
	public function nextLevel() {
		return 50 * Math.pow(2, level);
	}
	
	function gainLevel() {
		trace("level: " + (++level));
		maxHp += vitality;
		hp = maxHp;
		
		// todo - update hp bar
	}
	
	public override function moveStop(state:HxlState):Void {
		super.moveStop(state);
		var currentTileIndex = cast(Registery.world.currentLevel.getTile(Std.int(tilePos.x), Std.int(tilePos.y)), Tile).dataNum;
		
		if (HxlUtil.contains(SpriteTiles.instance.stairsDown, currentTileIndex))
			Registery.world.goToNextLevel(state);
	}
}

class CqMob extends CqActor, implements Mob {
	static var sprites = SpriteMonsters.instance;
	public var type:CqMobType;
	public var xpValue:Int;
	var aware:Int;
	
	
	public function new(X:Float, Y:Float, typeName:String) {
		// fixme - correct attribute according to typename
		super(X, Y, 1, 1, 5, 0,1,new Range(1, 1));
		xpValue = 1;
		
		loadGraphic(SpriteMonsters, true, false, Configuration.tileSize, Configuration.tileSize, false, Configuration.zoom, Configuration.zoom);
		faction = 1;
		aware = 0;
		type = Type.createEnum(CqMobType,  typeName.toUpperCase());
		
		addAnimation("idle", [sprites.getSpriteIndex(typeName)], 0 );
		play("idle");
	}
	
	function actUnaware(state:HxlState):Bool {
		var directions = [];
		if (!Registery.world.currentLevel.isBlockingMovement(Std.int(tilePos.x + 1), Std.int(tilePos.y)))
			directions.push(new HxlPoint(1, 0));
		if (!Registery.world.currentLevel.isBlockingMovement(Std.int(tilePos.x - 1), Std.int(tilePos.y)))
			directions.push(new HxlPoint(-1, 0));
		if (!Registery.world.currentLevel.isBlockingMovement(Std.int(tilePos.x), Std.int(tilePos.y+1)))
			directions.push(new HxlPoint(0, 1));
		if (!Registery.world.currentLevel.isBlockingMovement(Std.int(tilePos.x), Std.int(tilePos.y-1)))
			directions.push(new HxlPoint(0, -1));
			
		var direction = HxlUtil.getRandomElement(directions);

		return actInDirection(state,direction);
	}
	
	static function isBlocking(p:HxlPoint):Bool {
		if ( p.x < 0 || p.y < 0 || p.x >= Registery.world.currentLevel.widthInTiles || p.y >= Registery.world.currentLevel.heightInTiles ) return true;
		return Registery.world.currentLevel.getTile(Math.round(p.x), Math.round(p.y)).isBlockingView();
	}
	
	function actAware(state:HxlState):Bool {
		var line = HxlUtil.getLine(tilePos, Registery.player.tilePos, isBlocking);
		var dest = line[1];
		var dx = dest.x - tilePos.x;
		var dy = dest.y - tilePos.y;
		
		// prevent diagonal movement
		if (dx != 0 && dy != 0) {
			if (Math.random() < 0.5)
				dy = 0;
			else
				dx = 0;
		}
		
		var direction = new HxlPoint(dx, dy);
		
		return actInDirection(state,direction);
	}
	
	function updateAwarness() {
		
		if ( HxlUtil.isInLineOfSight(tilePos, Registery.player.tilePos,isBlocking,Registery.player.visionRadius) )
			aware = 5;
		else
			if (aware > 0)
			aware--;
	}
	
	public function act(state:HxlState):Bool {
		updateAwarness();
		
		if (aware>0)
			return actAware(state);
		else
			return actUnaware(state);
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
