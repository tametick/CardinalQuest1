package cq;

import com.eclecticdesignstudio.motion.Actuate;
import cq.states.GameOverState;
import haxel.HxlText;

import haxel.HxlLog;
import haxel.HxlState;
import haxel.HxlUtil;
import haxel.HxlPoint;
import haxel.HxlUIBar;
import haxel.HxlGraphics;

import world.Mob;
import world.Actor;
import world.Player;
import world.GameObject;
import world.Tile;

import data.Registery;
import data.Resources;
import data.SoundEffectsManager;
import data.Configuration;

import cq.CqResources;
import cq.CqItem;
import cq.CqSpell;
import cq.CqWorld;
import cq.GameUI;
import cq.CqVitalBar;

import playtomic.PtPlayer;

import flash.media.Sound;

class CqTimer {
	public var ticks:Int;
	public var buffName:String;
	public var buffValue:Int;
	public var specialEffect:CqSpecialEffectValue;
	
	public function new(duration:Int, buffName:String, buffValue:Int, specialEffect:CqSpecialEffectValue) {
		ticks = duration;
		this.buffName = buffName;
		this.buffValue = buffValue;
		this.specialEffect = specialEffect;
	}
}

class CqActor extends CqObject, implements Actor {
	public var lives:Int;
	public var isMoving:Bool;
	public var moveSpeed:Float;	
	public var visionRadius:Float;
	public var faction:Int;
	
	public var actionPoints:Int;
	
	public var attack:Int;
	public var defense:Int;
	public var speed:Int;
	public var spirit:Int;
	public var vitality:Int;
	
	// natural damage without weapon
	public var damage:Range;
	
	var equippedWeapon:CqItem;
	public var equippedSpells:Array<CqSpell>;
	
	// changes to basic abilities (attack, defense, speed, spirit) caused by equipped items or spells
	public var buffs:Hash<Int>;
	// special effects beyond changes to basic abilities, caused by magical items or spells
	public var specialEffects:Hash<CqSpecialEffectValue>;
	// visible effects from buffs & specialEffects
	public var visibleEffects:Array<String>;
	
	public var timers:Array<CqTimer>;

	// callbacks
	var onInjure:List<Dynamic>;
	var onKill:List<Dynamic>;
	var onEquip:List<Dynamic>;
	var onUnequip:List<Dynamic>;
	var onAttackMiss:List<Dynamic>;
	var onMove:List<Dynamic>;
	
	// effect helpers
	var isDodging:Bool;
	var dodgeDir:Int;
	var dodgeCounter:Float;
	var bobDir:Int;
	var bobCounter:Float;
	var bobCounterInc:Float;
	var bobMult:Float;

	public var justAttacked:Bool;
	
	public var healthBar:CqHealthBar;

	public function new(X:Float, Y:Float) {
		super(X, Y);

		zIndex = 3;

		actionPoints = 0;
		moveSpeed = 0.2;
		visionRadius = 8.2;
		
		maxHp = vitality;
		hp = maxHp;
		
		equippedSpells = new Array<CqSpell>();
		
		initBuffs();
		visibleEffects = new Array<String>();
		timers = new Array<CqTimer>();

		onInjure = new List();
		onKill = new List();
		onEquip = new List();
		onUnequip = new List();
		onAttackMiss = new List();
		onMove = new List();

		isDodging = false;
		dodgeDir = 0;
		dodgeCounter = 0;
		bobDir = 0;
		bobCounter = 0.0;
		bobCounterInc = 0.1;
		bobMult = 5.0;
	}
	
	function initBuffs(){
		buffs = new Hash<Int>();
		buffs.set("attack",0);
		buffs.set("defense",0);
		buffs.set("life", 0);
		buffs.set("speed", 0);
		buffs.set("spirit", 0);
		
		specialEffects = new Hash<CqSpecialEffectValue>();
		specialEffects.set("damage multipler", new CqSpecialEffectValue("damage multipler","1"));
	}

	public function addOnInjure(Callback:Dynamic) {
		onInjure.add(Callback);
	}

	public function addOnKill(Callback:Dynamic) {
		onKill.add(Callback);
	}

	public function addOnEquip(Callback:Dynamic) {
		onEquip.add(Callback);
	}

	public function addOnUnequip(Callback:Dynamic) {
		onUnequip.add(Callback);
	}

	public function addOnAttackMiss(Callback:Dynamic) {
		onAttackMiss.add(Callback);
	}

