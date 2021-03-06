package cq;

import cq.CqResources;
import cq.CqItem;
import cq.CqSpell;
import cq.CqActor;
import cq.effects.CqEffectSpell;
import cq.ui.CqDecoration;
import cq.states.GameState;
import data.io.SaveGameIO;
import data.SaveSystem;
import haxel.GraphicCache;

import generators.BSP;
import world.World;
import world.Level;
import world.Mob;
import world.Loot;
import world.Tile;
import world.GameObject;

import haxel.HxlSprite;
import haxel.HxlPoint;
import haxel.HxlState;
import haxel.HxlUtil;
import haxel.HxlGraphics;
import haxel.HxlLog;
import haxel.HxlTilemap;

import data.Registery;
import data.Resources;
import data.Configuration;
import data.MusicManager;

class CqLevel extends Level {
	static var tiles = SpriteTiles.instance;
	static var itemSprites = SpriteItems.instance;
	
	override public function destroy() {
		super.destroy();
	}
	
	//With index being the level, walls change on different levels
	public function getColor():String {
		if (index < 2)
			return "blue";
		else if (index < 4)
			return "green";
		else if (index < 6)
			return "brown";
		else
			return "red";
	}
	
	public function levelComplete() { 
		ptLevel.finish();
		if (index == Configuration.lastLevel) {
			// Wipe the save.
			SaveSystem.getLoadIO().clearSave();
			
			cast(HxlGraphics.state,GameState).startBossAnim();
		}
	}
	
	
	override public function removeMobFromLevel(state:HxlState, mob:Mob) {
		var cqmob = cast(mob, CqMob);
		
		// remove the monster from the level
		super.removeMobFromLevel(state, mob);
		
		// get its health bar off the stage
		if (cqmob.healthBar != null) 
			state.remove(cqmob.healthBar);
		
		// if the player just killed a legitimate monster, we'll credit the exploration clock
		if (cqmob.xpValue > 0) {
			ticksSinceNewDiscovery -= 60 * 4;
		}
		
		// now, if we're in a level that has special logic (namely, the last one)
		// that triggers when all monsters are dead, we need to see if this was the last one.
		// we have to skip monsters that are friendly (like magic mirror copies), but we
		// can't count charming as killing.  we must also ignore "encouraging" monsters that
		// grant no xp.
		for (m in mobs) {
			cqmob = cast(m, CqMob);
			if (cqmob.xpValue > 0) {
				if (cqmob.faction != CqPlayer.faction || cqmob.isCharmed) 
					return;
			}
		}
		
		// all monsters have been killed, so we'll go ahead and give all-monsters-dead a chance
		// to run as long as the player is still around (for most levels, this won't do anything.)
		if(Registery.player!=null)
			levelComplete();
	}
	
	override public function addDecoration(t:Tile, state:HxlState) {
		super.addDecoration(t, state);
		
		//return if is door.
		if (Lambda.has( Resources.doors, t.getDataNum()))
			return;
			
		//return if stair or ladder
		if (Lambda.has( Resources.stairsDown, t.getDataNum()))
			return;
			
		var floor:Bool = Lambda.has( Resources.walkableAndSeeThroughTiles, t.getDataNum());

		var dec:Int = floor?CqDecoration.randomFloorIndex():CqDecoration.randomWallIndex();
		t.decorationIndices.push( dec );
		
		var minimumZ:Int = 0;
		
		for (loot in t.loots) {
			var field:Dynamic = Reflect.field(loot, "zIndex");
			Reflect.setField(loot, "zIndex", field+1);
//			if (field < minimumZ) 
//				dec.zIndex = minimumZ = field;
		}
	}
	
	public function startMusic():Void {
		playMusicByIndex(index);
	}
	
	public static function playMusicByIndex(index:Int):Void
	{
		if(index==0)
			MusicManager.play(MainThemeOne);
		else if (index == 4)
			MusicManager.play(MainThemeTwo);
		else if (index == 7)
			MusicManager.play(BossTheme);
	}
	
