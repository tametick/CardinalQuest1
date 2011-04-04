package cq;

import cq.CqResources;
import cq.CqItem;

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
	
	public function new() {
		super();
		tileClass = CqTile;
		
				
		var newMapData = BSP.getBSPMap(CqConfiguration.getLevelWidth(), CqConfiguration.getLevelHeight(), tiles.getSpriteIndex("red_wall4"), tiles.getSpriteIndex("red_floor0"), tiles.getSpriteIndex("red_door_close"));
		startingLocation = HxlUtil.getRandomTile(CqConfiguration.getLevelWidth(), CqConfiguration.getLevelHeight(), newMapData, tiles.walkableAndSeeThroughTiles);
		
		loadMap(newMapData, SpriteTiles, Configuration.tileSize, Configuration.tileSize, 2.0, 2.0);
		
		// place chests
		addChests(CqConfiguration.chestsPerLevel);
	}
	
	function addChests(numberOfChests:Int) {
		for (c in 0...numberOfChests){
			var pos; 
			do {
				pos = HxlUtil.getRandomTile(CqConfiguration.getLevelWidth(), CqConfiguration.getLevelHeight(), mapData, tiles.walkableAndSeeThroughTiles);
			} while (cast(getTile(pos.x, pos.y), CqTile).loots.length > 0);
			
			addChest(pos);
		}
	}
	
	function addChest(pos:HxlPoint) {
		var pixelPos = getPixelPositionOfTile(pos.x, pos.y);
		var chest = new CqChest(pixelPos.x, pixelPos.y);
		
		// add to level loot list
		loots.push(chest);
		
		// add to tile loot list
		cast(getTile(pos.x, pos.y), CqTile).loots.push(chest);
	}
	
}

class CqWorld extends World 
{
	public function new() {
		super();
		
		levels.push(new CqLevel());
		currentLevel = levels[0];
	}
}
