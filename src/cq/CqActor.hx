package cq;

import com.eclecticdesignstudio.motion.Actuate;
import cq.states.GameOverState;
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
	
	// all spells, items and intrinsics go in the bag
	public var bag:CqBag;
	
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
		
		visibleEffects = null;
		
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
		//Bobbing is painful
		if( Configuration.mobile ) {
			moveSpeed = 0;
		} else {
			moveSpeed = 0.2;
		}
		visionRadius = 8.2;
		
		maxHp = vitality;
		hp = maxHp;
		
		initBuffs();
		visibleEffects = new Array<String>();
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
		if ( Configuration.mobile ) {
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
	
	public function doGhost(?dmgTotal:Int = 0) {
		isGhost = true;
	}

	public function doInjure(?dmgTotal:Int=0) {
		for ( Callback in onInjure ) 
			Callback(dmgTotal);
			
		showHealthBar(hp > 0 && hp < maxHp && visible);
		removeEffect("fear");
	}

	public function injureActor(state:HxlState, other:CqActor, dmgTotal:Int) {
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
	
	// make this private & call it from injureActor?  Could be much simpler
	public function killActor(state:HxlState, other:CqActor, dmgTotal:Int) {
		other.doKill(dmgTotal);
		// todo
		if (Std.is(this, CqPlayer)) {
			var mob = cast(other, CqMob);
			
			HxlLog.append("You kill");
			PtPlayer.kills();
			
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
			
			setAlpha(1.00); // must set alpha before the message or the message won't show!
			if (message == null) message = (Std.is(this, CqPlayer)) ? "You reappear" : "An invisible " + this.name + " appears!";
			GameUI.showEffectText(this, message, 0x6699ff);
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
				other.breakInvisible("You stumble into an invisible " + cast(other, CqMob).name + ".");
				return;
			} else {
				// monsters will sometimes pretend not to bump into you even when they should
				if (Math.random() < .5) {
					other.breakInvisible("You have been discovered!");
				}
				return;
			}
		}
		
		var missed = true;

		if (Math.random() < atk / (atk + def)) {
			// hit
			var dmgMultiplier:Int = 1;
			if(specialEffects.get("damage multipler")!=null)
				dmgMultiplier =  Std.parseInt(specialEffects.get("damage multipler").value);
				
			// do an extra 100% damage if stealthy!
			if (stealthy) dmgMultiplier += 1;
			
			// get our equipped weapon from our bag
			var damageRange = bag.equippedDamage();
			
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
				var lif = other.hp + other.buffs.get("life");
				
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
		visible = (alpha > 0.0);
		showHealthBar(hp < maxHp && visible);
		
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
			if(other.faction != faction && !other.isGhost) {
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
			visible = true;
			// only show hp bar if mob is hurt
			showHealthBar(hp < maxHp && visible);
		} else {
			visible = false;
			showHealthBar(false);
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
	
	public function applyEffect(effect:CqSpecialEffectValue, other:CqActor) {
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
			var hppart:Float = other.hp / other.maxHp;
			var mob = Registery.level.createAndaddMob(other.getTilePos(), Std.int(Math.random() * Registery.player.level), true);
			Registery.level.removeMobFromLevel(HxlGraphics.state, cast(other, CqMob));
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
		
		lastTile = null;
		
		onGainXP.clear();
	}
	
	public function new(PlayerClass:String, ?X:Float = -1, ?Y:Float = -1) {
		playerClassID = PlayerClass;
		
		var classes:StatsFile = Resources.statsFiles.get( "classes.txt" );
		var classEntry:StatsFileEntry = classes.getEntry( "ID", PlayerClass );
		
		if ( classEntry != null ) {
			playerClassName = classEntry.getField( "Name" );
			playerClassSprite = classEntry.getField( "Sprite" );
			
			attack = classEntry.getField( "Attack" );
			defense = classEntry.getField( "Defense" );
			speed = classEntry.getField( "Speed" );
			spirit = classEntry.getField( "Spirit" );
			vitality = classEntry.getField( "Vitality" );
			damage = new Range(1, 1);
		} else {
			throw( "Unknown class." );
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
		super(X, Y);

		lives = Configuration.playerLives;
		money = 0;
		
		maxHp = vitality * 2;
		hp = maxHp;

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

		loadGraphic(SpritePlayer, true, false, Configuration.tileSize, Configuration.tileSize, false, 2.0, 2.0);
		faction = CqPlayer.faction;

		play("idle");

		lastTile = null;
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

	override function updateSprite() {
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
			}
			
			play("idle_" + weaponName);
		}
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
		if (bag.grant(item)){
			// remove item from map
			Registery.level.removeLootFromLevel(state, item);
			
			// perform the special effects (this can't be part of give())
			SoundEffectsManager.play(Pickup);
			item.doPickupEffect();
			GameUI.showEffectText(this, item.name, 0x6699ff);
		} else {
			GameUI.showTextNotification("You need to make some room for it first!", 0xFF001A);
			SoundEffectsManager.play(PotionEquipped);
		}
		
		GameUI.instance.flashInventoryButton();
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
		var currentTile = getTile();
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
		for (spell in bag.spells()) {
			spell.statPoints = spell.statPointsRequired;
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
		visible = false;
		
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
	
	
	function getClosestEnemy(?afterThisOne:CqActor = null):CqActor {
		var best:Float = Registery.level.widthInTiles;
		var target:CqActor = null;
		
		var tooGood:Float = 0;
		
		if (afterThisOne != null) {
			tooGood = Math.abs(tilePos.x - afterThisOne.tilePos.x) + Math.abs(tilePos.y - afterThisOne.tilePos.y);
		}
		
		if (aware > 0 && faction != CqPlayer.faction) {
			target = Registery.player;
			best = Math.abs(tilePos.x - target.tilePos.x) + Math.abs(tilePos.y - target.tilePos.y);
			
			best -= 2; // chase a visible player even when a mirror or something else is a bit closer
		}
		
		for (mob in Registery.level.mobs) {
			var cqmob = cast(mob, CqActor);
			if (cqmob.faction != faction && !cqmob.specialEffects.exists("invisible")) {
				var dist = Math.abs(tilePos.x - mob.tilePos.x) + Math.abs(tilePos.y - mob.tilePos.y);
				if (dist < best) {
					if (dist < tooGood) continue;
					if (dist == tooGood && afterThisOne != null) {
						if (cqmob == afterThisOne) afterThisOne = null;
						continue;
					}
					best = dist;
					target = cqmob;
				}
			}
		}
		
		return target;
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
}
