package cq;

import com.eclecticdesignstudio.motion.Actuate;
import cq.states.GameOverState;
import flash.display.BitmapData;
import haxe.Timer;
import haxel.HxlSprite;
import haxel.HxlText;

import haxel.HxlLog;
import haxel.HxlState;
import haxel.HxlUtil;
import haxel.HxlPoint;
import haxel.HxlUIBar;
import haxel.HxlGraphics;
import haxel.HxlTilemap;

import world.Mob;
import world.Actor;
import world.Player;
import world.GameObject;
import world.Tile;

import data.Registery;
import data.Resources;
import data.SoundEffectsManager;
import data.MusicManager;
import data.Configuration;

import cq.CqResources;
import cq.CqItem;
import cq.CqSpell;
import cq.CqWorld;
import cq.GameUI;
import cq.ui.CqVitalBar;
import cq.effects.CqEffectSpell;

import com.baseoneonline.haxe.astar.AStar;
import com.baseoneonline.haxe.geom.IntPoint;

import playtomic.PtPlayer;

import flash.media.Sound;

class CqTimer {
	public var ticks:Int;
	public var buffName:String;
	public var buffValue:Int;
	public var specialEffect:CqSpecialEffectValue;
	public var specialMessage:String;
	public var messageColor:Int;
	
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
	public var isCharmed:Bool;
	
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
	var bobCounter:Float;
	var bobCounterInc:Float;
	var bobMult:Float;

	public var justAttacked:Bool;
	
	public var healthBar:HxlUIBar;
	public var cqhealthBar(getHealthBar, null):CqHealthBar;
	function getHealthBar() { return cast(healthBar, CqHealthBar); }
	
	public var name:String;
	//track last horizontal direction, for sprite flipping
	var lastDirX:Int;
	
	override function destroy() {
		super.destroy();
		buffs = null;

		if(healthBar!=null &&  !healthBar.dead)
			healthBar.destroy();
		healthBar = null;
		
		damage = null;
		
		var es:CqSpell = null;
		while (equippedSpells.length > 0){
			es = equippedSpells.pop();
			if(es!=null)
				es.destroy();
			es = null;
		}
		
		specialEffects = null;
		
		if(timers!=null)
			timers.slice(0, timers.length);
		timers = null;
		
		visibleEffects = null;
		
		if (equippedWeapon != null) {
			equippedWeapon.destroy();
			equippedWeapon = null;
		}
		
		if(onAttackMiss!=null)
			onAttackMiss.clear();
		if (onEquip != null)
			onEquip.clear();
		if (onInjure!= null)
			onInjure.clear();
		if (onKill!= null)
			onKill.clear();
		if (onMove!= null)
			onMove.clear();
		if (onUnequip!= null)
			onUnequip.clear();
		

		onAttackMiss = null;
		onEquip = null;
		onInjure = null;
		onKill = null;
		onMove = null;
		onUnequip = null;
	}
	
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
		bobCounter = 0.0;
		bobCounterInc = 0.1;
		bobMult = 5.0;
		isCharmed = false;
		
		lastDirX = 0;
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
		// so this is where we can add bobbing for waiting !
		isMoving = true;
		bobCounter = 0.0;
		Actuate.tween(this, moveSpeed, { x: X, y: Y } ).onComplete(moveStop);
		
