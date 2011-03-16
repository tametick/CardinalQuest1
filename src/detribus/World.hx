package detribus;

import haxel.HxlUtil;
import haxel.HxlState;
import haxel.HxlSound;
import haxel.HxlObject;
import detribus.Resources;
import detribus.LevelGenerator;
import detribus.Loot;

class World 
{
	public var currentLevel:Level;
	var currentLevelIndex:Int;
	var levels:Array<Level>;
	var gen:LevelGenerator;
	
	// fixme: should not be public once world owns all actors
	public var playState: HxlState;
	public var player:Player;
	
	public function new(playState:HxlState,player:Player) {
		currentLevelIndex = 0;
		levels = new Array<Level>();
		gen = new LevelGenerator();

		this.playState = playState;
		this.player = player;
		
		// Wilderness level	
		currentLevel = levels[0] = new Level(this);
		var mapData = gen.getWildernessMap(Resources.wildernessWidth, Resources.wildernessHeight);
		
		var walkableAndSeeThroughTiles = new Array<Int>();
		for (tile in Resources.walkableTiles) {
			if (HxlUtil.contains(Resources.seeThroughTiles, tile))
				walkableAndSeeThroughTiles.push(tile);
		}
		walkableAndSeeThroughTiles.remove(54);
		walkableAndSeeThroughTiles.remove(51);
		
		levels[0].startingLocation = HxlUtil.getRandomTile(Resources.wildernessWidth, Resources.wildernessHeight, mapData, walkableAndSeeThroughTiles);
		gen.addReachableFeature(Resources.wildernessWidth, Resources.wildernessHeight, mapData, levels[0].startingLocation, MapFeatures.CAVE_ENTRY);
		levels[0].loadMap(mapData, Tileset, Resources.tileSize, Resources.tileSize);
		levels[0].createMobs("detribus.MobAlpha",16);

	}
	
	function goToLevel(nextLevel:Int) {
		currentLevelIndex = nextLevel;
		if (levels[currentLevelIndex]==null) {
			currentLevel = levels[currentLevelIndex] = new Level(this);
			var mapData = gen.getCaveMap(Resources.cavesWidth, Resources.cavesHeight);
			levels[currentLevelIndex].startingLocation = HxlUtil.getRandomTile(Resources.cavesWidth, Resources.cavesHeight, mapData, Resources.walkableTiles);
			levels[currentLevelIndex].startingLocation = gen.addReachableFeature(Resources.cavesWidth, Resources.cavesHeight, mapData, levels[currentLevelIndex].startingLocation, MapFeatures.CAVE_STAIRS_UP);

			if (nextLevel < 5) {
				gen.addReachableFeature(Resources.cavesWidth, Resources.cavesHeight, mapData, levels[currentLevelIndex].startingLocation, MapFeatures.CAVE_STAIRS_DOWN);
			}
			
			levels[currentLevelIndex].loadMap(mapData, Tileset, Resources.tileSize, Resources.tileSize);
				
			switch(nextLevel) {
				case 1:
					currentLevel.createMobs("detribus.MobAlpha", 8);
					currentLevel.createMobs("detribus.MobBravo", 8);
				case 2:
					currentLevel.createMobs("detribus.MobBravo", 8);
					currentLevel.createMobs("detribus.MobCharlie", 8);
				case 3:
					currentLevel.createMobs("detribus.MobCharlie", 8);
					currentLevel.createMobs("detribus.MobDelta", 8);
				case 4:
					currentLevel.createMobs("detribus.MobDelta", 8);
					currentLevel.createMobs("detribus.MobEcho", 8);
				case 5:
					currentLevel.createMobs("detribus.MobEcho", 16);
			}
			
			for (pu in 0...10) {
				currentLevel.createRandomPowerUp();
			}
			
			if (nextLevel == 5) {
				// last level
				currentLevel.createGizmo();		
			}
			
		} else {
			currentLevel = levels[currentLevelIndex];
		}
		playState.remove(currentLevel);
		playState.add(currentLevel);
		currentLevel.zIndex = 0;
		currentLevel.follow();
		
		if (currentLevelIndex == 0) {
			// going back to the forest
			StateGame.caveMusic.stop();
			StateTitle.menuMusic.play();
			StateGame.forestMusic.play();
		} else if(StateGame.forestMusic.playing){
			// going into the first cave from the forest
			StateTitle.menuMusic.stop();
			StateGame.forestMusic.stop();	
			StateGame.caveMusic.play();
		}
	}
	
	public function goToNextLevel() {
		goToLevel(currentLevelIndex+1);
	}
	
	public function goToPreviousLevel() {
		goToLevel(currentLevelIndex-1);
	}
	
	public function addAllActors() {
		player.tilePos = currentLevel.startingLocation;
		player.x = currentLevel.getTilePos(player.tilePos.x, player.tilePos.y).x + 4;
		player.y = currentLevel.getTilePos(player.tilePos.x, player.tilePos.y).y + 4;
		playState.add(player);
		
		for (mob in currentLevel.mobs )
			playState.add(mob);
	}
	
	public function removeAllActors() {
		playState.remove(player);
			
		for (mob in currentLevel.mobs )
			playState.remove(mob);
	}
	
	public function addAllLoots() {
		for (loot in currentLevel.loots )
			playState.add(loot);
	}
	
	public function removeAllLoots() {			
		for (loot in currentLevel.loots )
			playState.remove(loot);
	}
	
	public function playerDead(player:Player) {
		gameOver(false);
	}
	
	public function gameOver(victory:Bool) {

		//TODO
		if (victory) {
			var victorySfx = new HxlSound();
			victorySfx.loadEmbedded(Victory, false);
			victorySfx.play();
		}else {
			var deathSfx = new HxlSound();
			deathSfx.loadEmbedded(Death, false);
			deathSfx.play();
		}
		
		if(StateGame.caveMusic.playing)
			StateGame.caveMusic.stop();
		if(!StateTitle.menuMusic.playing)
			StateTitle.menuMusic.play();
		if(StateGame.forestMusic.playing)
			StateGame.forestMusic.stop();

		if ( victory ) {
			cast(playState, StateGame).gameOverDialog.showVictory();
		} else {
			cast(playState, StateGame).gameOverDialog.showDefeat();
		}
	}
}
