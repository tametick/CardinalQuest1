package detribus;

import detribus.Resources;
import haxel.HxlUtil;
import haxel.HxlPoint;
import haxel.HxlTilemap;
import haxel.HxlUtil;
import haxel.HxlSprite;
import haxel.HxlGraphics;

class Mob extends Actor
{
	var allowDiagonal:Bool;
	var allowCardinal:Bool;
	var attackRange:Int;
	var memory:Int;
	var rewardXP:Int;
	
	
	// If memoryCounter gets set to -1, mob will follow the player indefinately
	var memoryCounter:Int;
	
	public function new(world:World, X:Float, Y:Float, Hp:Int, Armor:Int, Dodge:Int, Damage:Int, RewardXP:Int)
	{
		armor = 0;
		dodge = 0;
		super(world, X, Y, Armor, Dodge, Damage);
		attackRange = 1;
		allowDiagonal = false;
		allowCardinal = true;
		memory = 5;
		memoryCounter = 0;
		rewardXP = RewardXP;
		_hp = Hp;
	}
	
	public override function setTilePos(TilePos:HxlPoint):HxlPoint {
		super.setTilePos(TilePos);
		if ( _world.currentLevel.getTile(_tilePos.x, _tilePos.y).visibility != Visibility.IN_SIGHT ) {
			visible = false;
		} else {
			visible = true;
		}
		return TilePos;
	}
	
	public function act() {
		var player = _world.player;	
		if ( playerInSightRange() && playerInSight() ) {
			if (playerInAttackRange()) {
				// attack player
				attackPlayer();
			} else {
				// move towards player
				if ( !playerAdjacent() ) {
					moveToward( player.tilePos.x, player.tilePos.y);
				}
					
				memoryCounter = memory;
			}
		} else if ( memoryCounter > 0 || memoryCounter == -1 ) {
			moveToward( player.tilePos.x, player.tilePos.y);
			if ( memoryCounter > 0 ) memoryCounter--;
		} else {
			moveRandom();
		}
	}

	function attackPlayer() {
		//HxlGraphics.log("Attacking player!");
		var player = _world.player;
		player.takeHit(this, damage);
	}
	
	function moveRandom() {
		var adjacent = new Array();
		if ( allowDiagonal ) {
			adjacent.push([ -1, -1]);
			adjacent.push([1, -1]);
			adjacent.push([ -1, 1]);
			adjacent.push([1, 1]);
		}
		if ( allowCardinal ) {
			adjacent.push([1, 0]);
			adjacent.push([ -1, 0]);
			adjacent.push([0, 1]);
			adjacent.push([0, -1]);
		}
		var list = new Array();
		var X:Int;
		var Y:Int;
		for ( i in adjacent ) {
			X = Math.floor(_tilePos.x + i[0]);
			Y = Math.floor(_tilePos.y + i[1]);
			if ( !_world.currentLevel.isBlockingMovement(X, Y) ) list.push(_world.currentLevel.getTile(X, Y));
		}
		if ( list.length == 0 ) return;
		var targetTile:Tile = list[ Math.floor(HxlUtil.random() * list.length) ];
		setTilePos(new HxlPoint(targetTile.mapX, targetTile.mapY));
		moveTo( _world.currentLevel.getTilePos(targetTile.mapX, targetTile.mapY).x + 4, _world.currentLevel.getTilePos(targetTile.mapX, targetTile.mapY).y + 4 );
	}
	
	function playerInSight():Bool {
		var level:Level = _world.currentLevel;
		var isBlocking = function(p:HxlPoint):Bool { 
			if ( p.x < 0 || p.y < 0 || p.x >= level.widthInTiles || p.y >= level.heightInTiles ) return true;
			return level.getTile(Math.round(p.x), Math.round(p.y)).isBlockingView();
		}		
		var player = _world.player;
		var line:Array<HxlPoint> = HxlUtil.getLine(_tilePos, player.tilePos, isBlocking);
		if ( line.length > 0 && line[line.length - 1].x == player.tilePos.x && line[line.length - 1].y == player.tilePos.y ) return true;
		return false;
	}
	