		for (Callback in onMove ) 
			Callback(this);
	}
	
	public function moveStop() {
		isMoving = false;
	}
	
	public function attackObject(state:HxlState, other:GameObject) {
		var chest = cast(other, CqChest);
		chest.bust(state, Registery.world.currentLevelIndex);
		chest = null;
	}
	
	public function doInjure(?dmgTotal:Int=0) {
		for ( Callback in onInjure ) 
			Callback(dmgTotal);
	}

	function injureActor(other:CqActor, dmgTotal:Int) {
		if (this == Registery.player) {
			HxlLog.append("You hit");
			PtPlayer.hits();
		} else {
			HxlLog.append("Hit you");
			PtPlayer.isHit();
		}
		other.doInjure(dmgTotal);
	}
	
	function doKill(?dmgTotal:Int=0) {
		doInjure(dmgTotal);
		for ( Callback in onKill )
			Callback();
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
			HxlGraphics.state.add(mob);
			mob.doDeathEffect();
		} else {
			if (Std.is(other, CqPlayer)) {
				var player:CqPlayer = cast(other, CqPlayer);
				HxlLog.append("kills you");
				//It's ok to put it here, not perfect, but easier to test
				//We will ping simply the kong server twice as often, which should be ok
				Registery.getKong().SubmitScore( player.xp , "Normal" );
				player.doDeathEffect();
			} else {
				var mob = cast(other, CqMob);
				// remove other
				Registery.level.removeMobFromLevel(state, mob);
				HxlGraphics.state.add(mob);
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
				HxlLog.append("You miss");
				PtPlayer.misses();
			} else {
				HxlLog.append("Misses you");
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
		var tile:CqTile = cast(level.getTile(targetX,  targetY), CqTile);
		
		if (tile == null || (tile.isBlockingMovement() && (!Configuration.debugMoveThroughWalls))) {
			level = null;
			tile = null;
			return false;
		}
		
		if (tile.actors.length > 0) {
			var other = cast(tile.actors[tile.actors.length - 1],CqActor);
			
			//flip sprite
			var dirx:Int = tile.mapX - Std.int(tilePos.x);
			if (dirx != 0 && dirx != lastDirX)
			{
				_facing = Std.int((-dirx + 1) / 2);
				if (Std.is(this, CqPlayer))
					_facing = (_facing == 1?0:1);
				calcFrame();
			}
		
			// attack enemy actor
			if(other.faction != faction) {
				attackOther(state, other);
				justAttacked = true;
				// end turn
				
				other = null;
				level = null;
				tile = null;
				return true;
			} else {
				other = null;
				level = null;
				tile = null;
				return false;
			}
		} else if (tile.loots.length > 0 && Std.is(this,CqPlayer)) {
			var loot = tile.loots[tile.loots.length - 1];
			if (Std.is(loot, CqChest)) {
				// bust chest & don't move
				
				//flip sprite
				var dirx:Int = tile.mapX - Std.int(tilePos.x);
				if (dirx != 0 && dirx != lastDirX)
				{
					_facing = Std.int((-dirx + 1) / 2);
					if (Std.is(this, CqPlayer))
						_facing = (_facing == 1?0:1);
					calcFrame();
				}
				
				attackObject(state, loot);
				justAttacked = true;
				SoundEffectsManager.play(ChestBusted);
				
				// end turn
				level = null;
				loot = null;
				tile = null;
				return true;
			}
			loot = null;
		}
		
		/** Move **/
		isMoving = true;
		
		if (Std.is(this, CqPlayer)) {
			var step = "cq.Footstep" + HxlUtil.randomIntInRange(1, 6);
			var sound = Type.resolveClass(step);
			SoundEffectsManager.play(sound);
			step = null;
			sound = null;
		}
		
		//flip sprite
		var dirx:Int = tile.mapX - Std.int(tilePos.x);
		if (dirx != 0 && dirx != lastDirX) {
			_facing = Std.int((-dirx + 1) / 2);
			if (Std.is(this, CqPlayer))
				_facing = (_facing == 1?0:1);
			calcFrame();
		}
		lastDirX = dirx;
		
		setTilePos(Std.int(targetX), Std.int(targetY));
		
		// set invisible if moved out of sight range
		var tile = cast(Registery.level.getTile(Std.int(targetX), Std.int(targetY)),HxlTile);
		if (tile.visibility == Visibility.IN_SIGHT) {
			visible = true;
			// only show hp bar if mob is hurt
			if ( hp < maxHp && healthBar!= null) {
				healthBar.visible= true;
			}
			
		} else {
			visible = false;
			if (healthBar!= null) {
				healthBar.visible = false;
			}
		}
			
		var positionOfTile:HxlPoint = level.getPixelPositionOfTile(Math.round(tilePos.x), Math.round(tilePos.y));
		moveToPixel(state, positionOfTile.x, positionOfTile.y);
		
		positionOfTile = null;
		tile = null;
		level = null;
		
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
		if(!dead && hp>0) {
			if ( isMoving ) {
				var offset:Float = Math.sin(bobCounter) * bobMult;
				y -= offset;
				bobCounter += bobCounterInc;
			} else if ( isDodging ) {
				var offset:Float = dodgeCounter;
				if ( offset > 10 ) 
					offset = 10 - (dodgeCounter - 10);
				if ( offset < 0 ) 
					offset = 0;
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
					if (Std.is(this, CqPlayer)) {
						var player = Registery.player;
						player.updatePlayerHealthBars();
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
					if (Std.is(this, CqPlayer)) {
						var player = Registery.player;
						player.updatePlayerHealthBars();
					}
				}
			}
		}
	}
	
	public function useAt(itemOrSpell:CqItem, tile:CqTile) {
		var Effectcolor:Int = HxlUtil.averageColour(itemOrSpell.pixels);
		if(itemOrSpell.specialEffects != null){
			for ( effect in itemOrSpell.specialEffects) {
				applyEffectAt(effect, tile);
				if (itemOrSpell.duration > -1) {
						timers.push(new CqTimer(itemOrSpell.duration, null, -1, effect));
				}
			}
		}
		//special effect
		var pos:HxlPoint = Registery.level.getTilePos(tile.mapX, tile.mapY, true);
		var eff:CqEffectSpell = new CqEffectSpell(pos.x, pos.y,Effectcolor);
		eff.zIndex = 1000;
		HxlGraphics.state.add(eff);
		eff.start(true, 1.0, 10);
	}
	
	public function use(itemOrSpell:CqItem, ?other:CqActor = null) {
		if (Std.is(itemOrSpell, CqSpell) && cast(itemOrSpell, CqSpell).targetsOther && other != null) {
			var colorSource:BitmapData;
			if (Std.is(this, CqPlayer)) {
				if (itemOrSpell.fullName == "Fireball")
					itemOrSpell.damage = CqSpellFactory.getfireBalldamageByLevel(Registery.player.level);
				colorSource = itemOrSpell.uiItem.pixels;
			} else {
				if (itemOrSpell.fullName == "Fireball")
					itemOrSpell.damage = CqSpellFactory.getfireBalldamageByLevel(5);
				colorSource = this._framePixels;
			}
			
			GameUI.instance.shootXBall(this, other, colorSource, itemOrSpell);
		}else {
			useOn(itemOrSpell, this, other);
		}
	}
	
	static var tmpSpellSprite;
	public static function useOn(itemOrSpell:CqItem, actor:CqActor, victim:CqActor) {
		if (itemOrSpell.equipSlot == POTION)
			SoundEffectsManager.play(SpellEquipped);
			
		var source:BitmapData;
		if (itemOrSpell.uiItem == null) {
			if (tmpSpellSprite == null )
				tmpSpellSprite = new HxlSprite();
				
			// only happens when enemies try to use a spell
			tmpSpellSprite.loadGraphic(SpriteSpells, true, false, Configuration.tileSize, Configuration.tileSize);
			tmpSpellSprite.setFrame(SpriteSpells.instance.getSpriteIndex(itemOrSpell.spriteIndex));
			source = tmpSpellSprite.getFramePixels();
		} else {
			source = itemOrSpell.uiItem.pixels;
		}
		
		var Effectcolor:Int = HxlUtil.averageColour(source);
		
		if (itemOrSpell.uiItem == null) {
			// only disposing of the enemies tmp spell sprite 
			source.dispose();
			tmpSpellSprite.destroy();
			tmpSpellSprite = null;
		}
		source = null;
		
		// add buffs
		if(itemOrSpell.buffs != null) {
			for (buff in itemOrSpell.buffs.keys()) {
				var val = itemOrSpell.buffs.get(buff);
				var text = (val > 0?"+":"") + val + " " + buff;

				if (victim == null) {
					var c:Int;
					switch(buff) {
						case "attack":
							c = 0x4BE916;
						case "defense":
							c = 0x381AE6;
						case "speed":
							c = 0xEDD112;
						default:
							c = 0xFFFFFF;
					}
					GameUI.showEffectText(actor, text, c);
					
					// apply to self
					actor.buffs.set(buff, actor.buffs.get(buff) + itemOrSpell.buffs.get(buff));
					
					//special effect
					var eff:CqEffectSpell = new CqEffectSpell(actor.x+actor.width/2,actor.y+actor.width/2,Effectcolor);
					eff.zIndex = 1000;
					HxlGraphics.state.add(eff);
					eff.start(true, 1.0, 10);
					
					// add timer
					if (itemOrSpell.duration > -1) {
						actor.timers.push(new CqTimer(itemOrSpell.duration, buff, itemOrSpell.buffs.get(buff),null));
					}
				} else {
					// apply to victim
					var delta:Int = itemOrSpell.buffs.get(buff);
					victim.buffs.set(buff, victim.buffs.get(buff) + itemOrSpell.buffs.get(buff));
					
					GameUI.showEffectText(victim, text, 0xff8822);
				
					// add timer
					if (itemOrSpell.duration > -1) {
						var bufftimer: CqTimer = new CqTimer(itemOrSpell.duration, buff, delta, null);
						
						victim.timers.push(bufftimer);
					}
				}
			}
		}
		if (victim != null){
			//special effect
			var eff:CqEffectSpell = new CqEffectSpell(victim.x + victim.width/2, victim.y + victim.height/2, Effectcolor);
			eff.zIndex = 1000;
			HxlGraphics.state.add(eff);
			eff.start(true, 1.0, 10);
		}
		
		// apply special effect
		if(itemOrSpell.specialEffects != null){
			for (effect in itemOrSpell.specialEffects) {
				actor.applyEffect(effect, victim);
				
				if (itemOrSpell.duration > -1) {
					if (victim == null)
						actor.timers.push(new CqTimer(itemOrSpell.duration, null, -1, effect));
					else
						victim.timers.push(new CqTimer(itemOrSpell.duration, null, -1, effect));
				}
			}
		}
		
		// apply damage
		if (itemOrSpell.damage != null && itemOrSpell.damage.end>0 ) {
			var dmg = HxlUtil.randomIntInRange(itemOrSpell.damage.start, itemOrSpell.damage.end);
			if (victim== null) {
				actor.hp -= dmg;
				var lif = actor.hp + actor.buffs.get("life");
				if (lif > 0)
					actor.injureActor(actor, dmg);
				else
					actor.killActor(HxlGraphics.state,actor,dmg);
			} else {
				victim.hp -= dmg;
				var lif = victim.hp + victim.buffs.get("life");
				if (lif > 0)
					actor.injureActor(victim, dmg);
				else
					actor.killActor(HxlGraphics.state, victim, dmg);
			}
		}
	}
	function applyEffectAt(effect:CqSpecialEffectValue, tile:CqTile) {
		switch(effect.name){
		
		case "teleport":
			var pixelLocation = Registery.level.getPixelPositionOfTile(tile.mapX,tile.mapY);
			setTilePos(Std.int(tile.mapX), Std.int(tile.mapY));
			moveToPixel(HxlGraphics.state, pixelLocation.x, pixelLocation.y);
			Registery.level.updateFieldOfView(HxlGraphics.state, true);
			
			pixelLocation = null;
		case "magic_mirror":
			var mob = Registery.level.createAndAddMirror(new HxlPoint(tile.mapX,tile.mapY), Registery.player.level, true,Registery.player);
			GameUI.showEffectText(mob, "Mirror", 0x2DB6D2);
			//mob.speed = 0;
			mob.faction = Registery.player.faction;
			effect.value = mob;
			specialEffects.set(effect.name, effect);
			Registery.level.updateFieldOfView(HxlGraphics.state, true);
			
			mob = null;
		}
	}
	
	function applyEffect(effect:CqSpecialEffectValue, other:CqActor) {
		HxlLog.append("applied special effect: " + effect.name);
		switch(effect.name){
		
		case "heal":
			if (effect.value == "full"){
				if (other == null) {
					if (healthBar != null)
						healthBar.visible = true;
					//As per Ido's suggestion :P
					if ( hp == 1 )
						Registery.getKong().SubmitStat( Registery.KONG_FULLHEALAT1 , 1 );
					hp = maxHp;
					
					if(healthBar!=null)
						cqhealthBar.updateValue();
						
					if (Std.is(this, CqPlayer)) {
						var player = Registery.player;
						player.updatePlayerHealthBars();
					}
					GameUI.showEffectText(this, "Healed", 0x0080FF);
				} else {
					if(healthBar!=null)healthBar.visible = true;
					other.hp = other.maxHp;
					
					if (other.cqhealthBar != null)
						other.cqhealthBar.updateValue();
						
					if (Std.is(other, CqPlayer)) {
						var player = Registery.player;
						player.updatePlayerHealthBars();
					}
					GameUI.showEffectText(other, "Healed", 0x0080FF);
				}
			}
		case "reveal":
			Registery.level.showAll(HxlGraphics.state);
			GameUI.instance.panels.panelMap.updateDialog();
		case "charm":
			other.faction = faction;
			other.isCharmed = true;
			other.specialEffects.set(effect.name, effect);
			GameUI.showEffectText(other, "Charm", 0xFF8040);
		case "fear":
			other.specialEffects.set(effect.name, effect);
			GameUI.showEffectText(other, "Fear", 0x008080);
		case "sleep":
			effect.value = other.speed;
			other.speed = 0;
			other.specialEffects.set(effect.name, effect);
			GameUI.showEffectText(other, "Sleep", 0xFFFF00);
		case "blink":
			var tileLocation = HxlUtil.getRandomTile(Configuration.getLevelWidth(), Configuration.getLevelHeight(), Registery.level.mapData, SpriteTiles.walkableAndSeeThroughTiles);
			var pixelLocation = Registery.level.getPixelPositionOfTile(tileLocation.x,tileLocation.y);
			setTilePos(Std.int(tileLocation.x), Std.int(tileLocation.y));
			moveToPixel(HxlGraphics.state, pixelLocation.x, pixelLocation.y);
			Registery.level.updateFieldOfView(HxlGraphics.state,true);
		case "polymorph":
			other.specialEffects.set(effect.name, effect);
			GameUI.showEffectText(other, "Morph", 0xA81CE3);
			var _se = other.specialEffects;
			var _hp = other.hp;
			var mob = Registery.level.createAndaddMob(other.getTilePos(), Std.int(Math.random() * Registery.player.level), true);
			Registery.level.removeMobFromLevel(HxlGraphics.state, cast(other, CqMob));
			Registery.level.updateFieldOfView(HxlGraphics.state);
			GameUI.instance.addHealthBar(cast(mob, CqActor));
			//health bar hacks
			var casted:CqActor = cast(mob, CqActor);
			casted.specialEffects = _se;
			casted.healthBar.setTween(false);
			casted.cqhealthBar.updateValue(_hp);
			casted.healthBar.setTween(true);
			casted.healthBar.visible = true;
		default:
			if (other == null) {
				specialEffects.set(effect.name, effect);
				GameUI.showEffectText(this, "" + effect.name+ (effect.value==null?"":(": " + effect.value)), 0x8606F9);
			} else {
				other.specialEffects.set(effect.name, effect);
				GameUI.showEffectText(other, "" + effect.name+(effect.value==null?"":(": " + effect.value)), 0x0000ff);
			}
		}
		GameUI.instance.popups.setChildrenVisibility(false);
	}
	
	public function doDeathEffect(?respawn=false) {
		angularVelocity = -200;
		scaleVelocity.x = scaleVelocity.y = -1.2;
		Actuate
			.timer(0.5)
			//.update(deathEffectUpdate, 0.5, [1.0], [0.0])
			.onComplete(deathEffectComplete,[respawn]);
	}
/*	function deathEffectUpdate(a:Float) {
		alpha = a;
	}*/
	function deathEffectComplete(respawn:Bool) {
		if(Std.is(this,CqPlayer)){
			if (respawn) {
				cast(this, CqPlayer).respawn();
			} else {
				cast(this,CqPlayer).gameOver();
			}
		} else {
			HxlGraphics.state.remove(this);
			destroy();
		}
	}
}


