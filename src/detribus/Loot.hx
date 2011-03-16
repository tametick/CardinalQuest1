package detribus;

import detribus.Resources;

import haxel.HxlSprite;
import haxel.HxlPoint;
import haxel.HxlGraphics;

class Loot extends GameObject
{
	public var buff:Buff;
	public var value:Int;
	
	// If duration gets set to -1, power up will buff the player indefinately
	public var duration:Int;
	
	public function new(world:World, ?X:Float = 0, ?Y:Float, buff, amount) {
		super(world, X, Y);
		loadGraphic(SpritesSmall, true, false, 8, 8);
		value = 1;
		this.buff = buff;

		duration = 15;
		
		setTilePos(new HxlPoint(X / Resources.tileSize, Y / Resources.tileSize));
	}
	
	public override function setTilePos(TilePos:HxlPoint):HxlPoint {
		// add to new tile
		_tilePos = TilePos;
		_world.currentLevel.getTile(_tilePos.x, _tilePos.y).loot = this;
		return TilePos;
	}
	
	public static function getNewPowerUp(world:World, xInTiles:Float, yInTiles:Float, type:Buff):Loot {
		switch (type) {
			case DAMAGE:
				return new DamagePowerUp(world, xInTiles * Resources.tileSize, yInTiles * Resources.tileSize);
			case HP:
				return new HPPowerUp(world, xInTiles * Resources.tileSize, yInTiles * Resources.tileSize);
			case DODGE:
				return new DodgePowerUp(world, xInTiles * Resources.tileSize, yInTiles * Resources.tileSize);
			case ARMOR:
				return new ArmorPowerUp(world, xInTiles * Resources.tileSize, yInTiles * Resources.tileSize);
			case NONE:
				return null;
		}
	}
	
	public static function getNewGizmo(world:World, xInTiles:Float, yInTiles:Float):Gizmo {
		return new Gizmo(world, xInTiles * Resources.tileSize, yInTiles * Resources.tileSize);
	}
}

class DamagePowerUp extends Loot {
	public function new(world:World, ?X:Float = 0, ?Y:Float) {
		super(world, X, Y, DAMAGE, 2);
		
		addAnimation("idle", [150], 0);
		play("idle");
	}
}

class HPPowerUp extends Loot {
	public function new(world:World, ?X:Float = 0, ?Y:Float) {
		super(world, X, Y, HP, -1);
				
		addAnimation("idle", [182], 0);
		play("idle");
	}
}

class DodgePowerUp extends Loot {
	public function new(world:World, ?X:Float = 0, ?Y:Float) {
		super(world, X, Y, DODGE, 2);
				
		addAnimation("idle", [197], 0);
		play("idle");
	}
}

class ArmorPowerUp extends Loot {
	public function new(world:World, ?X:Float = 0, ?Y:Float) {
		super(world, X, Y, ARMOR, 2);
		
		addAnimation("idle", [30], 0);
		play("idle");
	}
}

class Gizmo extends Loot {
	public function new(world:World, ?X:Float = 0, ?Y:Float) {
		super(world, X, Y, NONE, -1);
		
		addAnimation("idle", [46], 0);
		play("idle");
	}
}

enum Buff {
	DAMAGE;
	HP;
	DODGE;
	ARMOR;
	NONE;
}