	public function addOnMove(Callback:Dynamic) {
		onMove.add(Callback);
	}

	public function moveToPixel(state:HxlState, X:Float, Y:Float) {
		isMoving = true;
		if ( Y < y ) bobDir = 0;
		else if ( X > x ) bobDir = 1;
		else if ( Y > y ) bobDir = 2;
		else if ( X < x ) bobDir = 3;
		bobCounter = 0.0;
		Actuate.tween(this, moveSpeed, { x: X, y: Y } ).onComplete(moveStop,[state]);
		for (Callback in onMove ) Callback(this);
	}
	
	public function moveStop(state:HxlState) {
		isMoving = false;
	}
	
	public function attackObject(state:HxlState, other:GameObject) {
		var chest = cast(other, CqChest);
		chest.bust(state);
	}
	
	public function doInjure(?dmgTotal:Int=0) {
		for ( Callback in onInjure ) Callback(dmgTotal);
	}

	function injureActor(other:CqActor, dmgTotal:Int) {
		if (this == CqRegistery.player) {
			HxlLog.append("You hit");
			PtPlayer.hits();
		} else {
			HxlLog.append("Hit you");
			PtPlayer.isHit();
		}
		other.doInjure(dmgTotal);
	}
	
	public function doKill(?dmgTotal:Int=0) {
		doInjure(dmgTotal);
		for ( Callback in onKill ) Callback();
	}

	function killActor(state:HxlState, other:CqActor, dmgTotal:Int) {
		other.doKill(dmgTotal);
		// todo
		if (Std.is(this, CqPlayer)) {
			var mob = cast(other, CqMob);
			
			HxlLog.append("You kill");
			PtPlayer.kills();
			cast(this, CqPlayer).gainExperience(mob);
			// remove other
			Registery.level.removeMobFromLevel(state, mob);
			mob.doDeathEffect();
		} else {
			if (Std.is(other, CqPlayer)) {
				var player = cast(other, CqPlayer);
				HxlLog.append("kills you");
				SoundEffectsManager.play(Death);
				if (player.lives >= 1) {
					player.lives--;
					player.infoViewLives.setText("x " + player.lives);
					
					var startingPostion = Registery.level.getPixelPositionOfTile(
												Registery.level.startingLocation.x,
												Registery.level.startingLocation.y);
					player.setTilePos(
						Std.int(Registery.level.startingLocation.x), Std.int(Registery.level.startingLocation.y)
					);
					player.moveToPixel(state, startingPostion.x, startingPostion.y);
					player.hp = player.maxHp;
					player.healthBar.updateValue();
					player.infoViewHealthBar.updateValue();
					player.healthBar.visible = true;					
				} else {
					///todo: Playtomic recording
					HxlGraphics.pushState(new GameOverState());
				}
			} else {
				var mob = cast(other, CqMob);
				// remove other
				Registery.level.removeMobFromLevel(state, mob);
				mob.doDeathEffect();
			}
		}
	}

	public function attackOther(state:HxlState, other:GameObject) {
		var other = cast(other, CqActor);
		
		// attack & defense buffs
		var atk = Math.max(attack + buffs.get("attack"), 1);
		var def = Math.max(other.defense + other.buffs.get("defense"), 1);

		if (Math.random() < atk / (atk + def)) {
			// hit
			
			if (Std.is(this, CqPlayer))
				SoundEffectsManager.play(EnemyHit);	
			else
				SoundEffectsManager.play(PlayerHit);
			
			var dmgMultipler:Int = 1;
			if(specialEffects.get("damage multipler")!=null)
				dmgMultipler =  Std.parseInt(specialEffects.get("damage multipler").value);
			
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
			if (Std.is(this, CqPlayer))
				SoundEffectsManager.play(EnemyMiss);	
			else
				SoundEffectsManager.play(PlayerMiss);
				
			if (this == cast(Registery.player,CqPlayer)) {
				HxlLog.append("You miss");//<b style='color: rgb("+other.vars.color.join()+");'>"+other.vars.description[0]+"</b>.");
				PtPlayer.misses();
			} else {
				HxlLog.append("Misses you");//"<b style='color: rgb("+vars.color.join()+");'>"+vars.description[0]+"</b> misses you.");
				PtPlayer.dodges();
			}
			for ( Callback in onAttackMiss ) Callback(this, other);
		}
	}
	