class CqPlayer extends CqActor, implements Player {
	public static var faction:Int = 0;
	
	static var sprites = SpritePlayer.instance;
	
	public var playerClass:CqClass;
	public var inventory:Array<CqItem>;
	
	public var infoViewHealthBar:CqHealthBar;
	public var infoViewXpBar:CqXpBar;
	
	public var centralHealthBar:CqHealthBar;
	public var centralXpBar:CqXpBar;
	
	public var infoViewLives:HxlText;
	public var infoViewMoney:HxlText;
	public var infoViewLevel:HxlText;
	public var infoViewFloor:HxlText;

	
	public var xp:Int;
	public var level:Int;
	public var money:Int;
	
	public var isDying:Bool;

	var onPickup:List<Dynamic>;
	var onGainXP:List<Dynamic>;

	var lastTile:HxlPoint;

	override function destroy() {
		super.destroy();
		
		if (centralHealthBar == null)
			return; // already destroyed (why is it getting destroyed twice?)
		
		if(!centralHealthBar.dead)
			centralHealthBar.destroy();
		centralHealthBar = null;
		
		if(!centralXpBar.dead)
			centralXpBar.destroy();
		centralXpBar = null;
		
		if(!infoViewHealthBar.dead)
			infoViewHealthBar.destroy();
		infoViewHealthBar = null;
		
		if(!infoViewXpBar.dead)
			infoViewXpBar.destroy();
		infoViewXpBar = null;
		
		var i:CqItem = null;
		while (inventory.length > 0) {
			i = inventory.pop();
			i.destroy();
			i = null;
		}
		
		lastTile = null;
		
		onGainXP.clear();
		onPickup.clear();
	}
	
