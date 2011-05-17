package cq;

import cq.CqResources;
import cq.CqItem;
import cq.CqSpell;
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
import haxel.HxlLog;

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
	
/*	
 *  todo = render decorations
	override function render():Void {
		super.render();
		if ( decorations.length>0 ) {
			...
		}
	}
 */
}

class CqLevel extends Level {
	static var tiles = SpriteTiles.instance;
	static var itemSprites = SpriteItems.instance;

	public function getColor():String {
		if (index < 4)
			return "blue";
		else if (index < 8)
			return "brown";
		else
			return "red";
	}
	
	public function new(index:Int) {
		super(index);
		tileClass = CqTile;
		
		var tmpWall = tiles.getSpriteIndex("red_wall4");
		var tmpFloor = tiles.getSpriteIndex("red_floor0");
		var tmpDoor = tiles.getSpriteIndex("red_door_close");
		var tmpDown = tiles.getSpriteIndex("red_down");
		
		var newMapData = BSP.getBSPMap(CqConfiguration.getLevelWidth(), CqConfiguration.getLevelHeight(), tmpWall, tmpFloor, tmpDoor);

		if(index<CqConfiguration.lastLevel) {
			startingLocation = HxlUtil.getRandomTile(CqConfiguration.getLevelWidth(), CqConfiguration.getLevelHeight(), newMapData, tiles.walkableAndSeeThroughTiles);
			var stairsDown:HxlPoint;
			do {
				stairsDown = HxlUtil.getRandomTile(CqConfiguration.getLevelWidth(), CqConfiguration.getLevelHeight(), newMapData, tiles.walkableAndSeeThroughTiles);
			} while (HxlUtil.distance(stairsDown, startingLocation) < 10);
			
			newMapData[Std.int(stairsDown.y)][Std.int(stairsDown.x)] = tmpDown;
		}
		

		for (y in 0...newMapData.length) {
			for (x in 0...newMapData[0].length) {
				var suffix = "";
				switch(newMapData[y][x]) {
					case tmpWall:
						suffix = "wall"+(1+HxlUtil.randomInt(3));
					case tmpFloor:
						suffix = "floor0";
					case tmpDoor:
						suffix = "door_close";
					case tmpDown:
						suffix = "down";
					default:
				}
				
				var prefix = getColor()+"_";
				
				newMapData[y][x] =  tiles.getSpriteIndex(prefix+suffix);
			}
		}
		
		loadMap(newMapData, SpriteTiles, Configuration.tileSize, Configuration.tileSize, 2.0, 2.0);
	
		// mark as visible in fov
		markInvisible();

		addChests(CqConfiguration.chestsPerLevel);
		addSpells(CqConfiguration.spellsPerLevel);
		addMobs(CqConfiguration.mobsPerLevel);
	}
	
	function markInvisible() {
		for ( Y in 0...heightInTiles ) {
			for ( X in 0...widthInTiles ) {
				_tiles[Y][X].visible = false;
			}
		}
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
	
	function chestsNearby(pos:HxlPoint):Int {
		var chests = 0;
		
		for (chest in loots) {
			if (HxlUtil.distance(chest.tilePos, pos) < 5)
				chests ++;
		}
		
		return chests;
	}
	
	function addChests(numberOfChests:Int) {
		for (c in 0...numberOfChests){
			var pos; 
			do {
				pos = HxlUtil.getRandomTile(CqConfiguration.getLevelWidth(), CqConfiguration.getLevelHeight(), mapData, tiles.walkableAndSeeThroughTiles);
			} while (chestsNearby(pos)>0);
			
			createAndaddChest(pos);
		}
	}

	function addMobs(numberOfMobs:Int) {
		for (c in 0...numberOfMobs){
			var pos; 
			do {
				pos = HxlUtil.getRandomTile(CqConfiguration.getLevelWidth(), CqConfiguration.getLevelHeight(), mapData, tiles.walkableAndSeeThroughTiles);
			} while (!isValidMobPosition(pos));
			
			createAndaddMob(pos, index);
		}
	}
	
	function isValidMobPosition(pos:HxlPoint):Bool {
		var numberOfActors = cast(getTile(pos.x, pos.y), CqTile).actors.length;
		var numberOfLoot = cast(getTile(pos.x, pos.y), CqTile).loots.length;
		var distFromPlayer = HxlUtil.distance(pos, startingLocation);
		
		return (numberOfActors == 0 && numberOfLoot == 0 && distFromPlayer >= 5);
	}

	function createAndaddSpell(pos:HxlPoint) {
		var pixelPos = getPixelPositionOfTile(pos.x, pos.y);
		var spell = CqSpellFactory.newRandomSpell(pixelPos.x, pixelPos.y);
			
		// todo - the null check is because not all spells are there yet
		if(spell!=null){
			// add to level loot list
			loots.push(spell);

			// add to tile loot list
			cast(getTile(pos.x, pos.y), CqTile).loots.push(spell);
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
			var specialEffects = creature.specialEffects;
			var visibleEffects = creature.visibleEffects;
			
			// remove timed out buffs & visibleEffects
			var timers = creature.timers;
			if (timers.length>0) {
				var expired = [];
				for (t in timers) {
					t.ticks--;
					if (t.ticks == 0) {
						
						if(t.buffName!= null) {
							// reduce buff
							var newVal = buffs.get(t.buffName) - t.buffValue;
							buffs.set(t.buffName, newVal);
							GameUI.showEffectText(creature, "-" + t.buffValue+ " " + t.buffName , 0xff0000);
						} 
						
						if(HxlUtil.contains(visibleEffects.iterator(), t.buffName)) {
							// remove visibleEffect
							creature.visibleEffects.remove(t.buffName);
						}
						
						if (HxlUtil.contains(specialEffects.iterator(), t.specialEffect)) {
							var currentEffect = specialEffects.get(t.specialEffect.name);
							
							GameUI.showEffectText(creature, "" + t.specialEffect.name + " expired", 0xff0000);
							creature.specialEffects.remove(t.specialEffect.name);
						}
						
						expired.push(t);
					}
				}
				
				// remove expired timers
				for (t in expired) {
					timers.remove(t);
					HxlLog.append("removed expired timer: " + t.buffName);
				}
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
		CqSpellFactory.remainingSpells = SpriteSpells.instance.spriteNames[0].copy();
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

		currentLevel.zIndex = -1;	
		state.add(currentLevel);
		currentLevel.updateFieldOfView(true);
		doOnNewLevel();
	}

	static public function onActorAdded(Actor:CqActor):Void {
		if ( actorAdded != null ) actorAdded();
	}
}