	public function actInDirection(state:HxlState, targetTile:HxlPoint):Bool {
		justAttacked = false;
		
		var targetX = tilePos.x + targetTile.x;
		var targetY = tilePos.y + targetTile.y;
		var level = Registery.level;
		
		var tile = cast(level.getTile(targetX,  targetY),CqTile);
		
		if (level.isBlockingMovement(Math.round(targetX),  Math.round(targetY)))
			return false;
		
		if (tile.actors.length > 0) {
			var other = cast(tile.actors[tile.actors.length - 1],CqActor);
			
			// attack enemy actor
			if(other.faction != faction) {
				attackOther(state, other);
				justAttacked = true;
				// end turn
				return true;
			} else {
				return false;
			}
		} else if (tile.loots.length > 0 && Std.is(this,CqPlayer)) {
			var loot = tile.loots[tile.loots.length - 1];
			if (Std.is(loot, CqChest)) {
				// bust chest & don't move
				attackObject(state, loot);
				justAttacked = true;
				SoundEffectsManager.play(ChestBusted);
				// end turn
				return true;
			}
		}
		
		// move
		isMoving = true;
		if (Std.is(this, CqPlayer)) {
			var step = "cq.Footstep" + HxlUtil.randomIntInRange(1, 6);
			var sound = Type.resolveClass(step);
			SoundEffectsManager.play(sound);
		}
		setTilePos(Std.int(targetX), Std.int(targetY));
		var positionOfTile:HxlPoint = level.getPixelPositionOfTile(Math.round(tilePos.x), Math.round(tilePos.y));
		moveToPixel(state, positionOfTile.x, positionOfTile.y);
		
		return true;
	}

	public function runDodge(Dir:Int) {
		isDodging = true;
		dodgeCounter = 0;
		dodgeDir = Dir;
	}

	public override function render() {
		var oldX:Float = x;
		var oldY:Float = y;
		if ( isMoving ) {
			var offset:Float = Math.sin(bobCounter) * bobMult;
			y -= offset;
			bobCounter += bobCounterInc;
		} else if ( isDodging ) {
			var offset:Float = dodgeCounter;
			if ( offset > 10 ) offset = 10 - (dodgeCounter - 10);
			if ( offset < 0 ) offset = 0;
			switch (dodgeDir) {
				case 0:
					y += offset;
				case 1:
					x -= offset;
				case 2:
					y -= offset;
				case 3:
					x += offset;
			}
		}
		super.render();
		if ( isDodging ) {
			x = oldX;
			y = oldY;
		}
	}

	public override function update() {
		if ( isDodging ) {
			dodgeCounter += 2;
			if ( dodgeCounter >= 20 ) isDodging = false;
		}
		super.update();
	}

	function updateSprite(){ }
	
	public function equipItem(item:CqItem) {
		if (CqEquipSlot.WEAPON == item.equipSlot) {
			equippedWeapon = item;
			updateSprite();
		}

		// add buffs
		if(item.buffs != null) {
			for (buff in item.buffs.keys()) {
				buffs.set(buff, buffs.get(buff) + item.buffs.get(buff));
				if (buff == "life") {
					healthBar.updateValue();
					if (Std.is(this, CqPlayer)) {
						var player = CqRegistery.player;
						player.infoViewHealthBar.updateValue();
					}
				}
			}
		}
	}

	public function unequipItem(item:CqItem) {
		if (item == equippedWeapon) {
			equippedWeapon = null;
			updateSprite();
		}
			
		// remove buffs
		if(item.buffs != null) {
			for (buff in item.buffs.keys()) {
				buffs.set(buff, buffs.get(buff) - item.buffs.get(buff));
				if (buff == "life") {
					if (this.hp < 1)
						this.hp = 1;
					healthBar.updateValue();
					if (Std.is(this, CqPlayer)) {
						var player = CqRegistery.player;
						player.infoViewHealthBar.updateValue();
					}
				}
			}
		}
	}
	