	public function new(index:Int) {
		super(index,Configuration.tileSize*2,Configuration.tileSize*2);
		
		tileClass = CqTile;
		
		var tmpWall = tiles.getSpriteIndex("red_wall4");
		var tmpFloor = tiles.getSpriteIndex("red_floor0");
		var tmpDoor = tiles.getSpriteIndex("red_door_close");
		
		var newMapData:Array<Array<Int>>;
		var suffix = "";
		var prefix = "";

		newMapData = BSP.getBSPMap(Configuration.getLevelWidth(), Configuration.getLevelHeight(), tmpWall, tmpFloor, tmpDoor);
		
		/* Dont like to set newMapData twice.. */
/*		if ( SaveLoad.hasSaveGame() )
			newMapData = SaveLoad.loadDungeonLayout();
		
		SaveLoad.saveDungeonLayout( newMapData , index );*/

		startingLocation = HxlUtil.getRandomTile(Configuration.getLevelWidth(), Configuration.getLevelHeight(), newMapData, Resources.walkableAndSeeThroughTiles);
		
		var tmpDown = tiles.getSpriteIndex("red_down");
		if (index < Configuration.lastLevel) {
			var stairsDown:HxlPoint;
			do {
				stairsDown = HxlUtil.getRandomTile(Configuration.getLevelWidth(), Configuration.getLevelHeight(), newMapData, Resources.walkableAndSeeThroughTiles);
			} while (HxlUtil.distance(stairsDown, startingLocation) < .3 * _tileWidth); // if you push this constant above .5, it might be possible to fail entirely, so don't!
			
			newMapData[Std.int(stairsDown.y)][Std.int(stairsDown.x)] = tmpDown;
		}
		

		for (y in 0...newMapData.length) {
			for (x in 0...newMapData[0].length) {
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
						suffix = "";
				}
				
				prefix = getColor()+"_";
				
				newMapData[y][x] =  tiles.getSpriteIndex(prefix+suffix);
			}
		}
	
		loadMap(GameUI.getMapFrame(), newMapData, SpriteTiles, SpriteDecorations, Configuration.tileSize, Configuration.tileSize, Configuration.zoom, Configuration.zoom);
	
		// mark as visible in fov
		markInvisible();

