package cq;

import cq.CqResources;

import generators.BSP;
import world.World;
import world.Level;
import world.Mob;
import world.Loot;
import world.Tile;
import haxel.HxlUtil;


class CqTile extends Tile {

}

class CqLevel extends Level {	
	public function new() 
	{
		super();
		tileClass = CqTile;
		
		// fix me
		var walkableAndSeeThroughTiles = new Array<Int>();
		walkableAndSeeThroughTiles.push(3);
		// em xif
		
		var newMapData = BSP.getBSPMap(30, 30, 8, 3, 10);
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