	public function use(itemOrSpell:CqItem, ?other:CqActor=null) {
		// todo
		HxlLog.append("using item or spell");
		
		// add buffs
		if(itemOrSpell.buffs != null) {
			for (buff in itemOrSpell.buffs.keys()) {
				var val = itemOrSpell.buffs.get(buff);
				var text = (val>0?"+":"") + val + " " + buff;
				if (other == null) {
					GameUI.showEffectText(this,text, 0x00ff00);
					
					// apply to self
					buffs.set(buff, buffs.get(buff) + itemOrSpell.buffs.get(buff));
				
					// add timer
					if (itemOrSpell.duration > -1) {
						timers.push(new CqTimer(itemOrSpell.duration, buff, itemOrSpell.buffs.get(buff),null));
					}
				} else {
					GameUI.showEffectText(other, text, 0x00ff00);
					
					// apply to other
					other.buffs.set(buff, other.buffs.get(buff) + itemOrSpell.buffs.get(buff));
				
					// add timer
					if (itemOrSpell.duration > -1) {
						other.timers.push(new CqTimer(itemOrSpell.duration, buff, itemOrSpell.buffs.get(buff),null));
					}
				}
			}
		}
		
		// apply special effect
		if(itemOrSpell.specialEffects != null){
			for ( effect in itemOrSpell.specialEffects) {
				applyEffect(effect, other);
				
				if (itemOrSpell.duration > -1) {
					if (other == null)
						timers.push(new CqTimer(itemOrSpell.duration, null, -1, effect));
					else
						other.timers.push(new CqTimer(itemOrSpell.duration, null, -1, effect));
				}
			}
		}
		
		// apply damage
		if (itemOrSpell.damage != null && itemOrSpell.damage.end>0 ) {
			var dmg = HxlUtil.randomIntInRange(itemOrSpell.damage.start, itemOrSpell.damage.end);
			if (other == null) {
				hp -= dmg;
				var lif = hp + buffs.get("life");
				if (lif > 0)
					injureActor(this, dmg);
				else
					killActor(HxlGraphics.state,this,dmg);
			} else {
				other.hp -= dmg;
				var lif = other.hp + other.buffs.get("life");
				if (lif > 0)
					injureActor(other, dmg);
				else
					killActor(HxlGraphics.state,other,dmg);
			}
		}
		
	}

	function applyEffect(effect:CqSpecialEffectValue, other:CqActor) {
		HxlLog.append("applied special effect: " + effect.name);
		
		if (effect.name == "heal") {
			if (effect.value == "full"){
				if (other == null) {
					healthBar.visible = true;
					hp = maxHp;
					healthBar.updateValue();
					if (Std.is(this, CqPlayer)) {
						var player = CqRegistery.player;
						player.infoViewHealthBar.updateValue();
					}
					GameUI.showEffectText(this, "Healed", 0x0000ff);
				} else {
					healthBar.visible = true;
					other.hp = other.maxHp;
					other.healthBar.updateValue();
					if (Std.is(other, CqPlayer)) {
						var player = CqRegistery.player;
						player.infoViewHealthBar.updateValue();
					}
					GameUI.showEffectText(other, "Healed", 0x0000ff);
				}
			}
		} else if (effect.name == "charm") {
			other.faction = faction;
			other.specialEffects.set(effect.name, effect);
			GameUI.showEffectText(other, "Charm", 0x0000ff);
		} else {
			if (other == null) {
				specialEffects.set(effect.name, effect);
				GameUI.showEffectText(this, "" + effect.name+ ": " + effect.value, 0x0000ff);
			} else {
				other.specialEffects.set(effect.name, effect);
				GameUI.showEffectText(other, "" + effect.name+ ": " + effect.value, 0x0000ff);
			}
		}
	}
}


class CqPlayer extends CqActor, implements Player {
	static var sprites = SpritePlayer.instance;
	
	public var playerClass:CqClass;
	public var inventory:Array<CqItem>;
	
	public var xpBar:CqXpBar;
	
	public var infoViewHealthBar:CqHealthBar;
	public var infoViewXpBar:CqXpBar;
	public var infoViewLives:HxlText;
	public var infoViewLevel:HxlText;
	public var infoViewFloor:HxlText;

	
	public var xp:Int;
	public var level:Int;

	var onPickup:List<Dynamic>;
	var onGainXP:List<Dynamic>;

	var lastTile:HxlPoint;