		if ( !GameState.loadingGame ) {
			addChests(Configuration.chestsPerLevel,startingLocation);
			addSpells(Configuration.spellsPerLevel);
			addMobs(Configuration.mobsPerLevel);
		}
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
				pos = HxlUtil.getRandomTile(Configuration.getLevelWidth(), Configuration.getLevelHeight(), mapData, Resources.walkableAndSeeThroughTiles);
			} while (cast(getTile(pos.x, pos.y), CqTile).loots.length > 0);
			
			createAndaddSpell(pos);
		}
	}
	function chestsNearby(pos:HxlPoint, ?distance:Int = 5):Int {
		var chests = 0;
		
		for (chest in loots) {
			if (HxlUtil.distance(chest.tilePos, pos) < distance)
			{
				chests++;
			}
		}
		return chests;
	}
	
	function addChests(numberOfChests:Int, playerPos:HxlPoint) 
	{
		//Instantiate
		var pos; 
		var distFromPlayer;
		var iterations:Int;
		var minChestDistance = 5;
		var minPlayerDistance = 10;
		//Try for each chest to put it on the level
		for (c in 0...numberOfChests){
			iterations = 0;
			minChestDistance = 5;
			minPlayerDistance = 10;
			do {//find chest locations that are far apart, but we may run out of space!
				iterations++;
				pos = HxlUtil.getRandomTile(Configuration.getLevelWidth(), Configuration.getLevelHeight(), mapData, Resources.walkableAndSeeThroughTiles);
				//having trouble finding a good place, so find a position thats closer to other chests, but not on a chest or a player
				//less iterations should equal to more groups of chests together
				//they do tend to group around the player, so we need them far away!
				if (iterations > 4) {
					minChestDistance = 4;
					minPlayerDistance = 15;
				}
				if (iterations > 10) {
					minChestDistance = 1;
					minPlayerDistance = 25;
				}
			} while (chestsNearby(pos, minChestDistance) > 0 || playerPos.intEquals(pos));
			createAndaddChest(pos);
		}
	}

	function addMobs(numberOfMobs:Int) {
		for (c in 0...numberOfMobs){
			var pos; 
			do {
				pos = HxlUtil.getRandomTile(Configuration.getLevelWidth(), Configuration.getLevelHeight(), mapData, SpriteTiles.walkableAndSeeThroughTiles);
			} while (!isValidMobPosition(pos));
			
			createAndaddMob(pos, index);
		}
	}
	
	function isValidMobPosition(pos:HxlPoint, ?minDistance:Int = 5):Bool {
		var numberOfActors = cast(getTile(pos.x, pos.y), CqTile).actors.length;
		var numberOfLoot = cast(getTile(pos.x, pos.y), CqTile).loots.length;
		var distFromPlayer = HxlUtil.distance(pos, startingLocation);
		
		return (numberOfActors == 0 && numberOfLoot == 0 && distFromPlayer >= minDistance);
	}
	
	public function protectRespawnPoint() {
		for (m in mobs) {
			var mob = cast(m, CqMob);
			var pos = mob.tilePos;
			var distFromPlayer = HxlUtil.distance(pos, startingLocation);
			
			mob.aware = 0;
			
			if (distFromPlayer < 5) {
				do {
					pos = HxlUtil.getRandomTile(Configuration.getLevelWidth(), Configuration.getLevelHeight(), mapData, SpriteTiles.walkableAndSeeThroughTiles);
				} while (!isValidMobPosition(pos));
				mob.setTilePos(Std.int(pos.x), Std.int(pos.y));
				var bumpto = getPixelPositionOfTile(pos.x, pos.y);
		
				mob.moveToPixel(HxlGraphics.state, bumpto.x, bumpto.y);
			}
		}
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
	
	public function createAndAddMirror(pos:HxlPoint, levelIndex:Int,?additionalAdd:Bool = false, actor:CqActor):CqMob
	{
		var tpos = getTilePos(pos.x, pos.y, false);
		var mob:CqMob = CqMobFactory.newMobFromLevel(tpos.x, tpos.y, levelIndex + 1, actor);
		mob.faction = actor.faction;
		
		// add to level mobs list
		mobs.push(mob);
		// for creating mobs not when initializing the level.
		if (additionalAdd)HxlGraphics.state.add(mob);
		// add to tile actors list
		cast(getTile(pos.x, pos.y), CqTile).actors.push(mob);
		// call world's ActorAdded static method
		CqWorld.onActorAdded(mob);
		return mob;
	}
	public function createAndaddMob(pos:HxlPoint, levelIndex:Int,?additionalAdd:Bool = false):CqMob {
		var pixelPos = getPixelPositionOfTile(pos.x, pos.y);
		var mob:CqMob; 
		if ( Math.random() < 0.1) {
			// out of depth enemy
			mob = CqMobFactory.newMobFromLevel(pixelPos.x, pixelPos.y, levelIndex + 1);
		} else {
			mob = CqMobFactory.newMobFromLevel(pixelPos.x, pixelPos.y, levelIndex);
		}
		// add to level mobs list
		mobs.push(mob);
		// for creating mobs not when initializing the level.
		if (additionalAdd)HxlGraphics.state.add(mob);
		// add to tile actors list
		cast(getTile(pos.x, pos.y), CqTile).actors.push(mob);
		// call world's ActorAdded static method
		CqWorld.onActorAdded(mob);
		return mob;
	}
	
	public override function foundStairs(magically:Bool) {
		super.foundStairs(magically);
		if (!magically) {
			if (getExplorationProgress() > .8) {
				GameUI.showTextNotification(Resources.getString( "NOTIFY_LATE_STAIRS" ), 0xFCF8F8);
			} else {
				GameUI.showTextNotification(Resources.getString( "NOTIFY_STAIRS" ), 0xFCF8F8);
			}
		}
	}
	

	public function randomUnblockedTile(origin:HxlPoint):HxlPoint {
		for (tries in 1...14) {
			var x:Int = Std.int(origin.x + Math.random() * 13 - 6);
			var y:Int = Std.int(origin.y + Math.random() * 11 - 5);
			var tile:CqTile = getTile(x, y);
			
			if (tile != null && tile.visibility == Visibility.IN_SIGHT && !isBlockingMovement(x, y, true)) {
				return new HxlPoint(x, y);
			}
		}
		return null;
	}

	public function tryToSpawnEncouragingMonster() {
		// you get 8 speed-1 turns before the game considers hounding you.  That's more than it sounds like --
		// especially since every new cell you uncover gives you 3 turns back and seeing monsters slows the counter
		// considerably and you're never really speed-1.  Try playing without scumming -- you'll never see this!
		if (ticksSinceNewDiscovery > 60 * 8 && Math.random() < .6) {
			// lots of code duplication from polymorph -- beware!
			
			if (Registery.world.currentLevelIndex == Configuration.lastLevel) {
				// on the last level, we'll never do this to you.  You're welcome.
				ticksSinceNewDiscovery = 0;
				return;
			}
			
			var playerPosition:HxlPoint = Registery.player.tilePos;
			var freePosition:HxlPoint = randomUnblockedTile(playerPosition);
			
			if (freePosition != null) {
				var mob:CqMob = createAndaddMob(freePosition, Std.int((.5 + .5 * Math.random()) * index), true);
				mob.xpValue = 0;
				
				updateFieldOfView(HxlGraphics.state);
				
				ticksSinceNewDiscovery -= 60 * 5; // a new monster every 5 turns or so once you stop exploring (note that the monster itself helps cancel this out)
				
				GameUI.instance.addHealthBar(cast(mob, CqActor));
				
				mob.healthBar.setTween(true);
				
				if (stairsAreFound && getExplorationProgress() > .8) {
					GameUI.showEffectText(mob, Resources.getString( "NOTIFY_LATE_EXPLORE" ), 0xFFEE33);
				} else {
					GameUI.showEffectText(mob, Resources.getString( "NOTIFY_EXPLORE" ), 0xFFEE33);
				}
			}
		}
	}
	
	// we need to move the bulk of this to CqActor
	
	public override function ticks(state:HxlState, player:CqActor) {
		var expired:Array<CqTimer> = [];
		
		while (player.actionPoints < 60) {
			var l:Int = mobs.length + 1;
			var i:Int = 0;
			
			if (ticksSinceNewDiscovery < 0) ticksSinceNewDiscovery = 0;
			ticksSinceNewDiscovery += 1.0;
			
			while (i < l) {
				var creature:CqActor;
				if (i == 0) {
					creature = Registery.player;
				} else {
					creature = cast(mobs[i - 1], CqActor);
				}
			
				if (creature == null)
					continue;
				
				// remove timed out buffs & visibleEffects
				var timers = creature.timers;
				if (timers.length>0) {
					for (t in timers) {
						t.ticks--;
						if (t.ticks == 0) {
							creature.applyTimerEffect(state, t);
							expired.push(t);
						}
					}
					
					// remove expired timers
					for (t in expired) {
						timers.remove(t);
						HxlLog.append(Resources.getString( "LOG_EXPIRED_TIMER" ) + " " + t.buffName);
					}
					
					expired.splice(0, expired.length);
					
					if (creature.dead) {
						l--;
						continue;
					}
				}
				

				// Charge action & spirit points -- offload this into the creature tick

				for (s in creature.bag.spells()) {
					var boost:Int = 0;
					switch ( s.stat ) {
						case "spirit": boost = creature.stats.spirit;
						case "speed": boost = creature.stats.speed;
						case "attack": boost = creature.stats.attack;
						case "defense": boost = creature.stats.defense;
						case "life": boost = creature.stats.life;
					}
					s.statPoints = Std.int(Math.min( s.statPointsRequired, s.statPoints + boost));
				}

				creature.actionPoints += creature.stats.speed;
				
				// Move mob if charged
				if (creature.actionPoints>=60 && !Std.is(creature,CqPlayer)) {
					if (cast(creature,Mob).act(state)) {
						creature.actionPoints = 0;
						// update l in case creature killed another creature
						l = mobs.length + 1;
					}
				}
				
				i++;
			}
		}
	}
	
	public function save( _io:SaveGameIO ) {
		// Save a 32x32 grid of tile data, plus seen status.
		_io.startBlock( "Map" );
		
		_io.writeInt( index );
		
		_io.writeInt( Std.int( startingLocation.x ) );
		_io.writeInt( Std.int( startingLocation.y ) );
		
		for ( y in 0 ... Configuration.getLevelHeight() ) {
			for ( x in 0 ... Configuration.getLevelWidth() ) {
				var graphic:Int;
				var decoration:Int;
				var seen:Int;
				
				graphic = _tiles[y][x].getDataNum();
				
				if ( _tiles[y][x].decorationIndices.length > 0 ) {
					decoration = _tiles[y][x].decorationIndices[0];
				} else {
					decoration = -1;
				}
				
				var tile:CqTile = getTile(x, y);
				switch ( tile.visibility ) {
					case Visibility.UNSEEN: seen = 0;
					case Visibility.SENSED: seen = 1;
					case Visibility.SEEN: seen = 2;
					case Visibility.IN_SIGHT: seen = 3;
				}
				
				_io.writeInt( graphic );
				_io.writeInt( decoration );
				_io.writeInt( seen );
			}
		}
		
		// Save all loots.
		for ( loot in loots ) {
			if ( Std.is( loot, CqChest ) ) {
				_io.startBlock( "Chest" );
				_io.writeInt( Std.int(loot.getTilePos().x) );
				_io.writeInt( Std.int(loot.getTilePos().y) );
			} else {
				cast( loot, CqItem ).save( _io );
			}
		}
		
		// Save all non-player actors, one by one.
		for ( mob in mobs ) {
			if ( Std.is( mob, CqMob ) ) {
				cast( mob, CqMob ).save( _io );
			}
		}
	}
	
	public function load( _io:SaveGameIO ) {
		// Clear old state (destroy all mobs + loot).
		while(mobs.length>0){
			var m:CqMob = cast(mobs.pop(), CqMob);
			removeMobFromLevel(HxlGraphics.state, m);
			m.destroy();
			m = null;
		}
		while(loots.length>0){
			var l:CqItem = cast(loots.pop(), CqItem);
			removeLootFromLevel(HxlGraphics.state, l);
			l.destroy();
			l = null;
		}
		
		_io.seekToBlock( "Map" );

		// Read & apply index...
		index = _io.readInt();
		Registery.world.currentLevelIndex = index;
		
		startingLocation.x = _io.readInt();
		startingLocation.y = _io.readInt();
		
		for ( y in 0 ... 32 ) {
			for ( x in 0 ... 32 ) {
				var graphic:Int = _io.readInt();
				var decoration:Int = _io.readInt();
				var seen:Int = _io.readInt();
				
				mapData[y][x] = graphic;
				updateTileGraphic(x, y, graphic );
				
				_tiles[y][x].decorationIndices = new Array<Int>();
				if ( decoration != -1 ) {
					_tiles[y][x].decorationIndices.push( decoration );
				}
				
				var tile:CqTile = getTile(x, y);
				switch ( seen ) {
					case 0: tile.visibility = Visibility.UNSEEN;
					case 1: tile.visibility = Visibility.SENSED;
					case 2: tile.visibility = Visibility.SEEN;
					case 3: tile.visibility = Visibility.IN_SIGHT;
				}
				
				if ( tile.visibility == Visibility.UNSEEN ) {
					tile.visible = false;
				} else {
					tile.visible = true;
				}

				_alpha = 1;
				_color = 0x00ffffff;
				tile.dirty = true;
				
				// Update A*.
				updateWalkable(x, y);
			}
		}

		// Add chests.
		var chestIdx:Int = -1;
		while ( (chestIdx = _io.seekToBlock( "Chest", chestIdx )) != -1 ) {
			var tileX:Int = _io.readInt();
			var tileY:Int = _io.readInt();

			var pixelPos = getPixelPositionOfTile(tileX, tileY);
			var chest = new CqChest(pixelPos.x, pixelPos.y);
			
			addLootToLevel( HxlGraphics.state, chest );
		}
		
		// Add non-chest items.
		var itemIdx:Int = -1;
		while ( (itemIdx = _io.seekToBlock( "Item", itemIdx )) != -1 ) {
			CqItem.loadItem( _io );
		}
		
		// Load actors.
		var mobIdx:Int = -1;
		while ( (mobIdx = _io.seekToBlock( "Mob", mobIdx )) != -1 ) {
			CqMob.loadActor( _io );
		}
		
		// Sort out everything's visibility and so forth.
		resetBuffer();
//		updateFieldOfView( HxlGraphics.state );
	}
}
