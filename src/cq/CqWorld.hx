package cq;

import cq.CqResources;

import generators.BSP;
import world.World;
import world.Level;
import world.Mob;
import world.Loot;
import world.Tile;
import haxel.HxlUtil;
import haxel.HxlGraphics;


class CqTile extends Tile {

}

class CqLevel extends Level {	
	public function new() 
	{
		super();
		tileClass = CqTile;
		var tiles = new SpriteTiles();
		
		// fix me
		var walkableAndSeeThroughTiles = new Array<Int>();
		walkableAndSeeThroughTiles.push(tiles.getSpriteIndex("red_wall1"));
		// em xif
		
		var newMapData = BSP.getBSPMap(30, 30, tiles.getSpriteIndex("red_wall1"), tiles.getSpriteIndex("red_floor0"), tiles.getSpriteIndex("red_door_close"));
		startingLocation = HxlUtil.getRandomTile(30, 30, newMapData, walkableAndSeeThroughTiles);
		
		// use the following line to see sprite scaling for tilemap images :D
		//loadMap(newMapData, SpriteTiles, 16, 16, 2.0, 2.0);
		loadMap(newMapData, SpriteTiles, 16, 16);

	}
	
}

class CqWorld extends World 
{

	public function new() 
	{
		super();
		
		levels.push(new CqLevel());
		currentLevel = levels[0];
	}
	
}