	public function new(PlayerClass:CqClass, ?X:Float = -1, ?Y:Float = -1) {
		playerClass = PlayerClass;
		switch(playerClass) {
			case FIGHTER:
				attack = 5;
				defense = 2;
				speed = 3;
				spirit = 20;
				vitality = 5;
				damage = new Range(1, 1);
			case WIZARD:
				attack = 2;
				defense = 2;
				speed = 4;
				spirit = 5;
				vitality = 3;
				damage = new Range(1, 1);
			case THIEF:
				attack = 3;
				defense = 3;
				speed = 5;
				spirit = 3;
				vitality = 2;
				damage = new Range(1, 1);
		}
		
		super(X, Y);

		lives = 1;
		
		for (s in 0...5)
			equippedSpells[s] = null;
		
		maxHp = vitality * 2;
		hp = maxHp;

		addAnimation("idle", [sprites.getSpriteIndex(Type.enumConstructor(playerClass).toLowerCase())], 0 );
		addAnimation("idle_dagger", [sprites.getSpriteIndex(Type.enumConstructor(playerClass).toLowerCase() + "_dagger")], 0 );
		addAnimation("idle_short_sword", [sprites.getSpriteIndex(Type.enumConstructor(playerClass).toLowerCase() + "_short_sword")], 0 );
		addAnimation("idle_long_sword", [sprites.getSpriteIndex(Type.enumConstructor(playerClass).toLowerCase() + "_long_sword")], 0 );
		addAnimation("idle_staff", [sprites.getSpriteIndex(Type.enumConstructor(playerClass).toLowerCase() + "_staff")], 0 );
		
		xp = 0;
		level = 1;
		
		onGainXP = new List();
		onPickup = new List();

		loadGraphic(SpritePlayer, true, false, Configuration.tileSize, Configuration.tileSize, false, 2.0, 2.0);
		faction = 0;
		inventory = new Array<CqItem>();

		play("idle");

		lastTile = null;
	}

	public function addOnGainXP(Callback:Dynamic) {
		onGainXP.add(Callback);
	}

	public function addOnPickup(Callback:Dynamic) {
		onPickup.add(Callback);
	}

	override function updateSprite() { 
		if (equippedWeapon == null)
			play("idle");
		else
			play("idle_"+equippedWeapon.spriteIndex);
	}
	
	//give item via script/etc
	public function give(?item:CqItem, ?itemType:CqItemType, ?spellType:CqSpellType) {
		if (item != null) {
			// add to actor inventory
			// if this item has a max stack size greater than or less than 1, lets see if we already have the same item in inventory
			var added:Bool = false;
			if ( item.stackSizeMax != 1 ) {
				for ( i in 0 ... inventory.length ) {
					if (inventory[i].spriteIndex == item.spriteIndex) {
						added = true;
						inventory[i].stackSize += item.stackSize;
						if ( inventory[i].stackSize > inventory[i].stackSizeMax && inventory[i].stackSizeMax > 1) {
							added = false;
							var diff = inventory[i].stackSize - inventory[i].stackSizeMax;
							inventory[i].stackSize = inventory[i].stackSizeMax;
							item.stackSize = diff;
						}
						// perform pickup callback functions
						for ( Callback in onPickup ) 
							Callback(inventory[i]);
						break;
					}
				}
			}
			if ( !added ) {
				inventory.push(item);
				// perform pickup callback functions
				for ( Callback in onPickup ) 
					Callback(item);
			}
			return;
		} else if (itemType != null) {
			give(CqLootFactory.newItem(-1, -1, itemType));
		} else if (spellType != null) {
			give(CqSpellFactory.newSpell(-1, -1, spellType));
		}
	}
	
	//pickup item from map
	public function pickup(state:HxlState, item:CqItem) {
		// remove item from map
		Registery.level.removeLootFromLevel(state, item);
		SoundEffectsManager.play(Pickup);
		item.doPickupEffect(); //todo: Find out if this should be apart of give()
		give(item);
	}

	public function removeInventory(item:CqItem) {
		for ( i in 0 ... inventory.length ) {
			if ( inventory[i] == item ) {
				inventory.splice(i, 1);
			}
		}
	}

	public function gainExperience(other:CqMob) {
		HxlLog.append("gained " + other.xpValue + " xp");
		//move this??
		cast(this, CqPlayer).xp += other.xpValue;
		
		if (xp >= nextLevel())
			gainLevel();

		for ( Callback in onGainXP ) Callback(other.xpValue);
	}
	
	public function currentLevel():Float {
		if (level == 1)
			return 0;
		else 
			return 50 * Math.pow(2, level-1);
	}
	
	public function nextLevel():Float {
		return 50 * Math.pow(2, level);
	}
	
	function gainLevel() {
		level++;
		infoViewLevel.setText("Level " + level);
		HxlLog.append("Level " + level);
		GameUI.showEffectText(this, "Level " + level, 0xFFFF66);
		healthBar.visible = true;
		maxHp += vitality;
		hp = maxHp;
		healthBar.updateValue();
		infoViewHealthBar.updateValue();
	}
	
