package cq;

import cq.CqResources;
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
	public function new() {
		super();
		tileClass = CqTile;
		var tiles = new SpriteTiles();
				
		var newMapData = BSP.getBSPMap(CqConfiguration.getLevelWidth(), CqConfiguration.getLevelHeight(), tiles.getSpriteIndex("red_wall4"), tiles.getSpriteIndex("red_floor0"), tiles.getSpriteIndex("red_door_close"));
		startingLocation = HxlUtil.getRandomTile(CqConfiguration.getLevelWidth(), CqConfiguration.getLevelHeight(), newMapData, tiles.walkableAndSeeThroughTiles);
		
		loadMap(newMapData, SpriteTiles, 16, 16, 2.0, 2.0);
	}
	
	
	public override function onAdd(state:HxlState) {
		addAllActors(state);
		addAllLoots(state);
	}
	
	function addAllActors(state:HxlState) {
		var player = Registery.player;
		player.tilePos = startingLocation;
		player.x = getPixelPositionOfTile(player.tilePos.x, player.tilePos.y).x;
		player.y = getPixelPositionOfTile(player.tilePos.x, player.tilePos.y).y;
		state.add(player);
		
		for (mob in mobs)
			state.add(mob);
	}
	
	function addAllLoots(state:HxlState) {
		
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