	function playerAdjacent(SkipDiagCheck:Bool=false):Bool {
		var player = _world.player;
		if (allowDiagonal || SkipDiagCheck ) {
			if ( Math.abs(player.tilePos.x - _tilePos.x) <= 1 && Math.abs(player.tilePos.y - _tilePos.y) <= 1 ) 
				return true;
		} else {
			if ( HxlUtil.distance(_tilePos, player.tilePos)  <= 1 )
				return true;
		}
		return false;
	}
	
	function playerInSightRange():Bool {
		var player = _world.player;
		if ( HxlUtil.distance(_tilePos, player.tilePos) <= visionRadius ) 
			return true;
		return false;
	}
	function playerInAttackRange():Bool {
		var player = _world.player;
		if ( HxlUtil.distance(_tilePos, player.tilePos) <= attackRange )
			return true;
		return false;
	}

	function moveToward(X:Dynamic, Y:Dynamic):Bool {
		var level = _world.currentLevel;
		X = Math.floor(X);
		Y = Math.floor(Y);
		if ( level.isBlockingMovement(X, Y) == true ) return false;
		if ( allowDiagonal == true && allowCardinal == false ) {
			var MyPos = Math.floor(_tilePos.x + _tilePos.y);
			var TargetPos = Math.floor(X + Y);
			if ( (MyPos % 2 == 0 && TargetPos % 2 != 0) || (MyPos % 2 != 0 && TargetPos % 2 == 0) ) {
				var adjacent = new Array();
				if ( X >= 1 ) adjacent.push([ -1, 0]);
				if ( Y >= 1 ) adjacent.push([0, -1]);
				if ( Y <= level.heightInTiles - 2 ) adjacent.push([ 0, 1]);
				if ( X <= level.widthInTiles - 2 ) adjacent.push([1, 0]);
				if ( adjacent.length == 0 ) return false;
				var bestDist:Float = -1;
				var bestTile = new Array();
				for ( i in adjacent ) {
					var dist:Float = HxlUtil.distance(_tilePos, new HxlPoint(X+i[0], Y+i[1]));
					if ( bestDist == -1 || dist < bestDist ) {
						bestTile = i;
						bestDist = dist;
					}
				}
				X += bestTile[0];
				Y += bestTile[1];
			}
		}
		var path:Array<HxlPoint> = level.getPath(_tilePos, new HxlPoint(X, Y), allowCardinal, allowDiagonal);
		if ( path == null ) 
			return false;
		
		// only move if you are not stepping on someone else
		if (level.getTile(path[1].x, path[1].y).actor == null ) {
			setTilePos(new HxlPoint(path[1].x, path[1].y));
			moveTo( level.getTilePos(path[1].x, path[1].y).x + 4, level.getTilePos(path[1].x, path[1].y).y + 4 );	
			return true;
		}
		return true;
			
	}

	public override function moveTo(X:Float, Y:Float):Void {
		super.moveTo(X, Y);
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
		HxlGraphics.log("(Mob) My pos: "+_tilePos.x+", "+tilePos.y);

	}
	
	public override function die(killer:Actor) { 
		killer.gainXP(rewardXP);
		_world.currentLevel.killMob(this);
		play("dead");
	}
}

class MobAlpha extends Mob {
	
	public function new(world:World, _player:Player, ?X:Float=0, ?Y:Float=0) 
	{
		super(world, X, Y,16,0,0,15,1);

		loadGraphic(SpritesSmall, true, false, 8, 8);
		addAnimation("idleE", [286], 0);
		addAnimation("walkE", [285, 287], 7);
		addAnimation("idleS", [288], 0);
		addAnimation("walkS", [290, 289, 291, 289], 7);
		addAnimation("idleW", [293], 0);
		addAnimation("walkW", [292, 294], 7);
		addAnimation("idleN", [296], 0);
		addAnimation("walkN", [297, 295, 298, 295], 7);
		addAnimation("dead", [288, 293, 296, 286, 288, 299], 8, false);
		play("idleS");		
		attackRange = 1;
		visionRadius = 5;
		allowCardinal = true;
		allowDiagonal = false;
	}	
	
}