	public override function actInDirection(state:HxlState, targetTile:HxlPoint):Bool {
		lastTile = tilePos;
		return super.actInDirection(state, targetTile);
	}

	public override function moveStop(state:HxlState) {
		super.moveStop(state);
		var currentTile = cast(Registery.level.getTile(Std.int(tilePos.x), Std.int(tilePos.y)), Tile);
		var currentTileIndex = currentTile.dataNum;
		if ( currentTile.loots.length > 0 ) {
			var item = cast(currentTile.loots[currentTile.loots.length-1], CqItem);
			item.setGlow(true);
		}
	}

	public override function moveToPixel(state:HxlState, X:Float, Y:Float) {
		if ( lastTile != null ) {
			if ( Registery.level.getTile(Std.int(lastTile.x), Std.int(lastTile.y)) != null ) {
				var tile = cast(Registery.level.getTile(Std.int(lastTile.x), Std.int(lastTile.y)), Tile);
				if ( tile.loots.length > 0 ) {
					for ( item in tile.loots ) cast(item, CqItem).setGlow(false);
				}
			}
		}
		super.moveToPixel(state, X, Y);
	//TODO: this code is repeated in the super, not sure why its here....
	//so commented out. IF no bugs happen, probalby fine to remove.
	/*	isMoving = true;
		if ( Y < y ) bobDir = 0;
		else if ( X > x ) bobDir = 1;
		else if ( Y > y ) bobDir = 2;
		else if ( X < x ) bobDir = 3;
		bobCounter = 0.0;
		Actuate.tween(this, moveSpeed, { x: X, y: Y } ).onComplete(moveStop,[state]);*/
	}
}

class CqMob extends CqActor, implements Mob {
	public static inline var FACTION = 1;
	
	static var sprites = SpriteMonsters.instance;
	public var type:CqMobType;
	public var xpValue:Int;
	var aware:Int;
		
	public function new(X:Float, Y:Float, typeName:String) {
		super(X, Y);
		xpValue = 1;
		
		loadGraphic(SpriteMonsters, true, false, Configuration.tileSize, Configuration.tileSize, false, Configuration.zoom, Configuration.zoom);
		faction = FACTION;
		aware = 0;
		type = Type.createEnum(CqMobType,  typeName.toUpperCase());
		visible = false;
		
		addAnimation("idle", [sprites.getSpriteIndex(typeName)], 0 );
		play("idle");
	}
	
	static var up:HxlPoint = new HxlPoint(0,-1);
	static var down:HxlPoint = new HxlPoint(0,1);
	static var left:HxlPoint = new HxlPoint(-1,0);
	static var right:HxlPoint = new HxlPoint(1, 0);
	static var directions = [];
	
	function actUnaware(state:HxlState):Bool {
		while(directions.length>0)
			directions.pop();
			
		if (!Registery.level.isBlockingMovement(Std.int(tilePos.x + 1), Std.int(tilePos.y)))
			directions.push(CqMob.right);
		if (!Registery.level.isBlockingMovement(Std.int(tilePos.x - 1), Std.int(tilePos.y)))
			directions.push(CqMob.left);
		if (!Registery.level.isBlockingMovement(Std.int(tilePos.x), Std.int(tilePos.y+1)))
			directions.push(CqMob.down);
		if (!Registery.level.isBlockingMovement(Std.int(tilePos.x), Std.int(tilePos.y-1)))
			directions.push(CqMob.up);
			
		var direction = HxlUtil.getRandomElement(directions);

		if(direction!=null)
			return actInDirection(state, direction);
		else {
			// fixme - mobs is stuck
			return true;
		}
	}
	
	static function isBlocking(p:HxlPoint):Bool {
		if ( p.x < 0 || p.y < 0 || p.x >= Registery.level.widthInTiles || p.y >= Registery.level.heightInTiles ) return true;
		return Registery.level.getTile(Math.round(p.x), Math.round(p.y)).isBlockingView();
	}
	
	
	function getClosestMob():CqActor {
		var minDist:Float = Registery.level.heightInTiles + Registery.level.widthInTiles;
		var target:CqMob = null;
		for (mob in Registery.level.mobs) {
			var dist = HxlUtil.distance( getTilePos(), mob.getTilePos());
			if (dist < minDist && mob!=this){
				minDist = dist;
				target = cast(mob,CqMob);
			}
		}
		
		return target;
	}
	