	public function new(PlayerClass:CqClass, ?X:Float = -1, ?Y:Float = -1) {
		playerClass = PlayerClass;
		switch(playerClass) {
			case FIGHTER:
				attack = 5;
				defense = 2;
				speed = 3;
				spirit = 1;
				vitality = 4;
				damage = new Range(1, 1);
				//Let Kongregate know, for now we only deal with "Normal" mode
				Registery.getKong().SubmitStat( Registery.KONG_STARTFIGHTER , 1 );
			case WIZARD:
				attack = 2;
				defense = 2;
				speed = 3;
				spirit = 5;
				vitality = 3;
				damage = new Range(1, 1);
				//Let Kongregate know, for now we only deal with "Normal" mode
				Registery.getKong().SubmitStat( Registery.KONG_STARTWIZARD , 1 );				
			case THIEF:
				attack = 3;
				defense = 3;
				speed = 5;
				spirit = 3;
				vitality = 2;
				damage = new Range(1, 1);
				//Let Kongregate know, for now we only deal with "Normal" mode
				Registery.getKong().SubmitStat( Registery.KONG_STARTTHIEF , 1 );					
		}
		if (Configuration.debug) {
/*			vitality = 500;
			attack = 500;*/
			spirit = 30;
			Configuration.playerLives = 4;
		}
		super(X, Y);

		lives = Configuration.playerLives;
		money = 0;
		for (s in 0...5)
			equippedSpells[s] = null;
		
		maxHp = vitality * 2;
		hp = maxHp;

		addAnimation("idle", [sprites.getSpriteIndex(Type.enumConstructor(playerClass).toLowerCase())], 0 );
		addAnimation("idle_dagger", [sprites.getSpriteIndex(Type.enumConstructor(playerClass).toLowerCase() + "_dagger")], 0 );
		addAnimation("idle_short_sword", [sprites.getSpriteIndex(Type.enumConstructor(playerClass).toLowerCase() + "_short_sword")], 0 );
		addAnimation("idle_long_sword", [sprites.getSpriteIndex(Type.enumConstructor(playerClass).toLowerCase() + "_long_sword")], 0 );
		addAnimation("idle_staff", [sprites.getSpriteIndex(Type.enumConstructor(playerClass).toLowerCase() + "_staff")], 0 );
		addAnimation("idle_axe", [sprites.getSpriteIndex(Type.enumConstructor(playerClass).toLowerCase() + "_axe")], 0 );
		
		xp = 0;
		level = 1;
		
		isDying = false;
		
		onGainXP = new List();
		onPickup = new List();

		loadGraphic(SpritePlayer, true, false, Configuration.tileSize, Configuration.tileSize, false, 2.0, 2.0);
		faction = CqPlayer.faction;
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
		
		
		if (equippedWeapon == null){
			play("idle");
		} else {
			var weaponName = equippedWeapon.spriteIndex;
			
			// for some weapons we don't have their own player-sprites
			switch (equippedWeapon.spriteIndex) {
				case "battle_axe", "mace":
					weaponName = "axe";
				case "claymore","broad_sword":
					weaponName = "long_sword";
			}
			
			play("idle_" + weaponName);
		}
	}
	
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
	public function giveMoney(amount:Int) {
		var plural:Bool = amount > 1;
		GameUI.showEffectText(this, "+" + amount + (plural?" coins":" coin"), 0xC2881D);
		infoViewMoney.setText("" + (Std.parseInt(infoViewMoney.text) + amount));
		//Let Kongregate know, for now we only deal with "Normal" mode
		Registery.getKong().SubmitStat( Registery.KONG_MAXGOLD , Std.parseInt(infoViewMoney.text) );
	}
	
