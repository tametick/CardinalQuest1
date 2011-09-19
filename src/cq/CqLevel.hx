package cq;

import cq.CqResources;
import cq.CqItem;
import cq.CqSpell;
import cq.CqActor;
import cq.effects.CqEffectSpell;
import cq.ui.CqDecoration;
import cq.states.GameState;

import generators.BSP;
import world.World;
import world.Level;
import world.Mob;
import world.Loot;
import world.Tile;
import world.GameObject;
import world.Decoration;

import haxel.HxlSprite;
import haxel.HxlPoint;
import haxel.HxlState;
import haxel.HxlUtil;
import haxel.HxlGraphics;
import haxel.HxlLog;

import data.Registery;
import data.Resources;
import data.Configuration;
import data.MusicManager;
import data.SaveLoad;

class CqLevel extends Level {
	static var tiles = SpriteTiles.instance;
	static var itemSprites = SpriteItems.instance;
	
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
		if (index == Configuration.lastLevel)
			cast(HxlGraphics.state,GameState).startBossAnim();

	}
	
	
	override public function removeMobFromLevel(state:HxlState, mob:Mob) {
		var cqmob = cast(mob, CqMob);
		
		super.removeMobFromLevel(state, mob);
		
		if (cqmob.healthBar != null) 
			state.remove(cqmob.healthBar);
		
		for (m in mobs) {
			cqmob = cast(m, CqMob);
			if (cqmob.faction != Registery.player.faction) 
				return;
			if (cqmob.isCharmed)
				return;
		}
			
		levelComplete();
	}
	
	override public function addDecoration(t:Tile, state:HxlState) {
		super.addDecoration(t, state);
		
		//return if is door.
		if (Lambda.has( Resources.doors, t.dataNum))
			return;
			
		//return if stair or ladder
		if (Lambda.has( Resources.stairsDown, t.dataNum))
			return;
			
		var floor:Bool = Lambda.has( Resources.walkableAndSeeThroughTiles, t.dataNum);
		var frame:String = floor?CqDecoration.randomFloor():CqDecoration.randomWall();
		var pos:HxlPoint = getPixelPositionOfTile(t.mapX, t.mapY);
		var dec:CqDecoration = new CqDecoration(pos.x, pos.y,frame);
		t.decorations.push( dec );
		addObject(state, dec );
		var minimumZ:Int = 0;
		
		for (loot in t.loots) {
			var field:Dynamic = Reflect.field(loot, "zIndex");
			Reflect.setField(loot, "zIndex", field+1);
			if (field < minimumZ) 
				dec.zIndex = minimumZ = field;
		}
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
		
		playMusicByIndex(index);
		
		tileClass = CqTile;
		
		var tmpWall = tiles.getSpriteIndex("red_wall4");
		var tmpFloor = tiles.getSpriteIndex("red_floor0");
		var tmpDoor = tiles.getSpriteIndex("red_door_close");
		
		var newMapData:Array<Array<Int>>;

		newMapData = BSP.getBSPMap(Configuration.getLevelWidth(), Configuration.getLevelHeight(), tmpWall, tmpFloor, tmpDoor);
		
		/* Dont like to set newMapData twice.. */
		if ( SaveLoad.hasSaveGame() )
			newMapData = SaveLoad.loadDungeonLayout();
		
		trace( index );
		trace( newMapData );
		SaveLoad.saveDungeonLayout( newMapData , index );

		startingLocation = HxlUtil.getRandomTile(Configuration.getLevelWidth(), Configuration.getLevelHeight(), newMapData, Resources.walkableAndSeeThroughTiles);
		
		var tmpDown = tiles.getSpriteIndex("red_down");
		if (index < Configuration.lastLevel) {
			var stairsDown:HxlPoint;
			do {
				stairsDown = HxlUtil.getRandomTile(Configuration.getLevelWidth(), Configuration.getLevelHeight(), newMapData, Resources.walkableAndSeeThroughTiles);
			} while (HxlUtil.distance(stairsDown, startingLocation) > 5); //<10 
			
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

		addChests(Configuration.chestsPerLevel,startingLocation);
		addSpells(Configuration.spellsPerLevel);
		addMobs(Configuration.mobsPerLevel);
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
	
	function addChests(numberOfChests:Int,playerPos:HxlPoint) {
		for (c in 0...numberOfChests){
			var pos; 
			var distFromPlayer;
			var iterations:Int = 0;
			var minChestDistance = 5;
			var minPlayerDistance = 10;
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
	
	public function createAndAddMirror(pos:HxlPoint, levelIndex:Int,?additionalAdd:Bool = false,player:CqPlayer):CqMob
	{
		var tpos = getTilePos(pos.x, pos.y, false);
		var mob:CqMob = CqMobFactory.newMobFromLevel(tpos.x, tpos.y, levelIndex + 1, player);
		mob.faction = player.faction;
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
	
	static var creatures:Array<CqActor>;
	public override function tick(state:HxlState) {
		if(creatures ==null)
			creatures = new Array<CqActor>();
		else
			creatures.splice(0, creatures.length);
			
		creatures.push(Registery.player);
		for (mob in mobs)
			creatures.push(cast(mob, CqActor));
			
		for (creature in creatures) {
			var buffs = creature.buffs;
			var specialEffects = creature.specialEffects;
			var visibleEffects = creature.visibleEffects;
			// remove timed out buffs & visibleEffects
			var timers = creature.timers;
			if (timers.length>0) {
				var expired = new Array();
				for (t in timers) {
					t.ticks--;
					if (t.ticks == 0) {
						
						if(t.buffName!= null) {
							// remove buff effect
							var newVal = buffs.get(t.buffName) - t.buffValue;
							GameUI.showEffectText(creature, (-t.buffValue) + " " + t.buffName , 0xff0000);
							buffs.set(t.buffName, newVal);
						} 
						
						if(HxlUtil.contains(visibleEffects.iterator(), t.buffName)) {
							// remove visibleEffect
							creature.visibleEffects.remove(t.buffName);
						}
						
						if (t.specialEffect != null && HxlUtil.contains(specialEffects.keys(), t.specialEffect.name)) {
							var currentEffect = specialEffects.get(t.specialEffect.name);
		
							if(t.specialEffect.name == "magic_mirror")
								GameUI.showEffectText(creature, "" + "magic mirror" + " expired", 0xff0000);
							else
								GameUI.showEffectText(creature, "" + t.specialEffect.name + " expired", 0xff0000);
							creature.specialEffects.remove(t.specialEffect.name);
							
							switch(currentEffect.name){
								case "charm":
									creature.faction = CqMob.FACTION;
									creature.isCharmed = false;
								case "sleep":
									creature.speed = currentEffect.value;
								case "magic_mirror":
									//spell particle effect
									var mob:CqMob = cast(currentEffect.value, CqMob);
									var eff:CqEffectSpell = new CqEffectSpell(mob.x+mob.width/2, mob.y+mob.height/2);
									eff.zIndex = 1000;
									HxlGraphics.state.add(eff);
									eff.start(true, 1.0, 10);
									removeMobFromLevel(HxlGraphics.state, mob);
									mob = null;
									eff = null;
								default:
									//
							}
							currentEffect = null;
						}
						
						expired.push(t);
					}
				}
				
				// remove expired timers
				for (t in expired) {
					timers.remove(t);
					HxlLog.append("removed expired timer: " + t.buffName);
				}
				
				expired = null;
			}
			
			var speed = creature.speed;
			// Apply speed buffs
			speed += creature.buffs.get("speed");
			speed = Std.int(Math.max(speed, 0));
			// apply spirit buffs
			var spirit = creature.spirit;
			var specialActive = creature.visibleEffects.length >0;
			spirit += creature.buffs.get("spirit");
			spirit = Std.int(Math.max(spirit, 1));
			
			// Charge action & spirit points
			creature.actionPoints += speed;
			if (!specialActive) {
				for (s in creature.equippedSpells) {
					if(s!=null)
						s.spiritPoints = Std.int(Math.min( s.spiritPointsRequired, s.spiritPoints + spirit));
				}
			}
			
			// Move mob if charged
			if ( !Std.is(creature,CqPlayer)  &&  creature.actionPoints>=60 ) {
				if (cast(creature,Mob).act(state)) {
					creature.actionPoints = 0;
				}
			}

			buffs = null;
			specialEffects = null;
			visibleEffects = null;
			timers = null;
		}
	}

}