	static var direction:HxlPoint;
	function actAware(state:HxlState):Bool {
		var target:CqActor = cast(Registery.player,CqActor);
		if (target.faction == faction) {
			target = getClosestMob();
			if (target == null)
				target = cast(Registery.player,CqActor);
		}
			
		var line = HxlUtil.getLine(tilePos, target.tilePos, isBlocking);
		var dest = line[1];
		
		if (dest == null)
			return true;
		
		if ( Std.is(this, CqMob) && equippedSpells.length > 0) {
			// Try casting spell first
			
			var spell:CqSpell = null;
			for (s in equippedSpells){
				if (s.spiritPoints >=  s.spiritPointsRequired) {
					spell = s;
					break;
				}
			}
			
			if (spell != null && Math.random() < 0.25) {
				// Use my spell rather than attack
				if(spell.targetsOther)
					use(spell, cast(Registery.player,CqActor));
				else
					use(spell, this);
				
				spell.spiritPoints = 0;
				// end turn
				return true;
			}
		}
			
		var dx = dest.x - tilePos.x;
		var dy = dest.y - tilePos.y;
		
		// prevent diagonal movement
		if (dx != 0 && dy != 0) {
			if (Math.random() < 0.5)
				dy = 0;
			else
				dx = 0;
		}
		
		if(direction==null)
			direction = new HxlPoint(dx, dy);
		else {
			direction.x = dx;
			direction.y = dy;
		}
		
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
		
		var invisible = CqRegistery.player.specialEffects.get("invisible");
		
		if (aware>0 && invisible==null)
			return actAware(state);
		else
			return actUnaware(state);
	}

	public function doDeathEffect() {
		HxlGraphics.state.add(this);
		var self = this;
		angularVelocity = -200;
		scaleVelocity.x = scaleVelocity.y = -1.2;
		Actuate.update(function(params:Dynamic) {
			self.alpha = params.Alpha;
		}, 0.5, {Alpha: 1.0}, {Alpha: 0.0}).onComplete(function() {
			HxlGraphics.state.remove(self);
			self.destroy();
		});
	}
}

class CqMobFactory {	
	static var inited = false;
	
	public static function initDescriptions() {
		if (inited)
			return;
		
		if(Resources.descriptions==null)
			Resources.descriptions = new Hash<String>();
		Resources.descriptions.set("Fighter", "A mighty warrior, possesing unparralleld strength and vigor.");
		Resources.descriptions.set("Wizard", "A wise mage who masterd the secrets of magic.");
		Resources.descriptions.set("Thief", "A cunning and agile rogue, his speed allows for a swift escape.");
		
		inited = true;
	}
	