	//pickup item from map
	public function pickup(state:HxlState, item:CqItem) {
		// if inventory is full, don't give the item
		if (GameUI.instance.invItemManager.getEmptyCell() == null && item.equipSlot != POTION ){
			// todo - beep
			GameUI.showTextNotification("Inventory is full!", 0xFF001A);
			SoundEffectsManager.play(PotionEquipped);
		} else {
			// remove item from map
			Registery.level.removeLootFromLevel(state, item);
			SoundEffectsManager.play(Pickup);
			item.doPickupEffect(); //todo: Find out if this should be apart of give()
			give(item);
		}
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
		SoundEffectsManager.play(LevelUp);
		maxHp += vitality;
		hp = maxHp;
		updatePlayerHealthBars();
	}
	
	public function updatePlayerHealthBars() {
		infoViewHealthBar.updateValue();
		centralHealthBar.updateValue();
	}
	
	public override function actInDirection(state:HxlState, targetTile:HxlPoint):Bool {
		lastTile = tilePos;
		var currentTile = cast(Registery.level.getTile(Std.int(lastTile.x), Std.int(lastTile.y)), Tile);
		if ( currentTile.loots.length > 0 ) {
			var item = cast(currentTile.loots[currentTile.loots.length - 1], CqItem);
			item.setGlow(false);
		}
		return super.actInDirection(state, targetTile);
	}