class MobBravo extends Mob {
	
	public function new(world:World, _player:Player, ?X:Float=0, ?Y:Float=0) 
	{
		super(world, X, Y,24,0,1,20,2);
		loadGraphic(SpritesSmall, true, false, 8, 8);
		addAnimation("idleE", [301], 0);
		addAnimation("walkE", [300, 302], 7);
		addAnimation("idleS", [303], 0);
		addAnimation("walkS", [305, 304, 306, 304], 7);
		addAnimation("idleW", [308], 0);
		addAnimation("walkW", [307, 309], 7);
		addAnimation("idleN", [311], 0);
		addAnimation("walkN", [312, 310, 313, 310], 7);
		addAnimation("dead", [303, 308, 311, 301, 303, 314], 8, false);
		play("idleS");		
		attackRange = 1;
		visionRadius = 5;
		allowCardinal = true;
		allowDiagonal = false;
	}	
	
}

class MobCharlie extends Mob {

	public function new(world:World, _player:Player, ?X:Float=0, ?Y:Float=0) 
	{
		super(world,  X, Y,32,1,0,30,5);
		loadGraphic(SpritesSmall, true, false, 8, 8);
		addAnimation("idleE", [316], 0);
		addAnimation("walkE", [315, 317], 7);
		addAnimation("idleS", [318], 0);
		addAnimation("walkS", [320, 319, 321, 319], 7);
		addAnimation("idleW", [323], 0);
		addAnimation("walkW", [322, 324], 7);
		addAnimation("idleN", [326], 0);
		addAnimation("walkN", [327, 325, 328, 325], 7);
		addAnimation("dead", [318, 323, 326, 316, 318, 329], 8, false);
		play("idleS");		
		attackRange = 1;
		visionRadius = 5;
		allowCardinal = true;
		allowDiagonal = false;
	}	

}

class MobDelta extends Mob {
	
	public function new(world:World, _player:Player, ?X:Float=0, ?Y:Float=0) 
	{
		super(world,  X, Y,48,1,1,40,10);
		loadGraphic(SpritesSmall, true, false, 8, 8);
		addAnimation("idleE", [331], 0);
		addAnimation("walkE", [330, 332], 7);
		addAnimation("idleS", [333], 0);
		addAnimation("walkS", [335, 334, 336, 334], 7);
		addAnimation("idleW", [338], 0);
		addAnimation("walkW", [337, 339], 7);
		addAnimation("idleN", [341], 0);
		addAnimation("walkN", [342, 340, 343, 340], 7);
		addAnimation("dead", [333, 338, 341, 331, 333, 344], 8, false);
		play("idleS");		
		attackRange = 1;
		visionRadius = 5;
		allowCardinal = true;
		allowDiagonal = false;
	}	
	
}

class MobEcho extends Mob {
	
	public function new(world:World, _player:Player, ?X:Float=0, ?Y:Float=0) 
	{
		super(world, X, Y,64,1,2,60,20);

		loadGraphic(SpritesSmall, true, false, 8, 8);
		addAnimation("idleE", [346], 0);
		addAnimation("walkE", [345, 347], 7);
		addAnimation("idleS", [348], 0);
		addAnimation("walkS", [350, 349, 351, 349], 7);
		addAnimation("idleW", [353], 0);
		addAnimation("walkW", [352, 354], 7);
		addAnimation("idleN", [356], 0);
		addAnimation("walkN", [357, 355, 358, 355], 7);
		addAnimation("dead", [348, 353, 356, 346, 348, 359], 8, false);
		play("idleS");		
		attackRange = 1;
		visionRadius = 5;
		allowCardinal = true;
		allowDiagonal = false;
	}	
	
}
