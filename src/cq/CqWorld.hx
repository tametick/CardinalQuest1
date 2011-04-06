package cq;

import cq.CqResources;
import cq.CqItem;
import cq.CqActor;

import haxel.HxlPoint;
import haxel.HxlState;

import generators.BSP;
import world.World;
import world.Level;
import world.Mob;
import world.Loot;
import world.Tile;
import world.GameObject;

import haxel.HxlUtil;
import haxel.HxlGraphics;

import data.Registery;
import data.Configuration;

class CqObject extends GameObjectImpl {
	public function new(X:Float, Y) {
		super(X, Y);
		_tilePos = new HxlPoint(X / Configuration.zoomedTileSize(), Y / Configuration.zoomedTileSize());
	}	
}
class CqTile extends Tile {}

class CqLevel extends Level {
	// fixme - use static function instead
	static var tiles = SpriteTiles.instance;
	static var itemSprites = SpriteItems.instance;

	public function new(index:Int) {
		super(index);
		tileClass = CqTile;
				
		var newMapData = BSP.getBSPMap(CqConfiguration.getLevelWidth(), CqConfiguration.getLevelHeight(), tiles.getSpriteIndex("red_wall4"), tiles.getSpriteIndex("red_floor0"), tiles.getSpriteIndex("red_door_close"));
		startingLocation = HxlUtil.getRandomTile(CqConfiguration.getLevelWidth(), CqConfiguration.getLevelHeight(), newMapData, tiles.walkableAndSeeThroughTiles);
		
		loadMap(newMapData, SpriteTiles, Configuration.tileSize, Configuration.tileSize, 2.0, 2.0);
		
		
		addChests(CqConfiguration.chestsPerLevel);
		addMobs(CqConfiguration.mobsPerLevel);
	}
	
	function addChests(numberOfChests:Int) {
		for (c in 0...numberOfChests){
			var pos; 
			do {
				pos = HxlUtil.getRandomTile(CqConfiguration.getLevelWidth(), CqConfiguration.getLevelHeight(), mapData, tiles.walkableAndSeeThroughTiles);
			} while (cast(getTile(pos.x, pos.y), CqTile).loots.length > 0);
			
			createAndaddChest(pos);
		}
	}

	function addMobs(numberOfMobs:Int) {
		for (c in 0...numberOfMobs){
			var pos; 
			do {
				pos = HxlUtil.getRandomTile(CqConfiguration.getLevelWidth(), CqConfiguration.getLevelHeight(), mapData, tiles.walkableAndSeeThroughTiles);
			} while (cast(getTile(pos.x, pos.y), CqTile).actors.length > 0 && cast(getTile(pos.x, pos.y), CqTile).loots.length > 0);
			
			createAndaddMob(pos, index);
		}
	}

	
	function createAndaddChest(pos:HxlPoint) {
		var pixelPos = getPixelPositionOfTile(pos.x, pos.y);
		var chest = new CqChest(pixelPos.x, pixelPos.y);
		
		// add to level loot list
		loots.push(chest);
		// add to tile loot list
		cast(getTile(pos.x, pos.y), CqTile).loots.push(chest);
	}
	
	function createAndaddMob(pos:HxlPoint, levelIndex:Int) {
		var pixelPos = getPixelPositionOfTile(pos.x, pos.y);
		var mob = CqMobFactory.newMobFromLevel(pixelPos.x, pixelPos.y, levelIndex);
		
		// add to level mobs list
		mobs.push(mob);
		// add to tile actors list
		cast(getTile(pos.x, pos.y), CqTile).actors.push(mob);
		// call world's ActorAdded static method
		CqWorld.onActorAdded(mob);
	}
	
	public override function tick(state:HxlState) {
		var creatures:Array<CqActor> = new Array<CqActor>();
		creatures.push(cast(Registery.player, CqActor));
		for (mob in mobs)
			creatures.push(cast(mob, CqActor));
			
		for (creature in creatures) {
			var buffs = creature.buffs;
			var visibleEffects = creature.visibleEffects;
			// remove timed out buffs & visibleEffects
			var timers = creature.timers;
			if (timers.length>0) {
				var expired = [];
				for (t in timers) {
					t.ticks--;
					if (t.ticks == 0) {
						// reduce buff
						var newVal = buffs.get(t.buffName) - t.buffValue;
						buffs.set(t.buffName, newVal);
						if(HxlUtil.contains(visibleEffects, t.buffName)) {
							// remove visibleEffect
							creature.visibleEffects.remove(t.buffName);
						}
						expired.push(t);
					}
				}
				
				// remove expired timers
				for (t in expired) 
					timers.remove(t);
			}
			
			var speed = creature.speed;
			// Apply speed buffs
			speed += creature.buffs.get("speed");
			speed = Std.int(Math.max(speed, 1));
			// apply spirit buffs
			var spirit = creature.spirit;
			var specialActive = creature.visibleEffects.length >0;
			spirit += creature.buffs.get("spirit");
			spirit = Std.int(Math.max(spirit, 1));
			
			// Charge action & spirit points				
			creature.actionPoints += speed;
			if (!specialActive)
				creature.spiritPoints = Std.int(Math.min(360, creature.spiritPoints + spirit));
			
			// Move mob if charged
			if ( !Std.is(creature,CqPlayer)  &&  creature.actionPoints>=60 ) {
				if (creature.act(state)) {
					creature.actionPoints = 0;
				}
			}
		}
	}
	
}

class CqWorld extends World 
{
	static public var actorAdded:Dynamic = null;

	public function new() {
		super();
		
		levels.push(new CqLevel(currentLevelIndex));
		currentLevel = levels[currentLevelIndex];
	}

	static public function onActorAdded(Actor:CqActor):Void {
		if ( actorAdded != null ) actorAdded();
	}
}
