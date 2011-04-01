package cq;

import cq.CqResources;
import haxel.HxlPoint;
import haxel.HxlState;

import generators.BSP;
import world.World;
import world.Level;
import world.Mob;
import world.Loot;
import world.Tile;
import haxel.HxlUtil;
import haxel.HxlGraphics;

import data.Registery;

class CqTile extends Tile {

}

class CqLevel extends Level {	
	// fixme - use static function instead
	static var tiles = new SpriteTiles();
	static var itemSprites = new SpriteItems();
	
	public function new() {
		super();
		tileClass = CqTile;
		
				
		var newMapData = BSP.getBSPMap(CqConfiguration.getLevelWidth(), CqConfiguration.getLevelHeight(), tiles.getSpriteIndex("red_wall4"), tiles.getSpriteIndex("red_floor0"), tiles.getSpriteIndex("red_door_close"));
		startingLocation = HxlUtil.getRandomTile(CqConfiguration.getLevelWidth(), CqConfiguration.getLevelHeight(), newMapData, tiles.walkableAndSeeThroughTiles);
		
		loadMap(newMapData, SpriteTiles, CqConfiguration.tileSize, CqConfiguration.tileSize, 2.0, 2.0);
		
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
		var idx = itemSprites.getSpriteIndex("chest");
		// add to level loot list
		// add to tile loot list
		
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