	public override function moveStop() {
		super.moveStop();
		var xx = Std.int(tilePos.x);
		var yy = Std.int(tilePos.y);
		var currentTile = cast(Registery.level.getTile(xx, yy), Tile);
		var currentTileIndex = currentTile.dataNum;
		if ( currentTile.loots.length > 0 ) {
			var item = cast(currentTile.loots[currentTile.loots.length - 1], CqItem);
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
	}
	
	public function respawn() {
		var state:HxlState = HxlGraphics.state;
		
		var level:CqLevel = Registery.level;
		
		var startingPostion = level.getPixelPositionOfTile(
			level.startingLocation.x,
			level.startingLocation.y
		);
		
		var player = this;
		
		// jump back to the origin
		player.setTilePos(Std.int(level.startingLocation.x), Std.int(level.startingLocation.y));
		
		player.moveToPixel(state, startingPostion.x, startingPostion.y);
		player.hp = player.maxHp;
		player.updatePlayerHealthBars();
				
		// clear all buffs, debuffs, and timers
		for (buff in player.buffs.keys()) player.buffs.remove(buff);
		player.timers.splice(0, player.timers.length);
		
		// recharge all spells
		for (spell in player.equippedSpells) {
			if (spell != null) {
				spell.spiritPoints = spell.spiritPointsRequired;
			}
		}
		
		// undo the death animation (we should do this when we arrive, but it looks ok.)
		angularVelocity = 0;
		angle = 0;
		scaleVelocity.x = scaleVelocity.y = 0;
		scale.x = scale.y = 1.0;
		
		level.updateFieldOfView(HxlGraphics.state, true);
		
		level.ticksSinceNewDiscovery = 0;
		
		isDying = false;
	}
	
	public function gameOver() {
		// too bad!
		HxlGraphics.setState(new GameOverState());
	}
	
	public override function doDeathEffect(?doNotUseThisArgument=false) {
		if (isDying) {
			// can't die twice at once
			return;
		}
		
		isDying = true;
		
		var player:CqPlayer = this;
		var alive:Bool = player.lives >= 1;
		if (alive) {
			SoundEffectsManager.play(Death);
			
			player.lives--;
			player.infoViewLives.setText("x" + player.lives);
			Registery.level.protectRespawnPoint();
		} else {
			///todo: Playtomic recording	
			MusicManager.stop();
			SoundEffectsManager.play(Lose);
		}
		player = null;
		
		super.doDeathEffect(alive);
	}
}

class CqMob extends CqActor, implements Mob {
	public static inline var FACTION = 1;
	
	static var sprites = SpriteMonsters.instance;
	public var type:CqMobType;
	public var xpValue:Int;
	
	public var maxAware:Int;
	public var averageColor:Int;
	public var aware:Int;
	
	public function new(X:Float, Y:Float, typeName:String,?player:Bool = false) {
		super(X, Y);
		xpValue = 1;
		isCharmed = false;
		if(player)
			loadGraphic(SpritePlayer, true, false, Configuration.tileSize, Configuration.tileSize, false, Configuration.zoom, Configuration.zoom);
		else
			loadGraphic(SpriteMonsters, true, false, Configuration.tileSize, Configuration.tileSize, false, Configuration.zoom, Configuration.zoom);
			
		averageColor = HxlUtil.averageColour(this.pixels);
		faction = FACTION;
		
		maxAware = 5;
		aware = 0;

		type = Type.createEnum(CqMobType,  typeName.toUpperCase());
		visible = false;
		
		var anim = new Array();
		if(player)
			anim.push(SpritePlayer.instance.getSpriteIndex(Type.enumConstructor(Registery.player.playerClass).toLowerCase()));
		else
			anim.push(sprites.getSpriteIndex(typeName));
			
		addAnimation("idle", anim, 0 );
		anim = null;
		play("idle");
	}
	
	static var up:HxlPoint = new HxlPoint(0,-1);
	static var down:HxlPoint = new HxlPoint(0,1);
	static var left:HxlPoint = new HxlPoint(-1,0);
	static var right:HxlPoint = new HxlPoint(1, 0);
	static var directions = new Array();
	
