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
import cq.CqMobFactory;

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
	}
	
	function initBuffs(){
		buffs = new Hash<Int>();
		buffs.set("attack",0);
		buffs.set("defense",0);
		buffs.set("life", 0);
		buffs.set("speed", 0);
		buffs.set("spirit", 0);
		
		specialEffects = new Hash<CqSpecialEffectValue>();
		specialEffects.set("damage multipler", new CqSpecialEffectValue("damage multipler", "1"));
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
			cast(this, CqPlayer).gainExperience(mob.xpValue);
			// remove other
			Registery.level.removeMobFromLevel(state, mob);
			HxlGraphics.state.add(mob);
			mob.doDeathEffect(.5);
		} else {
			if (Std.is(other, CqPlayer)) {
				var player:CqPlayer = cast(other, CqPlayer);
				HxlLog.append("kills you");
				//It's ok to put it here, not perfect, but easier to test
				//We will ping simply the kong server twice as often, which should be ok
				Registery.getKong().SubmitScore( player.xp , "Normal" );
				player.doDeathEffect(1.00);
			} else {
				var mob = cast(other, CqMob);
				// remove other
				Registery.level.removeMobFromLevel(state, mob);
				HxlGraphics.state.add(mob);
				mob.doDeathEffect(.5);
			}
		}
	}
	
	public function addTimer(timer:CqTimer) {
		for (t in this.timers) {
			if (t.specialEffect != null && timer.specialEffect != null && t.specialEffect.name == timer.specialEffect.name) {
				this.timers.remove(t);
				timer.ticks = Std.int(Math.max(timer.ticks, t.ticks));
			}
		}
		timers.push(timer);
	}
	
	public function breakInvisible(?message:String) {
		if (this.specialEffects != null && this.specialEffects.get("invisible") != null) {
			if (this.timers != null) {
				var i:Int = this.timers.length;
				while (i > 0) {
					i--;
					var t = this.timers[i];
					if (t.specialEffect != null && t.specialEffect.name == "invisible") {
						this.timers.splice(i, 1);
					}
				}
			}
			this.specialEffects.remove("invisible");
			
			setAlpha(1.00); // must set alpha before the message or the message won't show!
			if (message == null) message = (Std.is(this, CqPlayer)) ? "You reappear" : "An invisible " + this.name + " appears!";
			GameUI.showEffectText(this, message, 0x6699ff);
		}
	}

	public function attackOther(state:HxlState, other:GameObject) {
		var stealthy = false;
		
		var other = cast(other, CqActor);
		
		// attack & defense buffs
		var atk = Math.max(attack + buffs.get("attack"), 1);
		var def = Math.max(other.defense + other.buffs.get("defense"), 1);
		
		if (this.specialEffects.get("invisible") != null) {
			// always hit if we're invisible, but become visible
			def = 0;
			stealthy = true;
			
			if (Std.is(this, CqPlayer)) {
				breakInvisible("Backstab!");
			} else {
				breakInvisible();
			}
		}
		
		if (other.specialEffects.get("invisible") != null) {
			// attacking something that's invisible (probably the player) -- big boost to defense
			def += 2 * atk;

			if (!Std.is(other, CqPlayer)) {
				//// if a monster can be invisible, the player can make it visible by bumping it
				other.breakInvisible("You bump into an invisible " + cast(other, CqMob).name + ".");
			} else {
				// monsters will sometimes pretend not to bump into you even when they should
				if (Math.random() < .5) {
					other.breakInvisible("You have been discovered!");
				}
				return;
			}
		}

		if (Math.random() < atk / (atk + def)) {
			// hit
			
			if (Std.is(this, CqPlayer)) {
				SoundEffectsManager.play(EnemyHit);	
			} else {
				SoundEffectsManager.play(PlayerHit);
			}
			
			var dmgMultiplier:Int = 1;
			if(specialEffects.get("damage multipler")!=null)
				dmgMultiplier =  Std.parseInt(specialEffects.get("damage multipler").value);
				
			// do an extra 100% damage if stealthy!
			if (stealthy) dmgMultiplier += 1;
			
			// determine whether we're using a weapon
			var damageRange = (equippedWeapon != null) ? equippedWeapon.damage : damage;
			
			// roll and deal the damage
			var dmgTotal:Int = HxlUtil.randomIntInRange(damageRange.start * dmgMultiplier, damageRange.end * dmgMultiplier);
			other.hp -= dmgTotal;
			
			// life buffs
			var lif = other.hp + other.buffs.get("life");
			
			if (lif <= 0 && stealthy && Std.is(other, CqPlayer)) {
				lif = 1; // never die to an invisible enemy
				dmgTotal = other.hp + other.buffs.get("life") - lif;
			}
			
			if (lif > 0) {
				injureActor(other, dmgTotal);
			} else {
				killActor(state, other, dmgTotal);
			}

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
	
	public function showHealthBar(vis:Bool) {
		if (healthBar != null) {
			healthBar.visible = vis;
			healthBar.setChildrenVisibility(vis);
		}
	}
	
	public override function setAlpha(alpha:Float):Float {
		showHealthBar(hp < maxHp && alpha != 0);
		
		var old:Float = super.setAlpha(alpha);
		calcFrame();
		return old;
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
	
		//flip sprite
		var dirx:Int = tile.mapX - Std.int(tilePos.x);
		if (dirx != 0) {
			// it's ok if we turn even when we don't act
			var newfacing = Std.int(( -dirx + 1) / 2);
			// note that because this next line _doesn't_ apply to magic mirrors, they're backwards!  (Cool!)
			if (Std.is(this, CqPlayer)) newfacing = (newfacing == 1?0:1);
			if (newfacing != _facing) {
				_facing = newfacing;
				calcFrame();
			}
		}
		
		if (tile.actors.length > 0) {
			var other = cast(tile.actors[tile.actors.length - 1],CqActor);
		
			// attack enemy actor
			if(other.faction != faction) {
				attackOther(state, other);
				if (other.hp > 0 && other.hp < other.maxHp)
					other.showHealthBar(true);
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
				// bust chest but don't move
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
		
		setTilePos(Std.int(targetX), Std.int(targetY));
		
		// only show the mob if we can see it
		var tile = cast(Registery.level.getTile(Std.int(targetX), Std.int(targetY)),HxlTile);
		if (tile.visibility == Visibility.IN_SIGHT) {
			visible = true;
			// only show hp bar if mob is hurt
			if ( hp < maxHp && healthBar != null) {
				showHealthBar(alpha != 0.0);
			}	
		} else {
			visible = false;
			if (healthBar != null) {
				showHealthBar(false);
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
		if(!dead && hp>0 && !HxlGraphics.pause) {
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
		} else {
			bobCounter = 0.0;
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
				applyEffectAt(effect, tile, itemOrSpell.duration);
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
			breakInvisible();
			
			// and now shoot
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
						actor.addTimer(new CqTimer(itemOrSpell.duration, buff, itemOrSpell.buffs.get(buff),null));
					}
				} else {
					// apply to victim
					var delta:Int = itemOrSpell.buffs.get(buff);
					victim.buffs.set(buff, victim.buffs.get(buff) + itemOrSpell.buffs.get(buff));
					
					GameUI.showEffectText(victim, text, 0xff8822);
				
					// add timer
					if (itemOrSpell.duration > -1) {
						var bufftimer: CqTimer = new CqTimer(itemOrSpell.duration, buff, delta, null);
						
						victim.addTimer(bufftimer);
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
						actor.addTimer(new CqTimer(itemOrSpell.duration, null, -1, effect));
					else
						victim.addTimer(new CqTimer(itemOrSpell.duration, null, -1, effect));
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
	function applyEffectAt(effect:CqSpecialEffectValue, tile:CqTile, ?duration:Int = -1) {
		switch(effect.name){
		
		case "teleport":
			var pixelLocation = Registery.level.getPixelPositionOfTile(tile.mapX,tile.mapY);
			setTilePos(Std.int(tile.mapX), Std.int(tile.mapY));
			moveToPixel(HxlGraphics.state, pixelLocation.x, pixelLocation.y);
			Registery.level.updateFieldOfView(HxlGraphics.state, true);
			
			pixelLocation = null;
		case "magic_mirror":
			// note that the magic mirror sprite will actually be backwards!  Very cool.
			var mob = Registery.level.createAndAddMirror(new HxlPoint(tile.mapX,tile.mapY), Registery.player.level, true, this);
			GameUI.showEffectText(mob, "Mirror", 0x2DB6D2);
			//mob.speed = 0;
			mob.faction = this.faction;
			mob.xpValue = 0;
			mob.specialEffects.set(effect.name, effect);
			Registery.level.updateFieldOfView(HxlGraphics.state, true);
			
			if (duration > -1) {
				mob.addTimer(new CqTimer(duration, null, -1, effect));
			}
		}
	}
	
	function applyEffect(effect:CqSpecialEffectValue, other:CqActor) {
		HxlLog.append("applied special effect: " + effect.name);
		switch(effect.name){
		
		case "heal":
			if (effect.value == "full"){
				if (other == null) {
					if (healthBar != null) showHealthBar(true);
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
					showHealthBar(true);
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
			casted.showHealthBar(true);
		default:
			var text:String = effect.name;
			
			if (text == "invisible") text = "Vanished";
			
			if (other == null) {
				specialEffects.set(effect.name, effect);
				GameUI.showEffectText(this, "" + text + (effect.value==null?"":(": " + effect.value)), 0x3260C8);
			} else {
				other.specialEffects.set(effect.name, effect);
				GameUI.showEffectText(other, "" + text + (effect.value==null?"":(": " + effect.value)), 0xA86020);
			}
			
			if (effect.name == "invisible") {
				if (faction == CqPlayer.faction) setAlpha(0.40);
				else setAlpha(0.00);
			}
		}
		GameUI.instance.popups.setChildrenVisibility(false);
	}
	
	public function doDeathEffect(delay:Float) {
		angularVelocity = -225;
		scaleVelocity.x = scaleVelocity.y = -1.3;
		Actuate
			.timer(delay)
			.onComplete(deathEffectComplete);
	}
	
	function deathEffectComplete() {
		if(Std.is(this,CqPlayer)){
			if (lives >= 0) {
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

	public var lastTile:HxlPoint;

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
			var addedToExistingStack:Bool = false;
			if ( item.stackSizeMax != 1 ) {
				for ( i in 0 ... inventory.length ) {
					if (inventory[i].spriteIndex == item.spriteIndex) {
						addedToExistingStack = true;
						inventory[i].stackSize += item.stackSize;
						if ( inventory[i].stackSize > inventory[i].stackSizeMax && inventory[i].stackSizeMax > 1) {
							addedToExistingStack = false;
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
			if ( !addedToExistingStack ) {
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
			
			// perform the special effects (this can't be part of give())
			SoundEffectsManager.play(Pickup);
			item.doPickupEffect();
			GameUI.showEffectText(this, item.name, 0x6699ff);
			
			// put the item in the player's inventory
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

	public function gainExperience(xpValue:Int) {
		HxlLog.append("gained " + xpValue + " xp");
		//move this??
		cast(this, CqPlayer).xp += xpValue;
		
		while (xp >= nextLevel())
			gainLevel();

		for ( Callback in onGainXP ) Callback(xpValue);
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
		var oldx = tilePos.x, oldy = tilePos.y;
		var currentTile = cast(Registery.level.getTile(Std.int(tilePos.x), Std.int(tilePos.y)), Tile);
		if ( currentTile.loots.length > 0 ) {
			var item = cast(currentTile.loots[currentTile.loots.length - 1], CqItem);
			item.setGlow(false);
		}
		if (super.actInDirection(state, targetTile)) {
			lastTile = new HxlPoint(oldx, oldy);
			return true;
		} else {
			return false;
		}
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
	
	public function rechargeSpells() {
		for (spell in equippedSpells) {
			if (spell != null) {
				spell.spiritPoints = spell.spiritPointsRequired;
			}
		}
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
		
		player.setAlpha(1.0);
		// recharge all spells
		rechargeSpells();
		
		// undo the death animation (we should do this when we arrive, but it looks ok.)
		angularVelocity = 0;
		angle = 0;
		scaleVelocity.x = scaleVelocity.y = 0;
		scale.x = scale.y = 1.0;
		
		level.updateFieldOfView(HxlGraphics.state, true);
		level.restartExploration(1);
		
		isDying = false;
	}
	
	public function gameOver() {
		// too bad!
		HxlGraphics.setState(new GameOverState());
	}
	
	public override function doDeathEffect(delay) {
		if (isDying) {
			// can't die twice at once
			return;
		}
		
		isDying = true;
		
		var player:CqPlayer = this;
		var alive:Bool = player.lives >= 1;
		player.lives--;
		
		if (alive) {
			SoundEffectsManager.play(Death);
			
			player.infoViewLives.setText("x" + player.lives);
			Registery.level.protectRespawnPoint();
		} else {
			///todo: Playtomic recording	
			MusicManager.stop();
			SoundEffectsManager.play(Lose);
		}
		player = null;
		
		super.doDeathEffect(delay);
	}
}

class CqMob extends CqActor, implements Mob {
	public static inline var FACTION = 1;
	
	static var sprites = SpriteMonsters.instance;
	public var type:CqMobType;
	public var typeName:String;
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

		this.typeName = typeName;
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
		var afraid = specialEffects.exists("fear");
		if (Std.is(this, CqMob) && equippedSpells.length > 0 && Math.random() < 0.40) {
			for (spell in equippedSpells) {
				if (spell.spiritPoints >= spell.spiritPointsRequired) {
					if (!(afraid && spell.targetsOther)) {
						if(spell.targetsOther) {
							use(spell, enemy);
						} else if (spell.targetsEmptyTile) {
							// we've got to find a nearby empty tile, then, at random!
							var tile:HxlPoint = Registery.level.randomUnblockedTile(this.tilePos);
							if (tile != null) {
								useAt(spell, Registery.level.getTile(tile.x, tile.y));
							} else {
								continue;
							}
						} else {
							use(spell, this);
						}
						SoundEffectsManager.play(SpellCastNegative);
						
						spell.spiritPoints = 0;
						
						spell = null;
						return true;
					}
				}
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
		var dest = null;
		if (line != null && line.length > 0) 
			dest = line[line.length - 1];
		
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
		var reactionChance = .75;
		
		if (enemy.specialEffects.get("invisible") != null) {
			// we should try to find a magic mirror to attack in this case -- but that takes some revamping
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

enum CqClass {
	FIGHTER;
	WIZARD;
	THIEF;
}
