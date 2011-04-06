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
	}
	
	public override function tick() {
/*		for (var c = 0; c < vars.creatures.length; c++) {
			var buffs = vars.creatures[c].vars.buffs;
			var visibleEffect = vars.creatures[c].vars.visibleEffect;
			// remove timed out buffs & visibleEffects
			var timers = vars.creatures[c].vars.timers;
			if (timers) {
				var expired = [];
				for (var t = 0; t < timers.length; t++) {
					timers[t][0]--;
					if (timers[t][0] == 0) {
						if(buffs[timers[t][1]]){
							// reduce buff
							buffs[timers[t][1]] -= timers[t][2]
						} else if(visibleEffect==timers[t][1]) {
							// remove visibleEffect
							vars.creatures[c].vars.visibleEffect = null;
						}
						expired.push(t);
					}
				}
				
				// remove expired timers
				for (var t=0; t<expired.lenth; t++) 
					timers.remove(expired[t]);
			}
			
			var speed = vars.creatures[c].vars.speed;
			// Apply speed buffs
			if (vars.creatures[c].vars.buffs && vars.creatures[c].vars.buffs.speed) 
				speed += vars.creatures[c].vars.buffs.speed;
			speed = Math.max(speed, 1);
			// apply spirit buffs
			var spirit = vars.creatures[c].vars.spirit;
			var specialActive = vars.creatures[c].vars.visibleEffect != null;
			if (spirit && vars.creatures[c].vars.buffs && vars.creatures[c].vars.buffs.spirit) 
				spirit += vars.creatures[c].vars.buffs.spirit;
			spirit = Math.max(spirit, 1);
			// Charge action & spirit points				
			vars.creatures[c].vars.actionPoints += speed;
			if (spirit && !specialActive)
				vars.creatures[c].vars.spiritPoints = Math.min(360, vars.creatures[c].vars.spiritPoints + spirit);
			
			// Move if charged
			if (c != 0 && vars.creatures[c].vars.actionPoints >= 60) {
				if (vars.creatures[c].act()) {
					vars.creatures[c].vars.actionPoints = 0;
				}
			}
		}*/
	}
	
}

class CqWorld extends World 
{
	public function new() {
		super();
		
		levels.push(new CqLevel(currentLevelIndex));
		currentLevel = levels[currentLevelIndex];
	}
}