	function actUnaware(state:HxlState):Bool {
		while(directions.length>0)
			directions.pop();
			
		// I'd like to take this list of directions and put it on actor, add a few utilities to make it more useful,
		// and employ it much more generally.  It's a very useful thing to have!
		
		if (!Registery.level.isBlockingMovement(Std.int(tilePos.x + 1), Std.int(tilePos.y)))
			directions.push(CqMob.right);
		if (!Registery.level.isBlockingMovement(Std.int(tilePos.x - 1), Std.int(tilePos.y)))
			directions.push(CqMob.left);
		if (!Registery.level.isBlockingMovement(Std.int(tilePos.x), Std.int(tilePos.y+1)))
			directions.push(CqMob.down);
		if (!Registery.level.isBlockingMovement(Std.int(tilePos.x), Std.int(tilePos.y-1)))
			directions.push(CqMob.up);
			
		var direction = HxlUtil.getRandomElement(directions);
		if (direction != null) {
			var acted:Bool = actInDirection(state, direction);
			return acted;
		} else {
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
	
	function tryToCastSpell(enemy:CqActor):Bool {
		var spell:CqSpell = null;
		if ( !specialEffects.exists("fear") && Std.is(this, CqMob) && equippedSpells.length > 0) {
			// Try casting a spell first
			
			for (s in equippedSpells) {
				if (s.spiritPoints >= s.spiritPointsRequired) {
					spell = s;
					break;
				}
			}
			
			if (spell != null && Math.random() < 0.50) {
				if(spell.targetsOther)
					use(spell, enemy);
				else
					use(spell, this);
				SoundEffectsManager.play(SpellCastNegative);
				
				spell.spiritPoints = 0;
				
				spell = null;
				return true;
			}
		}
		
		return false;
	}
	
	
	function actAware(state:HxlState):Bool {
		// find out who we're fighting!  (hint: it's the player unless we're on his team)
		var enemy:CqActor = cast(Registery.player,CqActor);
		if (enemy.faction == faction) {
			 // we're on the player's team!  we'd better find someone to target...
			enemy = getClosestMob();
			if (enemy == null) return actUnaware(state);
		}
		
		// zap him with magic!  (die, die, die)
		// (aware will be maxAware if we can presently see the player, so it's a good visibility test)
		if (aware == maxAware && tryToCastSpell(enemy)) return true;
		
		// fine.  walk towards him!
		var astar:AStar = new AStar(Registery.level, new IntPoint(Std.int(tilePos.x), Std.int(tilePos.y)), new IntPoint(Std.int(enemy.tilePos.x), Std.int(enemy.tilePos.y)));
		var line:Array<IntPoint> = astar.solve(true, false);
		var dest = line[line.length - 1];
		
		if (dest == null) {
			// no path?  let's become unaware and consume a turn
			aware = 0;
			return true;
		}
		
		var dx = dest.x - tilePos.x;
		var dy = dest.y - tilePos.y;
		
		if (specialEffects.exists("fear")) {
			dx *= -1;
			dy *= -1;
		}
		
		if (!actInDirection(state, new HxlPoint(dx, dy))) {
			// we made a decision but it didn't pan out; maybe we're bumping into someone else,
			// maybe we're bumping into a wall.  In any case, let's move randomly like we're unaware;
			// maybe something will open up.  (This is particularly useful when we're afraid, since otherwise
			// we'll just walk into a corner and stall.)
			actUnaware(state);
		}
		
		return true;
	}
	
	function updateAwareness() {
		var enemy = Registery.player;
		var reactionChance = .8;
		
		if (enemy.specialEffects.get("invisible") != null) {
			aware = 0;
			return;
		} else 
			
		if ( (aware > 0 || Math.random() < reactionChance) && HxlUtil.isInLineOfSight(tilePos, enemy.tilePos, isBlocking, enemy.visionRadius) ) {
			aware = maxAware;
			return;
		}
		
		if (aware > 0) {
			aware--;
		} else {
			// this isn't the only place that aware may be decremented, so let's just clip it to 0
			aware = 0;
		}
	}
	
	public function act(state:HxlState):Bool {
		updateAwareness();
		
		if (aware > 0) {
			return actAware(state);
		} else {
			return actUnaware(state);
		}
	}
}

class CqMobFactory {	
	static var inited = false;
	
	public static function initDescriptions() {
		if (inited)
			return;
		
		if(Resources.descriptions==null)
			Resources.descriptions = new Hash<String>();
		
		// this is a very questionable place for these descriptions to come up
		Resources.descriptions.set("Fighter", "A mighty warrior of unparalleled strength and vigor, honorable in battle, master of hack-n-slash melee.\n\nThe best choice for new players.");
		Resources.descriptions.set("Wizard", "A wise sage, knower of secrets, worker of miracles, master of the arcane arts, maker of satisfactory mixed drinks.\n\nCan cast spells rapidly - use his mystic powers as often as possible.");
		Resources.descriptions.set("Thief", "A cunning and agile rogue whose one moral credo is this: Always get away alive.\n\nThe most challenging character - use his speed and skills to avoid taking damage." );
		
		inited = true;
	}
	
	public static function newMobFromLevel(X:Float, Y:Float, level:Int,?player:CqPlayer = null):CqMob {
		initDescriptions();
		var mob;
		var typeName:String = "";
		if (player != null) {
			typeName = HxlUtil.getRandomElement(SpriteMonsters.bandits);
			mob = new CqMob(X, Y, typeName.toLowerCase(), true);
			mob.attack = player.attack;
			mob.defense = player.defense;
			mob.speed = player.speed;
			mob.spirit = player.spirit;
			mob.hp = mob.maxHp = mob.vitality = player.maxHp;
			mob.damage = player.damage;
			mob.xpValue = player.xp;
			return mob;
		}
		var shortName:String = "";
		switch(level+1) {
			case 1:
				typeName = HxlUtil.getRandomElement(SpriteMonsters.bandits);
				shortName = "Bandit";
			case 2:
				if (Math.random() < Configuration.strongerEnemyChance)
				{
					typeName = HxlUtil.getRandomElement(SpriteMonsters.bandits);
					shortName = "Bandit";
				}else{
					typeName = HxlUtil.getRandomElement(SpriteMonsters.kobolds);
					shortName = "Kobold";
				}
			case 3:
				if(Math.random()<Configuration.strongerEnemyChance){
					typeName = HxlUtil.getRandomElement(SpriteMonsters.kobolds);
					shortName = "Kobold";
				}else{
					typeName = HxlUtil.getRandomElement(SpriteMonsters.succubi);
					shortName = "Succubus";
				}
			case 4:
				if(Math.random()<Configuration.strongerEnemyChance){
					typeName = HxlUtil.getRandomElement(SpriteMonsters.succubi);
					shortName = "Succubus";
				}else{
					typeName = HxlUtil.getRandomElement(SpriteMonsters.spiders);
					shortName = "Spider";
				}
			case 5:
				if (Math.random() < Configuration.strongerEnemyChance){
					typeName = HxlUtil.getRandomElement(SpriteMonsters.spiders);
					shortName = "Spider";
				}else{
					typeName = HxlUtil.getRandomElement(SpriteMonsters.apes);
					shortName = "Ape";
				}
			case 6:
				if (Math.random() < Configuration.strongerEnemyChance){
					typeName = HxlUtil.getRandomElement(SpriteMonsters.apes);
					shortName = "Ape";
				}else{
					typeName = HxlUtil.getRandomElement(SpriteMonsters.elementeals);
					shortName = "Elemental";
				}
			case 7:
				if(Math.random()<Configuration.strongerEnemyChance){
					typeName = HxlUtil.getRandomElement(SpriteMonsters.elementeals);
					shortName = "Elemental";
				}else{
					typeName = HxlUtil.getRandomElement(SpriteMonsters.werewolves);
					shortName = "Werewolf";
				}
			case 8,9:// for "out of depth" enemies in the 8th level 
				if (Math.random() < Configuration.strongerEnemyChance) {
					shortName = "Werewolf";
					typeName = HxlUtil.getRandomElement(SpriteMonsters.werewolves);
				}else {
					shortName = "Minotaur";
					typeName = HxlUtil.getRandomElement(SpriteMonsters.minotauers);
				}
			case 99,100,101:
				//ending boss
				typeName = HxlUtil.getRandomElement(SpriteMonsters.minotauers);
				shortName = "";
		}
		mob = new CqMob(X, Y, typeName.toLowerCase());
		mob.name = shortName;
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
				mob.spirit = 4;
				mob.hp = mob.maxHp = mob.vitality = HxlUtil.randomIntInRange(2,8);
				mob.damage = new Range(2, 4);
				mob.xpValue = 25;
				mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, CqSpellType.ENFEEBLE_MONSTER));
			case SPIDER_YELLOW, SPIDER_RED, SPIDER_GRAY, SPIDER_GREEN:
				mob.attack = 5;
				mob.defense = 3;
				mob.speed = 2;
				mob.spirit = 4;
				mob.hp = mob.maxHp = mob.vitality = HxlUtil.randomIntInRange(3,12);
				mob.damage = new Range(2, 8);
				mob.xpValue = 50;
				mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, CqSpellType.FREEZE));
			case APE_BLUE, APE_BLACK, APE_RED, APE_WHITE:
				mob.attack = 4;
				mob.defense = 4;
				mob.speed = 6;
				mob.spirit = 3;
				mob.hp = mob.maxHp = mob.vitality = HxlUtil.randomIntInRange(4,16);
				mob.damage = new Range(3, 5);
				mob.xpValue = 125;
			case ELEMENTAL_GREEN, ELEMENTAL_WHITE, ELEMENTAL_RED, ELEMENTAL_BLUE:
				mob.attack = 6;
				mob.defense = 6;
				mob.speed = 2;
				mob.spirit = 3;
				mob.hp = mob.maxHp = mob.vitality = HxlUtil.randomIntInRange(6,24);
				mob.damage = new Range(4, 8);
				mob.xpValue = 275;
				mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, CqSpellType.FIREBALL));
			case WEREWOLF_GRAY, WEREWOLF_BLUE, WEREWOLF_PURPLE:
				mob.attack = 5;
				mob.defense = 5;
				mob.speed = 8;
				mob.spirit = 4;
				mob.hp = mob.maxHp = mob.vitality = HxlUtil.randomIntInRange(8,32);
				mob.damage = new Range(4,8);
				mob.xpValue = 500;
				mob.equippedSpells.push(CqSpellFactory.newSpell( -1, -1, CqSpellType.HASTE));
			case MINOTAUER, MINOTAUER_AXE, MINOTAUER_SWORD:
				mob.attack = 7;
				mob.defense = 4;
				mob.speed = 7;
				mob.spirit = 4;
				mob.hp = mob.maxHp = mob.vitality = HxlUtil.randomIntInRange(24,48);
				mob.damage = new Range(12, 32);
				mob.xpValue = 950;
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
