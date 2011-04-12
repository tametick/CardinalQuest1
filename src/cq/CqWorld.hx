package cq;

import cq.CqResources;
import cq.CqItem;
import cq.CqActor;

import generators.BSP;
import world.World;
import world.Level;
import world.Mob;
import world.Loot;
import world.Tile;
import world.GameObject;

import haxel.HxlPoint;
import haxel.HxlState;
import haxel.HxlUtil;
import haxel.HxlGraphics;

import data.Registery;
import data.Configuration;

import flash.geom.Rectangle;

class CqObject extends GameObjectImpl {
	public function new(X:Float, Y) {
		super(X, Y);
		_tilePos = new HxlPoint(X / Configuration.zoomedTileSize(), Y / Configuration.zoomedTileSize());
	}	
}

class CqTile extends Tile {
	public function new(?X:Int = 0, ?Y:Int = 0, ?Rect:Rectangle = null) {
		super(X, Y, Rect);
		visible = false;
	}
}

class CqLevel extends Level {
	// fixme - use static function instead
	static var tiles = SpriteTiles.instance;
	static var itemSprites = SpriteItems.instance;

	public function new(index:Int) {
		super(index);
		tileClass = CqTile;
				
		var newMapData = BSP.getBSPMap(CqConfiguration.getLevelWidth(), CqConfiguration.getLevelHeight(), tiles.getSpriteIndex("red_wall4"), tiles.getSpriteIndex("red_floor0"), tiles.getSpriteIndex("red_door_close"));

		startingLocation = HxlUtil.getRandomTile(CqConfiguration.getLevelWidth(), CqConfiguration.getLevelHeight(), newMapData, tiles.walkableAndSeeThroughTiles);
		var stairsDown:HxlPoint;
		do {
			stairsDown = HxlUtil.getRandomTile(CqConfiguration.getLevelWidth(), CqConfiguration.getLevelHeight(), newMapData, tiles.walkableAndSeeThroughTiles);
		} while (HxlUtil.distance(stairsDown, startingLocation) < 10);
		
		newMapData[Std.int(stairsDown.y)][Std.int(stairsDown.x)] = tiles.getSpriteIndex("red_down");
		
		loadMap(newMapData, SpriteTiles, Configuration.tileSize, Configuration.tileSize, 2.0, 2.0);
	
		// We're going to disable rendering of tiles which will never be visible
		for ( Y in 0...heightInTiles ) {
			for ( X in 0...widthInTiles ) {
				if ( HxlUtil.contains(tiles.solidAndBlockingTiles, _tiles[Y][X].dataNum) ) {
					var pass:Bool = true;
					var ty:Int = Y - 1;
					while ( ty <= Y + 1 ) {
						if ( ty >= 0 && ty < heightInTiles ) {
							var tx:Int = X - 1;
							while ( tx <= X + 1 ) {
								if ( tx >= 0 && tx < widthInTiles ) {
									if ( !HxlUtil.contains(tiles.solidAndBlockingTiles, _tiles[ty][tx].dataNum) ) pass = false;
									if ( !pass ) break;
								}
								tx++;
							}
						}
						if ( !pass ) break;
						ty++;
					}
					if ( pass ) _tiles[Y][X].visible = false;
				}
			}
		}

		addChests(CqConfiguration.chestsPerLevel);
		addSpells(CqConfiguration.spellsPerLevel);
		addMobs(CqConfiguration.mobsPerLevel);
	}
	
	function addSpells(numberOfSpells:Int) {
		for (s in 0...numberOfSpells){
			var pos; 
			do {
				pos = HxlUtil.getRandomTile(CqConfiguration.getLevelWidth(), CqConfiguration.getLevelHeight(), mapData, tiles.walkableAndSeeThroughTiles);
			} while (cast(getTile(pos.x, pos.y), CqTile).loots.length > 0);
			
			createAndaddSpell(pos);
		}
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

	function createAndaddSpell(pos:HxlPoint) {
		var pixelPos = getPixelPositionOfTile(pos.x, pos.y);
		var spell = new CqSpell(pixelPos.x, pixelPos.y, HxlUtil.getRandomElement(SpriteSpells.instance.spriteNames[0]));
		
		// add to level loot list
		loots.push(spell);
		// add to tile loot list
		cast(getTile(pos.x, pos.y), CqTile).loots.push(spell);
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
				if (cast(creature,Mob).act(state)) {
					creature.actionPoints = 0;
				}
			}
		}
	}

}

class CqWorld extends World {

	static public var actorAdded:Dynamic = null;

	var onNewLevel:List<Dynamic>;

	public function new() {
		super();
		
		onNewLevel = new List();
		goToLevel(currentLevelIndex);
	}

	public function addOnNewLevel(Callback:Dynamic):Void {
		onNewLevel.add(Callback);
	}
	
	function doOnNewLevel():Void {
		for ( Callback in onNewLevel ) Callback();
	}

	function goToLevel(level:Int) {
		levels.push(new CqLevel(level));
		currentLevel = levels[level];
		doOnNewLevel();
	}
	
	public override function goToNextLevel(state:HxlState) {
		state.remove(currentLevel);
		
		currentLevelIndex++;
		goToLevel(currentLevelIndex);
		
		state.add(currentLevel);
		currentLevel.updateFieldOfView(true);
		doOnNewLevel();
	}

	static public function onActorAdded(Actor:CqActor):Void {
		if ( actorAdded != null ) actorAdded();
	}
}
