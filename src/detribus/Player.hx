package detribus;

import detribus.Resources;
import detribus.Perks;
import detribus.Loot;
import detribus.StateGame;

import haxel.HxlGraphics;
import haxel.HxlSprite;
import haxel.HxlState;
import haxel.HxlSound;
import com.eclecticdesignstudio.motion.Actuate;

import detribus.Sdrl;

class Player extends Actor
{
	public var isMoving:Bool;
	public var range:Int;
	public var xp:Int;
	public var level:Int;
	
	// used to calculate level-up
	public var levelingBase:Int;
	public var levelingFactor:Int;
	//
	
	public var lives:Int;
	public var perks:Perks;
	public var activePowerUps:Array<Loot>;
	
	public function new(world:World, ?X:Float=0, ?Y:Float=0) 
	{
		
		armor = 0;
		dodge = 0;
		damage = 15;
		super(world, X, Y, armor, dodge, damage);
		_maxHp = _hp = 90;
		
		loadGraphic(SpritesSmall, true, false, 8, 8);
		addAnimation("idleE", [271], 0);
		addAnimation("walkE", [270, 272], 7);
		addAnimation("idleS", [273], 0);
		addAnimation("walkS", [275, 274, 276, 274], 7);
		addAnimation("idleW", [278], 0);
		addAnimation("walkW", [277, 279], 7);
		addAnimation("idleN", [281], 0);
		addAnimation("walkN", [282, 280, 283, 280], 7);
		addAnimation("dead", [271, 281, 278, 273, 284], 7, false);
		play("idleS");

		range = Std.int(visionRadius)-1;
		
		xp = 0;
		level = 1;
		levelingBase = 2;
		levelingFactor = 4;
		lives = 3;
		
		
		perks = new Perks();
		activePowerUps = new Array<Loot>();
		name = "Abraxis";
	}
	
	public override function gainXP(XP:Int) {
		//trace("Gaining " + XP + " xp!");
		this.xp += XP;
		//trace("Now have " + this.xp + " xp");
		if (  this.xp  >=  levelingFactor * Math.pow(levelingBase,level+1)  ) {
			gainLevel();
			//trace("Gained level!");
		}
	}
	
	function gainLevel() {
		cast(_world.playState, StateGame).toggleLevelUp();
	}
	
	public function enterWorld(world:World) {
		this._world = world;
		/*
		var perkArray = perks.getAllPerkValues();
		for (  i in 0...perkArray.length ) {
			trace(perks.perkName(i) + ": " + perks.getPerkValue(i));
		}
		*/

	}
	
	public function face(direction:Int):Void 
	{
		_facing = direction;
		switch (_facing) {
			case HxlSprite.LEFT:
				play("idleW");
			case HxlSprite.RIGHT:
				play("idleE");
			case HxlSprite.UP:
				play("idleN");
			case HxlSprite.DOWN:
				play("idleS");
		}
	}
	
	public function decrementActivePowerUps() {
		var expiredPUs = new Array<Loot>();
		for (pu in activePowerUps) {
			if (pu.duration > 0) {
				pu.duration--;
				if (pu.duration == 0)
					expiredPUs.push(pu);
			}
		}
		
		for (pu in expiredPUs) {
			var sfx = new HxlSound();
			sfx.loadEmbedded(Powerdown, false);
			sfx.play();
			
			activePowerUps.remove(pu);
			switch(pu.buff) {
				case Buff.DAMAGE:
					damage -= pu.value;
				case Buff.ARMOR:
					armor -= pu.value;
				case Buff.DODGE:
					dodge -= pu.value;
				case Buff.HP:
				case Buff.NONE:
			}
		}
			
	}
	
	public override function moveTo(X:Float, Y:Float) {
		super.moveTo(X, Y);
		isMoving = true;
		if ( X == x || Y == y ) {
			// moving in a cardinal direction
			if ( X < x ) {
				// moving to the west
				_facing = HxlSprite.LEFT;
				play("walkW");
			} else if ( X > x ) {
				// moving to the east
				_facing = HxlSprite.RIGHT;
				play("walkE");
			} else if ( Y < y ) {
				// moving to the north
				_facing = HxlSprite.UP;
				play("walkN");
			} else if ( Y > y ) {
				// moving to the south
				_facing = HxlSprite.DOWN;
				play("walkS");
			}	
		} else if ( X < x ) {
			// Moving diagonally to the west
			_facing = HxlSprite.LEFT;
			play("walkW");
		} else if ( X > x ) {
			// Moving diagonally to the east
			_facing = HxlSprite.RIGHT;
			play("walkE");	
		}

	}
	
	public override function moveStop():Void {
		super.moveStop();
		isMoving = false;
		face(_facing);

		if (_world.currentLevel.getTile(tilePos.x, tilePos.y).loot != null) {
			var loot = _world.currentLevel.getTile(tilePos.x, tilePos.y).loot;
			_world.currentLevel.loots.remove(loot);
			_world.playState.remove(loot);
			activePowerUps.push(loot);
			switch(loot.buff) {
				case Buff.DAMAGE:
					damage += loot.value;
				case Buff.ARMOR:
					armor += loot.value;
				case Buff.DODGE:
					dodge += loot.value;
				case Buff.HP:
					_hp = _maxHp;
 					StateGame.healthBar.setWidth( (_hp / _maxHp) );
				case Buff.NONE:
			}
			
			var sfx = new HxlSound();
			sfx.loadEmbedded(Powerup, false);
			sfx.play();
			
			if (Std.is(loot, Gizmo))
				_world.gameOver(true);
		}
		
		if (_world.currentLevel.mapData[Std.int(tilePos.y)][Std.int(tilePos.x)] == 51) {
			_world.currentLevel.startingLocation = tilePos;
			_world.removeAllActors();
			_world.removeAllLoots();
			_world.goToNextLevel();
			_world.addAllActors();
			_world.addAllLoots();
		} else if (_world.currentLevel.mapData[Std.int(tilePos.y)][Std.int(tilePos.x)] == 54) {
			_world.currentLevel.startingLocation = tilePos;
			_world.removeAllActors();
			_world.removeAllLoots();
			_world.goToPreviousLevel();			
			_world.addAllActors();
			_world.addAllLoots();
		}
		var stateGame:StateGame = cast(_world.playState, StateGame);
		stateGame.updateFieldOfView(true);
		stateGame.remove(StateGame.healthBar);
		stateGame.add(StateGame.healthBar);
		
		//HxlGraphics.log("My pos: "+_tilePos.x+", "+tilePos.y);
	}

	
	public function shoot(targetX:Float, targetY:Float) {
		var targetXInPixels = targetX * Resources.tileSize;
		var targetYInPixels = targetY * Resources.tileSize;
		
		_world.playState.add(new Projectile(_world, this, x, y, targetXInPixels + 4, targetYInPixels + 4, damage));
		var sfx = new HxlSound();
		sfx.loadEmbedded(Shot, false);
		sfx.play();
	}

	public override function takeHit(src:Actor, damage:Int) {
		//trace("Player has been hit!");
		super.takeHit(src, damage);
		var sfx = new HxlSound();
		sfx.loadEmbedded(Shot2, false);
		sfx.play();
		StateGame.healthBar.setWidth( (_hp / _maxHp) );
	}
	
	public override function die(killer:Actor) {
		Actuate.stop(this, {}, false);
		play("dead");
		_world.playerDead(this);
	}
}
