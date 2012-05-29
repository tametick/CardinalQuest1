package cq;

import com.eclecticdesignstudio.motion.Actuate;
import cq.states.GameOverState;
import data.SaveSystem;
import data.StatsFile;
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
import cq.CqBag;
import cq.ui.CqVitalBar;
import cq.CqMobFactory;
import cq.effects.CqEffectSpell; // I'd like to get rid of this import here

import com.baseoneonline.haxe.astar.AStar;
import com.baseoneonline.haxe.astar.AStarNode;
import com.baseoneonline.haxe.geom.IntPoint;

import playtomic.PtPlayer;

import flash.media.Sound;

import data.io.SaveGameIO;

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

	public function save( _io:SaveGameIO ) {
		_io.writeInt( ticks );
		_io.writeString( buffName );
		_io.writeInt( buffValue );
		
		if ( specialEffect == null ) {
			_io.writeInt( 0 );
		} else {
			_io.writeInt( 1 );
			specialEffect.save( _io );
		}
		
		_io.writeString( specialMessage );
		_io.writeInt( messageColor );
	}

	public function load( _io:SaveGameIO ) {
		ticks = _io.readInt();
		buffName = _io.readString();
		buffValue = _io.readInt();
		
		var hasSpecialEffect:Bool = (_io.readInt() == 1);
		if ( hasSpecialEffect ) {
			specialEffect.load( _io );
		}
		
		specialMessage = _io.readString();
		messageColor = _io.readInt();
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
	
	public var minHp:Int; // Minimum HP is the furthest the actor can currently be hurt.
	
	// to avoid recomputing these every tick
	public var stats:EffectiveStats;
	
	// natural damage without weapon
	public var damage:Range;
	
	// all spells, items and intrinsics go in the bag
	public var bag:CqBag;
	
	// changes to basic abilities (attack, defense, speed, spirit) caused by equipped items or spells
	private var buffs:Hash<Int>;
	// special effects beyond changes to basic abilities, caused by magical items or spells
	public var specialEffects:Hash<CqSpecialEffectValue>;
	
	public var timers:Array<CqTimer>;

	// callbacks
	var onInjure:List<Dynamic>;
	var onKill:List<Dynamic>;
	var onAttackMiss:List<Dynamic>;
	var onMove:List<Dynamic>;
	
	// effect helpers
	public var isGhost:Bool; // shouldn't be public, but needed by CqItem
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
		
		specialEffects = null;
		
		if(timers!=null)
			timers.slice(0, timers.length);
		timers = null;
		
		if(onAttackMiss!=null)
			onAttackMiss.clear();

		if (onInjure!= null)
			onInjure.clear();
		if (onKill!= null)
			onKill.clear();
		if (onMove!= null)
			onMove.clear();

		onAttackMiss = null;
		onInjure = null;
		onKill = null;
		onMove = null;
	}
	
	public function new(X:Float, Y:Float) {
		super(X, Y);
		
		bag = new CqBag();

		zIndex = 3;

		actionPoints = 0;
		
		if (Configuration.mobile) {
			// speeding up movement just slightly on mobile helps keep things smooth
			moveSpeed = 0.15;
		} else {
			moveSpeed = 0.2;
		}
		visionRadius = HxlGraphics.smallScreen ? 4.77 : 8.2;
		
		hp = maxHp;
		minHp = 0;
		
		initBuffs();
		timers = new Array<CqTimer>();

		onInjure = new List();
		onKill = new List();
		onAttackMiss = new List();
		onMove = new List();

		isGhost = false;
		isDodging = false;
		dodgeDir = 0;
		dodgeCounter = 0;
		bobCounter = 0.0;
		bobCounterInc = 0.1;
		bobMult = 5.0;
		isCharmed = false;
		
		stats = new EffectiveStats(this);
	}
	
	function initBuffs(){
		buffs = new Hash<Int>();
		buffs.set("attack",0);
		buffs.set("defense",0);
		buffs.set("life", 0);
		buffs.set("speed", 0);
		buffs.set("spirit", 0);
		
		specialEffects = new Hash<CqSpecialEffectValue>();
		specialEffects.set("damage multiplier", new CqSpecialEffectValue("damage multiplier", "1"));
	}

	public function addBuff(buff:String, delta:Int) {
		buffs.set(buff, buffs.get(buff) + delta);
		stats.recompute();
	}
	
	public function getBuff(buff:String) : Int {
		return buffs.get(buff) + bag.equippedBuff(buff);
	}
	
	public function addOnInjure(Callback:Dynamic) {
		onInjure.add(Callback);
	}

	public function addOnKill(Callback:Dynamic) {
		onKill.add(Callback);
	}

	public function addOnAttackMiss(Callback:Dynamic) {
		onAttackMiss.add(Callback);
	}

	public function addOnMove(Callback:Dynamic) {
		onMove.add(Callback);
	}
	
	public function getTile():CqTile {
		return cast(Registery.level.getTile(Std.int(tilePos.x), Std.int(tilePos.y)), CqTile);
	}

	public function moveToPixel(state:HxlState, X:Float, Y:Float) {
		// so this is where we can add bobbing for waiting !
		isMoving = true;
		bobCounter = 0.0;
		if (false && Configuration.mobile && Std.is(this, CqPlayer)) {
			this.x = X;
			this.y = Y;
			isMoving = false;
		} else {
			Actuate.tween(this, moveSpeed, { x: X, y: Y } ).onComplete(moveStop);
		}
		
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
	
	public function isAGhost() : Bool
	{
		return isGhost;
	}
	
	public function doGhost(?dmgTotal:Int = 0) {
		isGhost = true;
	}

	public function doInjure(?dmgTotal:Int=0) {
		for ( Callback in onInjure ) 
			Callback(dmgTotal);

		updateHealthBar();
		
		var afraid = specialEffects.exists("fear");
		if ( afraid ) {
			removeEffect("fear");
			GameUI.showEffectText(this, Resources.getString("POPUP_FEAR_BREAK"), 0x909090);
		}
	}

	public function breakCharm() {
		if ( specialEffects.exists("charm") ) {
			this.faction = CqMob.FACTION;
			this.isCharmed = false;
			
			removeEffect("charm");
			GameUI.showEffectText(this, Resources.getString("POPUP_CHARM_BREAK"), 0x909090);
		}
	}
	
	public function injureActor(state:HxlState, other:CqActor, dmgTotal:Int) {
		if (this == Registery.player) {
			HxlLog.append(Resources.getString( "LOG_YOU_HIT" ));
			PtPlayer.hits();
			other.breakCharm();
		} else {
			HxlLog.append(Resources.getString( "LOG_HIT_YOU" ));
			PtPlayer.isHit();
		}
		other.doInjure(dmgTotal);
	}
	
	function doKill(?dmgTotal:Int=0) {
		doInjure(dmgTotal);
		for ( Callback in onKill )
			Callback();
	}
	
	// make this private & call it from injureActor?  Could be much simpler
	public function killActor(state:HxlState, other:CqActor, dmgTotal:Int) {
		other.doKill(dmgTotal);
		// todo
		if (Std.is(this, CqPlayer)) {
			var mob = cast(other, CqMob);
			
			HxlLog.append(Resources.getString( "LOG_YOU_KILL" ));
			PtPlayer.kills();
			
			// remove other
			Registery.level.removeMobFromLevel(state, mob);
			HxlGraphics.state.add(mob);
			mob.doDeathEffect(.5);
		} else {
			if (Std.is(other, CqPlayer)) {
				var player:CqPlayer = cast(other, CqPlayer);
				HxlLog.append(Resources.getString( "LOG_KILLS_YOU" ));
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
		
		if (this.faction == CqPlayer.faction && Std.is(other, CqMob)) {
			Registery.player.gainExperience(cast(other, CqMob).xpValue);
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
	
	public function applyTimerEffect(state:HxlState, t:CqTimer) {
		if (dead) {
			return;
		}
		
		if (t.buffName != null) {
			if (t.specialMessage != null) {
				GameUI.showEffectText(this, t.specialMessage, t.messageColor);
			} else {
				if (t.buffValue < 0) {
					GameUI.showEffectText(this, Resources.getString( "POPUP_RECOVERED" ) + " " + ( -t.buffValue) + " " + Resources.getString( t.buffName ), 0x00ff00);
				} else {
					GameUI.showEffectText(this, (t.buffValue) + " " + Resources.getString( t.buffName ) + " " + Resources.getString( "POPUP_EXPIRED" ), 0x909090);
				}
			}
			
			// remove buff effect
			var newVal = buffs.get(t.buffName) - t.buffValue;
			buffs.set(t.buffName, newVal);
		} 
		
		if (t.specialEffect != null && HxlUtil.contains(specialEffects.keys(), t.specialEffect.name)) {
			var currentEffect = specialEffects.get(t.specialEffect.name);

			if(t.specialEffect.name == "magic_mirror") GameUI.showEffectText(this, Resources.getString("POPUP_MIRROR_EXPIRED"), 0x909090);
			else if (t.specialEffect.name == "invisible") GameUI.showEffectText(this, Resources.getString("POPUP_INVIS_EXPIRED"), 0x909090);
			else GameUI.showEffectText(this, "" + Resources.getString(t.specialEffect.name) + " " + Resources.getString("POPUP_EFFECT_EXPIRED"), 0x909090);
			
			specialEffects.remove(t.specialEffect.name);
			
			switch(currentEffect.name){
				case "charm":
					this.faction = CqMob.FACTION;
					this.isCharmed = false;
				case "sleep":
					this.speed = currentEffect.value;
				case "invisible":
					this.setAlpha(1.00);
					
					// Reset popup.
					if ( Std.is(this, CqMob) ) {
						popup.setText( name );
					}
				case "magic_mirror":
					// when a mirror "shatters", it spawns a particle effect -- it's purely aesthetic, of course
					
					var mob:Mob = cast(this, Mob);
					var eff:CqEffectSpell = new CqEffectSpell(mob.x+mob.width/2, mob.y+mob.height/2, this._pixels);
					eff.zIndex = 1000;
					HxlGraphics.state.add(eff);
					eff.start(true, 1.0, 10);
					Registery.level.removeMobFromLevel(state, mob);
					cast(this, CqMob).destroy();
					
					return;
			}
			currentEffect = null;
		}
		
		stats.recompute();
	}
	
	public function removeEffect(effectName:String) {
		if (this.specialEffects != null && this.specialEffects.get(effectName) != null) {
			if (this.timers != null) {
				var i:Int = this.timers.length;
				while (i > 0) {
					i--;
					var t = this.timers[i];
					if (t.specialEffect != null && t.specialEffect.name == effectName) {
						this.timers.splice(i, 1);
					}
				}
			}	
			this.specialEffects.remove(effectName);
		}
	}
	
	public function breakInvisible(?message:String) {
		if (this.specialEffects != null && this.specialEffects.get("invisible") != null) {
			removeEffect("invisible");

			// Reset popup.
			if ( Std.is(this, CqMob) ) {
				popup.setText( name );
			}
			
			setAlpha(1.00); // must set alpha before the message or the message won't show!
			if (message == null) message = (Std.is(this, CqPlayer)) ? Resources.getString( "POPUP_INVIS_BROKEN" ) : Resources.getString( "POPUP_INVIS_BREAK1" ) + " " + this.name + " " + Resources.getString( "POPUP_INVIS_BREAK2" );
			GameUI.showEffectText(this, message, 0x6699ff);
			
			updateHealthBar();
		}
	}
	
	public static function biasedRandomInRange(low:Int, high:Int, ndice:Int) {
		// pick n dice that, when rolled, add up to high - low, and then roll them
		// the idea here is that by splitting a single roll up into several, we more closely
		// approximate a normal distribution and come out with more intuitive results.

		var range = high - low;
		var sides:Int = Math.floor(range / ndice);
		var bigger:Int = range - sides * ndice;
		
		var sum:Int = 0;
		for (i in 0 ... ndice - bigger) {
			sum += Math.floor(Math.random() * (sides + 1.0));
		}
		for (i in 0 ... bigger) {
			sum += Math.floor(Math.random() * (sides + 2.0));
		}
		
		return sum + low;
	}

	public function attackOther(state:HxlState, other:GameObject) {
		var stealthy = false;
		
		var other = cast(other, CqActor);
		
		// attack & defense buffs
		var atk = Math.max(attack + getBuff("attack"), 1);
		var def = Math.max(other.defense + other.getBuff("defense"), 1);
		
		if (this.specialEffects.get("invisible") != null) {
			// always hit if we're invisible, but become visible
			def = 0;
			stealthy = true;
			
			if (Std.is(this, CqPlayer)) {
				breakInvisible(Resources.getString( "POPUP_BACKSTAB" ));
			} else {
				breakInvisible();
			}
		}
		
		
		if (other.specialEffects.get("invisible") != null) {
			// attacking something that's invisible (probably the player) -- big boost to defense

			if (!Std.is(other, CqPlayer)) {
				// if a monster can be invisible, the player can make it visible by bumping it
				other.breakInvisible(Resources.getString( "POPUP_BUMP1" ) + " " + cast(other, CqMob).name + Resources.getString( "POPUP_BUMP2" ));
				return;
			} else {
				// monsters will sometimes pretend not to bump into you even when they should, and the odds are based on your defense (i.e., evasion)
				if (Math.random() < 6 / (6 + def)) {
					other.breakInvisible(Resources.getString( "POPUP_BUMPED" ));
				}
				return;
			}
		}
		
		var missed = true;

		if (Math.random() < atk / (atk + def)) {
			// hit
			var dmgMultiplier:Int = 1;
			if(specialEffects.get("damage multiplier") != null)
				dmgMultiplier =  Std.parseInt(specialEffects.get("damage multiplier").value);
				
			// do an extra 100% damage if stealthy!
			if (stealthy) dmgMultiplier += 1;
			
			// get our equipped weapon from our bag
			var damageRange = bag.equippedDamage();
			
			// If no weapon equipped, use our standard melee damage.
			if ( damageRange == null ) {
				damageRange = this.damage;
			}
			
			if (Std.is(this, CqPlayer)) {
				SoundEffectsManager.play(EnemyHit);	
			} else {
				SoundEffectsManager.play(PlayerHit);
			}
			
			// roll and deal the damage
			var dmgTotal:Int = biasedRandomInRange(damageRange.start * dmgMultiplier, damageRange.end * dmgMultiplier, 2);
			
			if (dmgTotal > 0) {
				missed = false;
				other.hp -= dmgTotal;
				
				// life buffs
				var lif = other.hp + other.getBuff("life");
				
				if ( lif < other.minHp ) {
					other.hp += other.minHp - lif;
					lif = other.minHp;
				}
				
				if (lif <= 0 && stealthy && Std.is(other, CqPlayer)) {
					dmgTotal = 1 - (other.hp + dmgTotal);
					other.hp = lif = 1; // never die to an invisible enemy
				}
				
				if (lif > 0) {
					injureActor(state, other, dmgTotal);
				} else {
					killActor(state, other, dmgTotal);
				}
			}
		}
		
		if (missed) {
			// Miss
			if (Std.is(this, CqPlayer))
				SoundEffectsManager.play(EnemyMiss);	
			else
				SoundEffectsManager.play(PlayerMiss);
				
			if (this == cast(Registery.player,CqPlayer)) {
				HxlLog.append(Resources.getString( "POPUP_LOG_YOU_MISS" ));
				PtPlayer.misses();
			} else {
				HxlLog.append(Resources.getString( "POPUP_LOG_MISS_YOU" ));
				PtPlayer.dodges();
			}
			for ( Callback in onAttackMiss ) Callback(this, other);
		}
	}
	
	public function setVisible(vis:Bool) {
		visible = vis;
		updateHealthBar();
	}
	
	public function updateHealthBar() {
		var healthBarVis:Bool = visible && hp > 0 && hp < maxHp && (!specialEffects.exists("invisible") || faction == CqPlayer.faction);

		if (healthBar != null) {
			healthBar.visible = healthBarVis;
			healthBar.setChildrenVisibility(healthBarVis);
		}
	}

	public override function setAlpha(alpha:Float):Float {
		setVisible(alpha > 0.0);
		updateHealthBar();
		
		var old:Float = super.setAlpha(alpha);
		calcFrame();
		return old;
	}
	
	public function canAttackOther(other:CqActor) {
		return other.faction != faction && !other.isGhost;
	}
	
	public function actInDirection(state:HxlState, targetTile:HxlPoint):Bool {
		justAttacked = false;
		
		var targetX = tilePos.x + targetTile.x;
		var targetY = tilePos.y + targetTile.y;
		
		var level = Registery.level;
		var tile:CqTile = cast(level.getTile(targetX,  targetY), CqTile);
		
		if (tile == null || (tile.blocksMovement && (!Configuration.debugMoveThroughWalls))) {
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
			if(canAttackOther(other)) {
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
			setVisible(true);
		} else {
			setVisible(false);
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

	public function updateSprite(){ }
	
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
	
	public static function showWeaponDamage(actor:CqActor, damage:Range) {
		var text = "" + damage.start + " - " + damage.end + " " + Resources.getString("damage");
		GameUI.showEffectText(actor, text, 0xff4422);		
	}
	
	// mergre note: make use of showBuff and showWeaponDamage
	public static function showBuff(actor:CqActor, val:Int, buffName:String, col:Int=0 ) {
		var text = (val > 0?"+":"") + val + " " + Resources.getString( buffName );
		
		var c:Int = col;
		if ( c == 0 ) {
			switch(buffName) {
				case "attack":
					c = 0x4BE916;
				case "defense":
					c = 0x3C1CFF; // 0x381AE6;
				case "speed":
					c = 0xEDD112;
				default:
					c = 0xFFFFFF;
			}
		}
		
		GameUI.showEffectText(actor, text, c);		
	}
	
				
// merge note : after // apply to victim :					showBuff(victim, val, buff, 0xff8822);

//  merge note: after // apply damage
//			var injured:CqActor = (victim == null) ? actor : victim;
//			
//			injured.hp -= dmg;
//			var lif = injured.hp + injured.getBuff("life");
//			if ( lif < injured.minHp ) {
//				injured.hp += injured.minHp - lif;
//				lif = injured.minHp;
/////// later:
//			}
//			if (lif > 0 && !injured.isGhost) {
//				actor.injureActor(HxlGraphics.state, injured, dmg);
//		} else {

	public function applyEffect(effect:CqSpecialEffectValue, other:CqActor) {
		HxlLog.append(Resources.getString( "LOG_EFFECT" ) + " " + Resources.getString( effect.name ));
		switch(effect.name){
		
		case "heal":
			if (effect.value == "full"){
				if (other == null) {
					updateHealthBar(); // was showHealthBar(true)
					//As per Ido's suggestion :P
					if ( hp == 1 )
						Registery.getKong().SubmitStat( Registery.KONG_FULLHEALAT1 , 1 );
					hp = maxHp;
					
					if(healthBar!=null)
						cqhealthBar.updateValue();
						
					if (Std.is(this, CqPlayer)) {
						var player = Registery.player;
						player.updatePlayerHealthBars();
						
						// Update min HP.
						player.minHp = HxlUtil.randomIntInRange( 1, Math.floor(0.25*(player.maxHp+player.getBuff("life"))) );
					}
					GameUI.showEffectText(this, Resources.getString( "POPUP_HEALED" ), 0x0080FF);
				} else {
					other.updateHealthBar();
					other.hp = other.maxHp;
					
					if (other.cqhealthBar != null)
						other.cqhealthBar.updateValue();
						
					if (Std.is(other, CqPlayer)) {
						var player = Registery.player;
						player.updatePlayerHealthBars();
					}
					GameUI.showEffectText(other, Resources.getString( "POPUP_HEALED" ), 0x0080FF);
				}
			}
		case "charge":
			if (effect.value == "full") {
				if (other == null) {
					for (s in bag.spells()) {
						s.statPoints = s.statPointsRequired;
						if ( s.inventoryProxy != null ) {
							s.inventoryProxy.updateCharge();
						}
					}

					GameUI.showEffectText(this, Resources.getString( "POPUP_CHARGED" ), 0xFFFF00);
				}
			}
		case "reveal":
			Registery.level.showAll(HxlGraphics.state);
			GameUI.instance.panels.panelMap.updateDialog();
		case "charm":
			other.faction = faction;
			other.isCharmed = true;
			other.specialEffects.set(effect.name, effect);
			GameUI.showEffectText(other, Resources.getString( "POPUP_CHARM" ), 0xFF8040);
		case "fear":
			other.specialEffects.set(effect.name, effect);
			GameUI.showEffectText(other, Resources.getString( "POPUP_FEAR" ), 0x008080);
		case "sleep":
			effect.value = other.speed;
			other.speed = 0;
			other.specialEffects.set(effect.name, effect);
			GameUI.showEffectText(other, Resources.getString( "POPUP_SLEEP" ), 0xFFFF00);
		case "blink":
			var tileLocation = HxlUtil.getRandomTile(Configuration.getLevelWidth(), Configuration.getLevelHeight(), Registery.level.mapData, SpriteTiles.walkableAndSeeThroughTiles);
			var pixelLocation = Registery.level.getPixelPositionOfTile(tileLocation.x,tileLocation.y);
			setTilePos(Std.int(tileLocation.x), Std.int(tileLocation.y));
			moveToPixel(HxlGraphics.state, pixelLocation.x, pixelLocation.y);
			Registery.level.hideAll(HxlGraphics.state);
			Registery.level.updateFieldOfView(HxlGraphics.state,true);
		case "polymorph":
			other.specialEffects.set(effect.name, effect);
			GameUI.showEffectText(other, Resources.getString( "POPUP_POLYMORPH" ), 0xA81CE3);
			var _se = other.specialEffects;
			var hppart:Float = other.hp / other.maxHp;
			var mob = Registery.level.createAndaddMob(other.getTilePos(), Std.int(Math.random() * Registery.player.level), true);
			
			if ( cast(other,CqMob).xpValue == 0 ) {
				mob.xpValue = 0; // Polymorphing worthless monsters won't let you get XP.
			}
			
			Registery.level.removeMobFromLevel(HxlGraphics.state, cast(other, CqMob));
			cast(other, CqMob).destroy();
			Registery.level.updateFieldOfView(HxlGraphics.state);
			
			// preserve the old monster's level of health
			mob.hp = Math.ceil(hppart * mob.maxHp);
			
			//health bar hacks
			GameUI.instance.addHealthBar(cast(mob, CqActor));
			var casted:CqActor = cast(mob, CqActor);
			casted.specialEffects = _se;
			casted.healthBar.setTween(false);
			casted.cqhealthBar.updateValue(casted.hp);
			casted.healthBar.setTween(true);
			casted.updateHealthBar();
		default:
			var text:String = effect.name;
			
			if (text == "invisible") {
				text = Resources.getString( "POPUP_INVIS" );
			} else {
				text = Resources.getString( text );
			}
			
			if (other == null) {
				specialEffects.set(effect.name, effect);
				GameUI.showEffectText(this, "" + text + (effect.value==null?"":(": " + effect.value)), 0x3260C8);
			} else {
				other.specialEffects.set(effect.name, effect);
				GameUI.showEffectText(other, "" + text + (effect.value==null?"":(": " + effect.value)), 0xA86020);
			}
			
			if (effect.name == "invisible") {
				if (faction == CqPlayer.faction) {
					setAlpha(0.40);
				} else {
					setAlpha(0.00);
					
					// Clear popup.
					if ( Std.is(this, CqMob) ) {
						popup.setText( "" );
					}
				}
			}
			
			updateHealthBar();
		}
		GameUI.instance.popups.setChildrenVisibility(false);
	}
	
	public function getClosestEnemy(?afterThisCell:HxlPoint = null, ?losOnly:Bool = false):CqActor {
		var best:Float = Registery.level.widthInTiles;
		var target:CqActor = null;
		
		var tooGood:Float = 0;
		
		if (afterThisCell != null) {
			tooGood = Math.abs(tilePos.x - afterThisCell.x) + Math.abs(tilePos.y - afterThisCell.y);
		}
		
		// note that this is used for ALL combat purposes, not just for ranged projectiles, so we can't use LOS
		if (Std.is(this, CqMob) && cast(this, CqMob).aware > 0 && faction != CqPlayer.faction) {
			target = Registery.player;
			best = Math.abs(tilePos.x - target.tilePos.x) + Math.abs(tilePos.y - target.tilePos.y);
			
			best -= 2; // chase a visible player even when a mirror or something else is a bit closer
		}
		
		for (mob in Registery.level.mobs) {
			var cqmob = cast(mob, CqActor);
			if (canAttackOther(cqmob) && !cqmob.specialEffects.exists("invisible") && (cqmob.visible || !losOnly)) {
				var dist = Math.abs(tilePos.x - mob.tilePos.x) + Math.abs(tilePos.y - mob.tilePos.y);
				if (dist < best) {
					if (dist < tooGood) continue;
					if (dist == tooGood && afterThisCell != null) {
						if (cqmob.tilePos.x == afterThisCell.x && cqmob.tilePos.y == afterThisCell.y) {
							// this is exactly the mob we were using as a cutoff -- from now on, we can accept a monster at the same distance
							afterThisCell = null;
						}
						continue;
					}
					best = dist;
					target = cqmob;
				}
			}
		}
		
		return target;
	}	
}	

class CqPlayer extends CqActor, implements Player {
	public static var faction:Int = 0;
	
	static var sprites = SpritePlayer.instance;
	
	public var playerClassID:String;
	public var playerClassName:String;
	public var playerClassSprite:String;
	
	public var infoViewHealthBar:CqHealthBar;
	public var infoViewXpBar:CqXpBar;
	
	public var centralHealthBar:CqHealthBar;
	public var centralXpBar:CqXpBar;
	
	public var infoViewLives:HxlText;
	public var infoViewMoney:HxlText;
	public var infoViewLevel:HxlText;
	public var infoViewFloor:HxlText;
	
	public var prefDamage:Int;	
	public var prefAttack:Int;	
	public var prefDefense:Int;	
	public var prefSpeed:Int;	
	public var prefSpirit:Int;	
	public var prefLife:Int;	
	public var xp:Int;
	public var level:Int;
	public var money:Int;
	
	public var isDying:Bool;

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
		
		bag.destroy();
		
		onGainXP.clear();
	}
	
	public static function getStatsEntry(PlayerClass:String, Level:Int) : StatsFileEntry {
		var classStats:StatsFile = Resources.statsFiles.get( "classStats.txt" );
		
		var entry:StatsFileEntry = null;
		var bestLevel:Int = -1;
		
		for ( statsLine in classStats ) {
			if ( statsLine.getField( "ID" ) == PlayerClass ) {
				var statsLevel:Int = statsLine.getField( "Level" );
				if ( statsLevel > bestLevel && statsLevel <= Level ) {
					entry = statsLine;
					bestLevel = statsLevel;
				}
			}
		}
		
		return entry;
	}
	
	public function new(PlayerClass:String, ?X:Float = -1, ?Y:Float = -1) {
		super(X, Y);
		
		playerClassID = PlayerClass;
		
		var classes:StatsFile = Resources.statsFiles.get( "classes.txt" );
		var classEntry:StatsFileEntry = classes.getEntry( "ID", PlayerClass );
		var classStatsEntry:StatsFileEntry = getStatsEntry( PlayerClass, 1 );
		
		if ( classEntry != null ) {
			playerClassName = Resources.getString( PlayerClass );
			playerClassSprite = classEntry.getField( "Sprite" );
			
			prefDamage = classEntry.getField( "DamagePref" );
			prefAttack = classEntry.getField( "AttackPref" );
			prefDefense = classEntry.getField( "DefensePref" );
			prefSpeed = classEntry.getField( "SpeedPref" );
			prefSpirit = classEntry.getField( "SpiritPref" );
			prefLife = classEntry.getField( "LifePref" );
		} else {
			throw( "Unknown class." );
		}
			
		if ( classStatsEntry != null ) {
			
			attack = classStatsEntry.getField( "Attack" );
			defense = classStatsEntry.getField( "Defense" );
			speed = classStatsEntry.getField( "Speed" );
			spirit = classStatsEntry.getField( "Spirit" );
			vitality = classStatsEntry.getField( "Vitality" );
			hp = maxHp = classStatsEntry.getField( "HP" );
			damage = new Range(1, 1);
		} else {
			throw( "Missing class stats entry for level 1." );
		}
		
		//Let Kongregate know, for now we only deal with "Normal" mode
		switch(playerClassID) {
			case "FIGHTER": Registery.getKong().SubmitStat( Registery.KONG_STARTFIGHTER , 1 );
			case "WIZARD": Registery.getKong().SubmitStat( Registery.KONG_STARTWIZARD , 1 );				
			case "THIEF": Registery.getKong().SubmitStat( Registery.KONG_STARTTHIEF , 1 );					
		}
		if (Configuration.debug) {
/*			vitality = 500;
			attack = 500;*/
			spirit = 30;
			Configuration.playerLives = 4;
		}

		lives = Configuration.playerLives;
		money = 0;
		
		addAnimation("idle", [sprites.getSpriteIndex(playerClassSprite)], 0 );
		addAnimation("idle_dagger", [sprites.getSpriteIndex(playerClassSprite + "_dagger")], 0 );
		addAnimation("idle_short_sword", [sprites.getSpriteIndex(playerClassSprite + "_short_sword")], 0 );
		addAnimation("idle_long_sword", [sprites.getSpriteIndex(playerClassSprite + "_long_sword")], 0 );
		addAnimation("idle_staff", [sprites.getSpriteIndex(playerClassSprite + "_staff")], 0 );
		addAnimation("idle_axe", [sprites.getSpriteIndex(playerClassSprite + "_axe")], 0 );
		
		xp = 0;
		level = 1;
		
		isDying = false;
		
		onGainXP = new List();

		loadGraphic(SpritePlayer, true, false, Configuration.tileSize, Configuration.tileSize, false, Configuration.zoom, Configuration.zoom);
		faction = CqPlayer.faction;

		play("idle");
		
		stats.recompute();
	}

	public function addOnGainXP(Callback:Dynamic) {
		onGainXP.add(Callback);
	}
	
	public function getPrimaryWeapon() {
		var bestWeapon:CqItem = null;
		
		for (weapon in bag.items(WEAPON, true)) {
			if (bestWeapon == null || bestWeapon.damage.end + bestWeapon.damage.start < weapon.damage.end + weapon.damage.start) {
				bestWeapon = weapon;
			}
		}
		
		return bestWeapon;
	}

	override public function updateSprite() {
		var equippedWeapon:CqItem = getPrimaryWeapon();
		
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
				case "rune_sword":
					weaponName = "short_sword";
			}
			
			play("idle_" + weaponName);
		}
	}
	
	
	public function valueItem(Item:CqItem) : Float {
		var valueItem:Float = prefDamage * (Item.damage.start + Item.damage.end) / 2;
		
		valueItem += prefAttack * Item.buffs.get("attack");
		valueItem += prefDefense * Item.buffs.get("defense");
		valueItem += prefSpeed * Item.buffs.get("speed");
		valueItem += prefSpirit * Item.buffs.get("spirit");
		valueItem += prefLife * Item.buffs.get("life");
		
		return valueItem;
	}
	
	public function give(?itemOrSpellID:String) {
		var item:CqItem = CqLootFactory.newItem( -1, -1, itemOrSpellID);
		if (item != null) {
			bag.grant(item);
		} else {
			var spell:CqSpell = CqSpellFactory.newSpell( -1, -1, itemOrSpellID);
			if (spell != null) {
				bag.grant(spell);
			} else {
				throw( "Unknown item or spell \"" + itemOrSpellID + "\"." );
			}
		}
		
		updateSprite();
	}
	
	public function giveMoney(amount:Int) {
		if ( amount > 0 ) {
			var plural:Bool = amount > 1;
			GameUI.showEffectText(this, "+" + amount + " " + Resources.getString( plural?"POPUP_COINS":"POPUP_COIN" ), 0xC2881D);
			infoViewMoney.setText("" + (Std.parseInt(infoViewMoney.text) + amount));
			//Let Kongregate know, for now we only deal with "Normal" mode
			Registery.getKong().SubmitStat( Registery.KONG_MAXGOLD , Std.parseInt(infoViewMoney.text) );
		}
	}
	
	//pickup item from map
	public function pickup(state:HxlState, item:CqItem) {
		var result = bag.grant(item);
		
		if ( result == BagGrantResult.SUCCEEDED || result == BagGrantResult.SOLD ) {
			// remove item from map
			Registery.level.removeLootFromLevel(state, item);
			
			// perform the special effects (this can't be part of give())
			SoundEffectsManager.play(Pickup);
			item.doPickupEffect();

			if ( result == BagGrantResult.SOLD ) { 
				//Destroy the item.
				item.destroy();
			}
			
			updateSprite();
		} else {
			GameUI.showTextNotification(Resources.getString( "NOTIFY_INV_FULL" ), 0xFF001A);
			SoundEffectsManager.play(PotionEquipped); // why play this sound?  weird.
		}
		
		if ( result != BagGrantResult.SOLD ) {
			GameUI.instance.flashInventoryButton();
		}
	}
	
	public override function canAttackOther(other:CqActor) {
		// Players can attack EVERYTHING. (except, in case of bugginess, themselves.)
		return other != this;
	}
	
	public override function actInDirection(state:HxlState, targetTile:HxlPoint):Bool {
		var oldx = tilePos.x, oldy = tilePos.y;

		if (super.actInDirection(state, targetTile)) {
			// we track lastTile for wall sliding to work better
			lastTile = new HxlPoint(oldx, oldy);
			return true;
		} else {
			return false;
		}
	}	

	public function gainExperience(xpValue:Int) {
		HxlLog.append(Resources.getString( "LOG_XP1" ) + " " + xpValue + " " + Resources.getString( "LOG_XP2" ));
		//move this??
		cast(this, CqPlayer).xp += xpValue;
		
		// Update spells powered by XP.
		for (s in bag.spells()) {
			if ( s.stat == "xp" ) {
				var boost:Int = Std.int( 3200 * xpValue / (nextLevel() - currentLevel()) );
				s.statPoints = Std.int(Math.min( s.statPointsRequired, s.statPoints + boost));
				s.inventoryProxy.updateCharge();
			}
		}
		
		while (xp >= nextLevel())
			gainLevel();

		for ( Callback in onGainXP ) Callback(xpValue);
	}
	
	public function currentLevel():Float {
		if (level == 1)
			return 0;
		else 
			return 50 * Math.pow(2, level-1) - 25;
	}
	
	public function nextLevel():Float {
		return 50 * Math.pow(2, level) - 25;
	}
	
	function gainLevel() {
		level++;
		infoViewLevel.setText(Resources.getString( "UI_LEVEL" ) + " " + level);
		HxlLog.append(Resources.getString( "UI_LEVEL" ) + " " + level);
		GameUI.showEffectText(this, Resources.getString( "UI_LEVEL" ) + " " + level, 0xFFFF66);
		SoundEffectsManager.play(LevelUp);
		
		// Boost stats.
		var oldStats:StatsFileEntry = getStatsEntry( playerClassID, level-1 );
		var newStats:StatsFileEntry = getStatsEntry( playerClassID, level );

		var attackBoost:Int = Std.int( newStats.getField( "Attack" ) - oldStats.getField( "Attack" ) );
		var defenseBoost:Int = Std.int( newStats.getField( "Defense" ) - oldStats.getField( "Defense" ) );
		var speedBoost:Int = Std.int( newStats.getField( "Speed" ) - oldStats.getField( "Speed" ) );
		var spiritBoost:Int = Std.int( newStats.getField( "Spirit" ) - oldStats.getField( "Spirit" ) );
		var hpBoost:Int = Std.int( newStats.getField( "HP" ) - oldStats.getField( "HP" ) );
		
		if ( attackBoost != 0 ) {
			attack += attackBoost;
			CqActor.showBuff( this, attackBoost, "attack" );
		}
		if ( defenseBoost != 0 ) {
			defense += defenseBoost;
			CqActor.showBuff( this, defenseBoost, "defense" );
		}
		if ( speedBoost != 0 ) {
			speed += speedBoost;
			CqActor.showBuff( this, speedBoost, "speed" );
		}
		if ( spiritBoost != 0 ) {
			spirit += spiritBoost;
			CqActor.showBuff( this, spiritBoost, "spirit" );
		}
		if ( hpBoost != 0 ) {
			maxHp += hpBoost;
			CqActor.showBuff( this, hpBoost, "life" );
		}
		
		hp = maxHp;
		updatePlayerHealthBars();
		
		stats.recompute();
	}
	
	public function updatePlayerHealthBars() {
		infoViewHealthBar.updateValue();
		centralHealthBar.updateValue();
	}

	public function rechargeSpells() {
		// we'll make a potion or scroll of recharging, too!
		
		for (spell in bag.spells()) {
			spell.statPoints = spell.statPointsRequired;
		}
		
		// GameUI.instance.updateCharges();
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
				
		// Apply all timers to clear effects, etc.
		for ( t in player.timers ) {
			applyTimerEffect( null, t );
		}
		player.timers.splice(0, player.timers.length);
		
		player.setAlpha(1.0);
		// recharge all spells
		rechargeSpells();
		
		// undo the death animation (we should do this when we arrive, but it looks ok.)
		angularVelocity = 0;
		angle = 0;
		scaleVelocity.x = scaleVelocity.y = 0;
		scale.x = scale.y = 1.0;
		
		level.hideAll(HxlGraphics.state);
		level.updateFieldOfView(HxlGraphics.state, true);
		level.restartExploration(1);
		
		isGhost = false;
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
			
#if japanese
			player.infoViewLives.setText("" + player.lives);
#else
			player.infoViewLives.setText(Resources.getString( "UI_TIMES" ) + player.lives);
#end
			Registery.level.protectRespawnPoint();
		} else {
			///todo: Playtomic recording	
			MusicManager.stop();
			SoundEffectsManager.play(Lose);
			
			// Wipe the save.
			SaveSystem.getLoadIO().clearSave();
		}
		player = null;
		
		super.doDeathEffect(delay);
	}
	
	public function save( _io:SaveGameIO ) {
		// Save this mob, its stats, its buffs, etc.
		_io.startBlock( "Player" );
		
		// Tile X/Y.
		_io.writeInt( Std.int(tilePos.x) );
		_io.writeInt( Std.int(tilePos.y) );
		
		// thorough stats dump
		_io.writeInt( lives );
		
		_io.writeInt( attack );
		_io.writeInt( defense );
		_io.writeInt( speed );
		_io.writeInt( spirit );
		_io.writeInt( vitality );
	
		_io.writeInt( minHp );
	
		_io.writeInt( damage.start );
		_io.writeInt( damage.end );
		
		// player specific stuff
		_io.writeString( playerClassID );
		_io.writeString( playerClassName );
		_io.writeString( playerClassSprite );
	
		_io.writeInt( prefDamage );
		_io.writeInt( prefAttack );
		_io.writeInt( prefDefense );
		_io.writeInt( prefSpeed );
		_io.writeInt( prefSpirit );
		_io.writeInt( prefLife );
		_io.writeInt( xp );
		_io.writeInt( level );
		_io.writeInt( Std.parseInt(infoViewMoney.text) );
		
		// save hp and max hp, as those vary
		_io.writeInt( hp );
		_io.writeInt( maxHp );
		
		// save facing
		_io.writeInt( _facing );
		
		// save status
		_io.writeInt( faction );
	
		_io.writeInt( actionPoints );

		// save buffs, special effects and timers :(
		var numBuffs:Int = Lambda.count( buffs );
		_io.writeInt( numBuffs );
		for ( k in buffs.keys() ) {
			_io.writeString( k );
			_io.writeInt( buffs.get(k) );
		}
		
		// special effects...
		var numSpecialEffects:Int = Lambda.count( specialEffects );
		_io.writeInt( numSpecialEffects );
		for ( k in specialEffects.keys() ) {
			_io.writeString( k );
			
			var value:CqSpecialEffectValue = specialEffects.get(k);
			value.save( _io );
		}

		// ...timers... :(
		_io.writeInt( timers.length );
		for ( t in timers ) {
			t.save( _io );
		}
		
		// ALL EQUIPMENT:
		bag.save( _io );
	}
	
	public function load( _io:SaveGameIO ) {
		_io.seekToBlock( "Player" );
		
		var tileX:Int = _io.readInt();
		var tileY:Int = _io.readInt();
		
		setTilePos(Std.int(tileX), Std.int(tileY));
		var positionOfTile:HxlPoint = Registery.level.getPixelPositionOfTile(Math.round(tilePos.x), Math.round(tilePos.y));
		x = positionOfTile.x;
		y = positionOfTile.y;

		// thorough stats dump
		lives = _io.readInt();
		
		attack = _io.readInt();
		defense = _io.readInt();
		speed = _io.readInt();
		spirit = _io.readInt();
		vitality = _io.readInt();
	
		minHp = _io.readInt();
	
		damage.start = _io.readInt();
		damage.end = _io.readInt();
		
		// player specific stuff
		playerClassID = _io.readString();
		playerClassName = _io.readString();
		playerClassSprite = _io.readString();
	
		prefDamage = _io.readInt();
		prefAttack = _io.readInt();
		prefDefense = _io.readInt();
		prefSpeed = _io.readInt();
		prefSpirit = _io.readInt();
		prefLife = _io.readInt();
		xp = _io.readInt();
		level = _io.readInt();
		money = _io.readInt();
		
		// save hp and max hp, as those vary
		hp = _io.readInt();
		maxHp = _io.readInt();
		
		// save facing
		_facing = _io.readInt();
		
		// save status
		faction = _io.readInt();
	
		actionPoints = _io.readInt();
		
		// save buffs, special effects and timers :(
		var numBuffs:Int = _io.readInt();
		for ( i in 0 ... numBuffs ) {
			var key:String = _io.readString();
			var value:Int = _io.readInt();
			
			addBuff( key, value );
		}
		
		// special effects...
		var numSpecialEffects:Int = _io.readInt();
		for ( i in 0 ... numSpecialEffects ) {
			var key:String = _io.readString();
			
			var value:CqSpecialEffectValue = new CqSpecialEffectValue("");
			value.load( _io );
			
			specialEffects.set( key, value );
		}

		// ...timers... :(
		var numTimers:Int = _io.readInt();
		for ( i in 0 ... numTimers ) {
			var timer:CqTimer = new CqTimer(0, "", 0, new CqSpecialEffectValue(""));
			timer.load(_io);
			timers.push( timer );
		}
		
		// ALL EQUIPMENT:
		bag.load( _io );

		// Rewrite all animations.
		clearAnimations();
		addAnimation("idle", [sprites.getSpriteIndex(playerClassSprite)], 0 );
		addAnimation("idle_dagger", [sprites.getSpriteIndex(playerClassSprite + "_dagger")], 0 );
		addAnimation("idle_short_sword", [sprites.getSpriteIndex(playerClassSprite + "_short_sword")], 0 );
		addAnimation("idle_long_sword", [sprites.getSpriteIndex(playerClassSprite + "_long_sword")], 0 );
		addAnimation("idle_staff", [sprites.getSpriteIndex(playerClassSprite + "_staff")], 0 );
		addAnimation("idle_axe", [sprites.getSpriteIndex(playerClassSprite + "_axe")], 0 );
		
		// Update stuff. Graphics:
		updateSprite();
		calcFrame();
		
		// UI: lives
#if japanese
		infoViewLives.setText("" + player.lives);
#else
		infoViewLives.setText(Resources.getString( "UI_TIMES" ) + lives);
#end

		// UI: money
		infoViewMoney.setText("" + money);

		// UI: floor
		infoViewFloor.setText(Resources.getString( "UI_FLOOR" ) + " " +(Registery.world.currentLevelIndex + 1));
		
		// UI: level
		infoViewLevel.setText(Resources.getString( "UI_LEVEL" ) + " " + level);
		
		// UI: character screen
		GameUI.instance.panels.panelCharacter.onLoad();
	}	
}

class CqMob extends CqActor, implements Mob {
	public static inline var FACTION = 1;
	
	static var sprites = SpriteMonsters.instance;
	public var typeName:String;
	public var xpValue:Int;
	
	public var maxAware:Int;
	public var averageColor:Int;
	public var aware:Int;
	public var neverSeen:Bool;
	
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
		neverSeen = true;

		this.typeName = typeName;
		setVisible(false);
		
		var anim = new Array();
		if(player)
			anim.push(SpritePlayer.instance.getSpriteIndex(Registery.player.playerClassSprite));
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
	
	static var direction:HxlPoint;
	
	function tryToCastSpell(enemy:CqActor):Bool {
		var spell:CqSpell = null;
		var afraid = specialEffects.exists("fear");
		if (Std.is(this, CqMob) && Math.random() < 0.40) {
			for (spell in bag.spells()) {
				if (spell.isReadyToActivate) {
					if (!(afraid && spell.targetsOther)) {
						if (spell.targetsOther) {
							spell.activate(this, enemy);
						} else if (spell.targetsEmptyTile) {
							// we've got to find a nearby empty tile, then, at random!
							var tile:HxlPoint = Registery.level.randomUnblockedTile(this.tilePos);
							if (tile != null) {
								spell.activate(this, null, tile);
							} else {
								continue;
							}
						} else {
							spell.activate(this, this);
						}
						SoundEffectsManager.play(SpellCastNegative);
						
						spell.statPoints = 0;
						
						spell = null;
						return true;
					}
				}
			}
		}
		
		return false;
	}
	
	function updateAwareness() {
		var enemy = Registery.player;
		var reactionChance = .75;
		
		if (enemy.specialEffects.get("invisible") != null) {
			aware = 0;
			return;
		}
			
		if (getTile().visibility == IN_SIGHT) {
			neverSeen = false;
			if (aware > 0 || Math.random() < reactionChance) {
				aware = maxAware;
				return;
			}
		}
		
		if (aware > 0) {
			aware--;
		} else {
			// this isn't the only place that aware may be decremented, so let's just clip it to 0
			aware = 0;
		}
	}
	
	public function act(state:HxlState):Bool {
		if ( isGhost ) {
			return true; // Don't act if we're dead.
		}
		
		updateAwareness();
		
		if (neverSeen) return actUnaware(state);
		
		// find out who we're fighting!  (it's the player unless we're on his team)
		var enemy:CqActor = getClosestEnemy();
		if (enemy == null) return actUnaware(state);
		
		// zap him with magic!  (die, die, die)
		// (aware will be maxAware if we can presently see the player, so it's a good visibility test)
		// -- todo: make awareness subject to the current preferred target (or targets)
		if (aware == maxAware && tryToCastSpell(enemy)) return true;
		
		// fine.  walk towards him!
		var astar:AStar = Registery.level.aStar;
		
		// var astar:AStar = new AStar(Registery.level, new IntPoint(Std.int(tilePos.x), Std.int(tilePos.y)), new IntPoint(Std.int(enemy.tilePos.x), Std.int(enemy.tilePos.y)));
		var path:AStarNode = astar.solve(Std.int(tilePos.x), Std.int(tilePos.y), Std.int(enemy.tilePos.x), Std.int(enemy.tilePos.y));
		var dest:AStarNode = null;
		if (path != null) 
			dest = path.child;
		
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

	public function save( _io:SaveGameIO ) {
		// Save this mob, its stats, its buffs, etc.
		_io.startBlock( "Mob" );
		
		// Tile X/Y.
		_io.writeInt( Std.int(tilePos.x) );
		_io.writeInt( Std.int(tilePos.y) );
		
		// save the sprite index "typeName" (since that's a unique id per monster type)
		_io.writeString( typeName );
		
		// save hp and max hp, as those vary
		_io.writeInt( hp );
		_io.writeInt( maxHp );
		
		// save facing
		_io.writeInt( _facing );
		
		// save status
		_io.writeInt( faction );
		_io.writeInt( isCharmed ? 1 : 0 );
	
		_io.writeInt( actionPoints );
		
		// save AI status
		_io.writeInt( aware );
		_io.writeInt( neverSeen ? 1 : 0 );
		
		// save buffs, special effects and timers :(
		var numBuffs:Int = Lambda.count( buffs );
		_io.writeInt( numBuffs );
		for ( k in buffs.keys() ) {
			_io.writeString( k );
			_io.writeInt( buffs.get(k) );
		}
		
		// special effects...
		var numSpecialEffects:Int = Lambda.count( specialEffects );
		_io.writeInt( numSpecialEffects );
		for ( k in specialEffects.keys() ) {
			_io.writeString( k );
			
			var value:CqSpecialEffectValue = specialEffects.get(k);
			value.save( _io );
		}

		// ...timers... :(
		_io.writeInt( timers.length );
		for ( t in timers ) {
			t.save( _io );
		}
		
		// ...spell stat points...
		for ( s in bag.spells() ) {
			_io.writeInt( s.statPoints );
		}
	}
	
	public static function loadActor( _io:SaveGameIO ) {
		var tileX:Int = _io.readInt();
		var tileY:Int = _io.readInt();
		
		// get the sprite index "typeName" (since that's a unique id per monster type)
		var typeName:String = _io.readString();
		
		// Create the actor at this point.
		var pixelPos:HxlPoint = Registery.level.getPixelPositionOfTile(tileX, tileY);
		var mob:CqMob = CqMobFactory.newMobFromTypename( pixelPos.x, pixelPos.y, typeName );
		
		// save hp and max hp, as those vary
		mob.hp = _io.readInt();
		mob.maxHp = _io.readInt();
		
		// save facing
		mob._facing = _io.readInt();
		mob.calcFrame();
		
		// save status
		mob.faction = _io.readInt();
		mob.isCharmed = (_io.readInt()==1);
	
		mob.actionPoints = _io.readInt();
		
		// save AI status
		mob.aware = _io.readInt();
		mob.neverSeen = (_io.readInt()==1);
		
		// save buffs, special effects and timers :(
		var numBuffs:Int = _io.readInt();
		for ( i in 0 ... numBuffs ) {
			var key:String = _io.readString();
			var value:Int = _io.readInt();
			
			mob.addBuff( key, value );
		}
		
		// special effects...
		var numSpecialEffects:Int = _io.readInt();
		for ( i in 0 ... numSpecialEffects ) {
			var key:String = _io.readString();
			
			var value:CqSpecialEffectValue = new CqSpecialEffectValue("");
			value.load( _io );
			
			mob.specialEffects.set( key, value );
		}

		// ...timers... :(
		var numTimers:Int = _io.readInt();
		for ( i in 0 ... numTimers ) {
			var timer:CqTimer = new CqTimer(0, "", 0, new CqSpecialEffectValue(""));
			timer.load(_io);
			mob.timers.push(timer);
		}
		
		// ...spell stat points...
		for ( s in mob.bag.spells() ) {
			s.statPoints = _io.readInt();
		}
		
		// and now finish creating the mob
		Registery.level.addMobToLevel( HxlGraphics.state, mob );
/*		
		if (additionalAdd)HxlGraphics.state.add(mob);
		// add to tile actors list
		cast(getTile(pos.x, pos.y), CqTile).actors.push(mob);
		// call world's ActorAdded static method
		CqWorld.onActorAdded(mob);*/
		
//		GameUI.instance.addHealthBar(cast(mob, CqActor));
	}
}

class EffectiveStats {
	public var spirit(default, null):Int;
	public var speed(default, null):Int;
	public var attack(default, null):Int;
	public var defense(default, null):Int;
	public var life(default, null):Int;
	
	public var creature(default, null):CqActor;
	
	public function new(actor:CqActor) {
		creature = actor;
		recompute();
	}
	
	public function recompute() {
		speed = creature.speed;
		
		// Apply speed buffs
		if ( speed != 0 ) { // ...unless it's asleep!
			speed += creature.getBuff("speed");
			speed = speed < 0 ? 0 : speed;
		}
		
		// apply spirit buffs
		spirit = creature.spirit;
		spirit += creature.getBuff("spirit");
		spirit = spirit < 1 ? 1 : spirit;
		
		// Calc attack, defense and vitality as well, for various spells
		attack = creature.attack;
		attack += creature.getBuff("attack");
		attack = attack < 0 ? 0 : attack;
		
		defense = creature.defense;
		defense += creature.getBuff("defense");
		defense = defense < 0 ? 0 : defense;
		
		life = creature.maxHp;
		life += creature.getBuff("life");
		life = life < 0 ? 0 : life;
	}
}