	public static function newMobFromLevel(X:Float, Y:Float, level:Int):CqMob {
		initDescriptions();
		
		var typeName = null;
		switch(level+1) {
			case 1:
				typeName = HxlUtil.getRandomElement(SpriteMonsters.bandits);
			case 2:
				if(Math.random()<0.7)
					typeName = HxlUtil.getRandomElement(SpriteMonsters.bandits);
				else
					typeName = HxlUtil.getRandomElement(SpriteMonsters.kobolds);
			case 3:
				if(Math.random()<0.7)
					typeName = HxlUtil.getRandomElement(SpriteMonsters.kobolds);
				else
					typeName = HxlUtil.getRandomElement(SpriteMonsters.succubi);
			case 4:
				if(Math.random()<0.7)
					typeName = HxlUtil.getRandomElement(SpriteMonsters.succubi);
				else
					typeName = HxlUtil.getRandomElement(SpriteMonsters.spiders);
			case 5:
				if(Math.random()<0.7)
					typeName = HxlUtil.getRandomElement(SpriteMonsters.spiders);
				else
					typeName = HxlUtil.getRandomElement(SpriteMonsters.apes);
			case 6:
				if (Math.random() < 0.7)
					typeName = HxlUtil.getRandomElement(SpriteMonsters.apes);
				else
					typeName = HxlUtil.getRandomElement(SpriteMonsters.elementeals);
			case 7:
				if(Math.random()<0.7)
					typeName = HxlUtil.getRandomElement(SpriteMonsters.elementeals);
				else
					typeName = HxlUtil.getRandomElement(SpriteMonsters.werewolves);
			case 8,9:// for "out of depth" enemies in the 8th level 
				if(Math.random()<0.7)
					typeName = HxlUtil.getRandomElement(SpriteMonsters.werewolves);
				else
					typeName = HxlUtil.getRandomElement(SpriteMonsters.minotauers);
		}
		
		var mob = new CqMob(X, Y, typeName.toLowerCase());
		
		switch(mob.type) {
			case BANDIT_LONG_SWORDS, BANDIT_SHORT_SWORDS, BANDIT_SINGLE_LONG_SWORD, BANDIT_KNIVES:
				mob.attack = 2;
				mob.defense = 2;
				mob.speed = 3;
				mob.spirit = 3;
				mob.hp = mob.maxHp = mob.vitality = HxlUtil.randomIntInRange(2, 3);
				mob.damage = new Range(1, 1);
				mob.xpValue = 5;
			case KOBOLD_SPEAR, KOBOLD_KNIVES, KOBOLD_MAGE:
				mob.attack = 4;
				mob.defense = 3;
				mob.speed = 3;
				mob.spirit = 3;
				mob.hp = mob.maxHp = mob.vitality = HxlUtil.randomIntInRange(1,4);
				mob.damage = new Range(1, 3);
				mob.xpValue = 10;
			case SUCCUBUS, SUCCUBUS_STAFF, SUCCUBUS_WHIP, SUCCUBUS_SCEPTER:
				mob.attack = 3;
				mob.defense = 4;
				mob.speed = 4;
				mob.spirit = 3;
				mob.hp = mob.maxHp = mob.vitality = HxlUtil.randomIntInRange(2,8);
				mob.damage = new Range(1, 3);
				mob.xpValue = 25;
				mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, CqSpellType.ENFEEBLE_MONSTER));
			case SPIDER_YELLOW, SPIDER_RED, SPIDER_GRAY, SPIDER_GREEN:
				mob.attack = 4;
				mob.defense = 3;
				mob.speed = 2;
				mob.spirit = 3;
				mob.hp = mob.maxHp = mob.vitality = HxlUtil.randomIntInRange(3,12);
				mob.damage = new Range(2, 8);
				mob.xpValue = 50;
				mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, CqSpellType.FREEZE));
			case APE_BLUE, APE_BLACK, APE_RED, APE_WHITE:
				mob.attack = 4;
				mob.defense = 4;
				mob.speed = 5;
				mob.spirit = 3;
				mob.hp = mob.maxHp = mob.vitality = HxlUtil.randomIntInRange(4,16);
				mob.damage = new Range(2, 4);
				mob.xpValue = 125;
			case ELEMENTAL_GREEN, ELEMENTAL_WHITE, ELEMENTAL_RED, ELEMENTAL_BLUE:
				mob.attack = 5;
				mob.defense = 5;
				mob.speed = 2;
				mob.spirit = 3;
				mob.hp = mob.maxHp = mob.vitality = HxlUtil.randomIntInRange(6,24);
				mob.damage = new Range(4, 8);
				mob.xpValue = 275;
				mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, CqSpellType.FIREBALL));
			case WEREWOLF_GRAY, WEREWOLF_BLUE, WEREWOLF_PURPLE:
				mob.attack = 5;
				mob.defense = 5;
				mob.speed = 7;
				mob.spirit = 3;
				mob.hp = mob.maxHp = mob.vitality = HxlUtil.randomIntInRange(8,32);
				mob.damage = new Range(4,8);
				mob.xpValue = 500;
				mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, CqSpellType.HASTE));
			case MINOTAUER, MINOTAUER_AXE, MINOTAUER_SWORD:
				mob.attack = 5;
				mob.defense = 3;
				mob.speed = 5;
				mob.spirit = 3;
				mob.hp = mob.maxHp = mob.vitality = HxlUtil.randomIntInRange(12,48);
				mob.damage = new Range(4, 32);
				mob.xpValue = 750;
				mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, CqSpellType.BERSERK));
		}
		
		return mob;
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
	APE_BLUE; APE_BLACK; APE_RED; APE_WHITE;
	ELEMENTAL_GREEN; ELEMENTAL_WHITE; ELEMENTAL_RED; ELEMENTAL_BLUE;
	WEREWOLF_GRAY; WEREWOLF_BLUE; WEREWOLF_PURPLE;
	MINOTAUER; MINOTAUER_AXE; MINOTAUER_SWORD;
}
