package world;

import com.eclecticdesignstudio.motion.Actuate;
import cq.CqActor;
import cq.CqItem;
import cq.CqResources;
import data.Registery;
import data.Resources;
import flash.display.Bitmap;
import com.baseoneonline.haxe.astar.PathMap;
import flash.system.System;

import haxel.HxlPoint;
import haxel.HxlTilemap;
import haxel.HxlState;
import haxel.HxlGraphics;
import haxel.HxlUtil;
import haxel.HxlSprite;


import data.Registery;

import playtomic.PtLevel;

import data.Configuration;
import cq.states.WinState;

import com.baseoneonline.haxe.astar.IAStarSearchable;

class Level extends HxlTilemap, implements IAStarSearchable {
	public var mobs:Array<Mob>;
	public var loots:Array<Loot>;
	public var startingLocation:HxlPoint;
	public var index(default, null):Int;
	public var ticksSinceNewDiscovery:Float; // float for convenient arithmetic
	public var stairsAreFound:Bool;
	
	public static inline var CHANCE_DECORATION:Float = 0.2;
	
	var ptLevel:PtLevel;
	
	public function new(index:Int,tileW:Int,tileH:Int) {
		super(tileW,tileH);
		
		this.index = index;
		mobs = new Array();
		loots = new Array();
		startingIndex = 1;
		ptLevel = new PtLevel(this);
		ticksSinceNewDiscovery = 0;
		stairsAreFound = false;
	}
	
	public function isBlockingMovement(X:Int, Y:Int, ?CheckActor:Bool=false):Bool { 
		if ( X < 0 || Y < 0 || X >= widthInTiles || Y >= heightInTiles ) 
			return true;
		if ( CheckActor && cast(_tiles[Y][X], Tile).actors.length>0 )
			return true;
		return _tiles[Y][X].isBlockingMovement();
	}
	
	public function isBlockingView(X:Int, Y:Int):Bool {
		if ( X < 0 || Y < 0 || X >= widthInTiles || Y >= heightInTiles ) 
			return true;
		return _tiles[Y][X].isBlockingView();
	}
	
	public override function onAdd(state:HxlState) {
		super.onAdd(state);
		
		addAllActors(state);
		addAllLoots(state);
		ptLevel.start();
		//follow();
		HxlGraphics.follow(Registery.player, 10);
	}
	
	override public function destroy() {
		removeAllActors(HxlGraphics.state);
		removeAllLoots(HxlGraphics.state);
		removeAllDecorations(HxlGraphics.state);
		ptLevel.destroy();
		
		ptLevel = null;
		startingLocation = null;
		
		HxlGraphics.unfollow();
		
		Actuate.reset();
		
		super.destroy();
	}
	
	public override function onRemove(state:HxlState) {
		super.onRemove(state);
	}
	
	public function addMobToLevel(state:HxlState, mob:Mob) {
		mobs.push(mob);
		var tile = cast(getTile(mob.getTilePos().x, mob.getTilePos().y), Tile);
		tile.actors.push(mob);
		addObject(state, mob);
	}
	
	public function removeMobFromLevel(state:HxlState, mob:Mob) {
		if (mob == null) return; // safety against timing issues
		
		// take the monster out of the global list of monsters
		mobs.remove(mob);
		
		// take the monster out of the tile it was in
		var mobPos = null;
		mobPos = mob.getTilePos();
		
		if (mobPos!=null) {
			var mobTile = null;
			mobTile = cast(getTile(mobPos.x, mobPos.y), Tile);
			
			if(mobTile.actors!=null)
				mobTile.actors.remove(mob);			
		}
		
		// remove the monster from the graphical stage
		state.remove(mob);
	}
	
	function addObject(state:HxlState, obj:GameObject) {
		state.add(obj);
	}
	
	function addAllActors(state:HxlState) {
		var player = Registery.player;
		player.setTilePos(Std.int(startingLocation.x),Std.int(startingLocation.y));
		player.x = getPixelPositionOfTile(player.tilePos.x, player.tilePos.y).x;
		player.y = getPixelPositionOfTile(player.tilePos.x, player.tilePos.y).y;
		state.add(player);
		
		for (mob in mobs)
			addObject(state, mob);
			
		player = null;
		state = null;
	}
	
	public function addLootToLevel(state:HxlState, loot:Loot) {
		// add item to level loot list
		loots.push(loot);
		// add item to tile loot list
		var tile = cast(getTile(loot.getTilePos().x, loot.getTilePos().y), Tile);
		tile.loots.push(loot);
		// make item viewable on level
		addObject(state, loot);
	}
	
	function addLoot(state:HxlState, loot:Loot) {
		state.add(loot);
	}
	
	function addAllLoots(state:HxlState) {
		for (loot in loots )
			addObject(state,loot);
	}
	
	public function removeAllActors(state:HxlState) {
		if(Registery.player!=null)
			state.remove(Registery.player);
			
		var m:CqMob;
		while(mobs.length>0){
			m = cast(mobs.pop(), CqMob);
			removeMobFromLevel(state, m);
			m.destroy();
			m = null;
		}
		
		mobs = null;
	}
	
	public function removeAllLoots(state:HxlState) {			
		var l:CqItem;
		while (loots.length > 0) {
			l = cast(loots.pop(),CqItem);
			removeLootFromLevel(state, l);
			l.destroy();
			l = null;
		}
			
		loots = null;
	}
	
	public function removeLootFromLevel(state:HxlState, loot:Loot) {
		loots.remove(loot);
		
		var lootPos = loot.getTilePos();		
		var lootTile = cast(getTile(lootPos.x, lootPos.y), Tile);
		lootTile.loots.remove(loot);
		
		state.remove(loot);
		
		lootPos = null;
		lootTile  = null;
	}
	
	override public function loadMap(MapData:Array<Array<Int>>, TileGraphic:Class<Bitmap>, ?TileWidth:Int = 0, ?TileHeight:Int = 0, ?ScaleX:Float=1.0, ?ScaleY:Float=1.0):HxlTilemap {
		var map = super.loadMap(MapData, TileGraphic, TileWidth, TileHeight, ScaleX, ScaleY);
		
		for (y in 0...map.heightInTiles) {
			for (x in 0...map.widthInTiles) {
				cast(_tiles[y][x], Tile).level = this;
				_tiles[y][x].color = 0x000000;
			}
		}

		return map;
	}
	
	/**
	 * Slightly less confusing name in this context
	 */
	public function getPixelPositionOfTile(X:Dynamic, Y:Dynamic, ?Center:Bool = false):HxlPoint {
		return super.getTilePos(X, Y, Center);
	}
		
	public function addDecoration(t:Tile, state:HxlState) {	}
	
	public function removeAllDecorations(state:HxlState) {
		for (y in 0...heightInTiles) {
			for (x in 0...widthInTiles) {
				var t:Tile = cast(_tiles[y][x], Tile);
				for(dec in t.decorations) {
					state.remove(dec);
				}
				t.decorations = null;
			}
		}
	}
	
	inline function isBlockedFromAllSides(x:Int,y:Int):Bool {
		var blocked = (x == 0 || getTile(x - 1, y).isBlockingMovement());
		blocked = blocked && (x == widthInTiles - 1 || getTile(x + 1, y).isBlockingMovement());
		blocked = blocked && (y == heightInTiles - 1 || getTile(x, y + 1).isBlockingMovement());
		blocked = blocked && (y == 0 || getTile(x, y - 1).isBlockingMovement());
		
		blocked = blocked && ((x==0 || y==0)  ||  getTile(x - 1, y-1).isBlockingMovement());
		blocked = blocked && ((x==widthInTiles-1 || y==heightInTiles-1)  ||  getTile(x + 1, y+1).isBlockingMovement());
		blocked = blocked && ((x==0 || y==heightInTiles-1) ||  getTile(x-1, y + 1).isBlockingMovement());
		blocked = blocked && ((x==widthInTiles-1 || y==0)  ||  getTile(x+1, y - 1).isBlockingMovement());
		
		return blocked;
	}
	
	public function showAll(state:HxlState) {
		for ( x in 0...widthInTiles-1 ) {
			for ( y in 0...heightInTiles - 1) {
				if(!isBlockedFromAllSides(x,y)){
					var tile = cast(getTile(x, y),Tile);

					firstSeen(state, this, new HxlPoint(x, y), Visibility.SENSED);
					tile.visible = true;
					tile.color = 0xffffff;
						
					for (loot in tile.loots)
						cast(loot,HxlSprite).visible = true;
					for (actor in tile.actors)
						cast(actor,HxlSprite).visible = true;
					for (decoration in tile.decorations)
						cast(decoration,HxlSprite).visible = true;
				}
			}
		}
		
		updateFieldOfView(state, Registery.player);
	}

	/** gets called for each tile EVERY time it is seen (not just the first time) **/
	static function firstSeen(state:HxlState, map:Level, p:HxlPoint, newvis:Visibility) { 
		if (map == null || p == null)
			return;
		
		var t:Tile = map.getTile(Math.round(p.x), Math.round(p.y));
		if (t == null)
			return;
		
		if (t.visibility == Visibility.UNSEEN) {
			if (Math.random() < CHANCE_DECORATION) {
				map.addDecoration(t, state);
			}
			
			if (HxlUtil.contains(SpriteTiles.stairsDown.iterator(), t.dataNum)) {
				map.stairsAreFound = true;
			}

			if (newvis == Visibility.SENSED) {
				t.visibility = Visibility.SENSED;
			}
		}
		
		if (newvis != Visibility.SENSED) {
			if (t.visibility != Visibility.IN_SIGHT) {
				// have to tweak this until it feels right -- but we don't want to reset it to 0 or optimal
				// play will call for waiting until just before dudes start appearing
				
				t.timesUncovered++;
				switch (t.timesUncovered) {
					case 1: map.ticksSinceNewDiscovery -= 3 * 60; // every cell we see pays off 3 turns of hanging around (quite a lot, really)
					case 2: map.ticksSinceNewDiscovery -= 2 * 60; // take off two turn every time you uncover something twice (hey, at least you're still moving)
					case 3: map.ticksSinceNewDiscovery -= 1 * 60; // take off one turn the third time (pretty much breaking even here)
					case 4: map.ticksSinceNewDiscovery -= 1 * 15; // take off a few ticks the fourth time
					default: // nothing happens by default
				}
			}
			t.visibility = newvis;
		}
	}
	
	
	// THIS IS EXACTLY WHY CODE DUPLICATION IS EVIL: two nearly identical functions with tiny, undocumented differences.
	// this will be rectified momentarily.
	static var adjacent = [[ -1, -1], [0, -1], [1, -1], [ -1, 0], [1, 0], [ -1, 1], [0, 1], [1, 1]];
	public function updateFieldOfView(state:HxlState,?otherActorHighlight:Actor,?skipTween:Bool = false, ?gradientColoring:Bool = true, ?seenTween:Int = 64, ?inSightTween:Int=255) {
		var actor:Actor = null;
		if (otherActorHighlight == null) actor = Registery.player;
		else actor = otherActorHighlight;
		
		var bottom = Std.int(Math.min(heightInTiles - 1, actor.tilePos.y + (actor.visionRadius+1)));
		var top = Std.int(Math.max(0, actor.tilePos.y - (actor.visionRadius+1)));
		var right = Std.int(Math.min(widthInTiles - 1, actor.tilePos.x + (actor.visionRadius+1)));
		var left = Std.int(Math.max(0, actor.tilePos.x - (actor.visionRadius+1)));
		var tile:HxlTile;
		
		// reset previously seen tiles
		for ( x in left...right+1 ) {
			for ( y in top...bottom+1 ) {
				tile = getTile(x, y);
				if ( tile.visibility == Visibility.IN_SIGHT ) {
					tile.visibility = Visibility.SEEN;
				}
			}
		}

		if ( isBlockingView(Std.int(actor.tilePos.x), Std.int(actor.tilePos.y)) ) {
			// if actor is on a view blocking tile, only show adjacent tiles
			for ( i in adjacent) {
				var xx = Std.int(actor.tilePos.x + i[0]);
				var yy = Std.int(actor.tilePos.y + i[1]);
				if (yy < heightInTiles && xx < widthInTiles && yy >= 0 && xx >= 0) {
					cast(getTile(xx, yy), Tile).visibility = Visibility.IN_SIGHT;
				}
			}
		} else {
			var map:Level = this;
			HxlUtil.markFieldOfView(actor.tilePos, actor.visionRadius, this, true, 
				function(p:HxlPoint) { 
					firstSeen(state, map, p, Visibility.IN_SIGHT); 
				} );
			map = null;
		}
		
		var dest = new HxlPoint(0, 0);
		for ( x in left...right+1 ) {
			for ( y in top...bottom+1 ) {
				tile = getTile(x, y);
				
				dest.x = x;
				dest.y = y;
					
				var dist = HxlUtil.distance(actor.tilePos, dest);
				var Ttile:Tile = cast(tile, Tile);
				var normColor:Int = normalizeColor(dist, actor.visionRadius, seenTween, inSightTween);
				var dimness = (actor.visionRadius - dist) / actor.visionRadius;
				switch (tile.visibility) {
					case Visibility.IN_SIGHT:
						tile.visible = true;
						
						for (loot in Ttile.loots)
							cast(loot,HxlSprite).visible = true;
						for (actor in Ttile.actors) {
							cast(actor, HxlSprite).visible = true;
							var hpbar = actor.healthBar;
							if (hpbar != null && actor.hp != actor.maxHp)
								hpbar.visible = true;
								
							if (Std.is(actor, CqMob)) {
								var asmob = cast(actor, CqMob);
								if (asmob != null && asmob.xpValue > 0) {
									// this is a monster and it wasn't spawned to keep you moving,
									// so deduct 60 ticks from the counter for seeing it each turn.
									// in practice, this should mean you won't ever see extra spawns
									// while in the presence of a real monster.  It would be nice to
									// work out some more precise math for this.
									
									ticksSinceNewDiscovery -= 60;
								} else {
									// and if we've spawned a monster to keep you exploring, we don't want to
									// keep spawning them until you kill it. (But if you sit around again you
									// should still get what you've got coming.)
									ticksSinceNewDiscovery -= 25 ;
								}
							}
						}
						Ttile.colorTo(normColor, actor.moveSpeed);
						//Ttile.setColor(HxlUtil.colorInt(normColor, normColor, normColor));
						for (decoration in Ttile.decorations){
							//decoration.setColor(HxlUtil.colorInt(normColor, normColor, normColor));
							decoration.colorTo(normColor, actor.moveSpeed);
						}
					case Visibility.SEEN, Visibility.SENSED:
						tile.visible = true;
						
						for (loot in Ttile.loots)
							cast(loot,HxlSprite).visible = false;
						for (actor in Ttile.actors) {
							cast(actor, HxlSprite).visible = false;
							var pop = cast(actor, HxlSprite).getPopup();
							var hpbar = actor.healthBar;
							if (hpbar != null)
								hpbar.visible = false;
							if (pop != null)
								pop.visible = false;
							pop = null;
							hpbar = null;
						}
						
						Ttile.colorTo(seenTween, actor.moveSpeed);
						//Ttile.setColor(HxlUtil.colorInt(seenTween, seenTween, seenTween));
						for (decoration in Ttile.decorations)
							//decoration.setColor(HxlUtil.colorInt(seenTween, seenTween, seenTween));
							decoration.colorTo(seenTween, actor.moveSpeed);
							
					case Visibility.UNSEEN:
						for (actor in Ttile.actors) {
							var pop = cast(actor, HxlSprite).getPopup();
							var hpbar = actor.healthBar;
							if (hpbar != null)
								hpbar.visible = false;
							if (pop != null)
								pop.visible = false;
							pop = null;
							hpbar = null;
						}
				}
				Ttile = null;
			}
		}
		
		
		actor = null;
		tile = null;
		
	}
	public function updateFieldOfViewByPoint(state:HxlState, tilePos:HxlPoint,visionRadius:Int,tweenSpeed:Int, ?seenTween:Int = 64, ?inSightTween:Int=255):Void 
	{
		var bottom = Std.int(Math.min(heightInTiles - 1, tilePos.y + (visionRadius+1)));
		var top = Std.int(Math.max(0, tilePos.y - (visionRadius+1)));
		var right = Std.int(Math.min(widthInTiles - 1, tilePos.x + (visionRadius+1)));
		var left = Std.int(Math.max(0, tilePos.x - (visionRadius+1)));
		var tile:HxlTile;
		
		// reset previously seen tiles
		for ( x in left...right+1 ) {
			for ( y in top...bottom+1 ) {
				tile = getTile(x, y);
				if ( tile.visibility == Visibility.IN_SIGHT ) {
					tile.visibility = Visibility.SEEN;
				}
			}
		}

		if ( isBlockingView(Std.int(tilePos.x), Std.int(tilePos.y)) ) {
			// if point is on a view blocking tile, only show adjacent tiles
			for ( i in adjacent ) {
				var xx = Std.int(tilePos.x + i[0]);
				var yy = Std.int(tilePos.y + i[1]);
				if (yy < heightInTiles && xx < widthInTiles && yy >= 0 && xx >= 0) {
					cast(getTile(xx, yy), Tile).visibility = Visibility.IN_SIGHT;
				}
			}
		} else {
			var map:Level = this;
			
			HxlUtil.markFieldOfView(tilePos, visionRadius, this, true, 
				function(p:HxlPoint) { 
					firstSeen(state, map, p, Visibility.IN_SIGHT); 
					map = null;
				} );
		}
		
		var dest:HxlPoint = new HxlPoint(0, 0);
		for ( x in left...right+1 ) {
			for ( y in top...bottom+1 ) {
				tile = getTile(x, y);
				dest.x = x;
				dest.y = y;
					
				var dist = HxlUtil.distance(tilePos, dest);
				var Ttile:Tile = cast(tile, Tile);
				var normColor:Int = normalizeColor(dist, visionRadius, seenTween, inSightTween);
				var dimness = (visionRadius-dist) / visionRadius;
				switch (tile.visibility) {
					case Visibility.IN_SIGHT:
						tile.visible = true;
						
						for (loot in Ttile.loots)
							cast(loot,HxlSprite).visible = true;
						for (actor in Ttile.actors) {
							cast(actor, HxlSprite).visible = true;
						}
						Ttile.colorTo(normColor, tweenSpeed);
						//Ttile.setColor(HxlUtil.colorInt(normColor, normColor, normColor));
						for (decoration in Ttile.decorations){
							//decoration.setColor(HxlUtil.colorInt(normColor, normColor, normColor));
							decoration.colorTo(normColor, tweenSpeed);
						}
					case Visibility.SEEN:
						tile.visible = true;
						
						for (loot in Ttile.loots)
							cast(loot,HxlSprite).visible = false;
						for (actor in Ttile.actors)
							cast(actor,HxlSprite).visible = false;
						
						Ttile.colorTo(seenTween, tweenSpeed);
						//Ttile.setColor(HxlUtil.colorInt(seenTween, seenTween, seenTween));
						for (decoration in Ttile.decorations)
							//decoration.setColor(HxlUtil.colorInt(seenTween, seenTween, seenTween));
							decoration.colorTo(seenTween, tweenSpeed);
							
					case Visibility.SENSED:
						tile.visible = true;
						
						for (loot in Ttile.loots)
							cast(loot,HxlSprite).visible = false;
						for (actor in Ttile.actors)
							cast(actor,HxlSprite).visible = false;
						
						Ttile.colorTo(seenTween, tweenSpeed);
						//Ttile.setColor(HxlUtil.colorInt(seenTween, seenTween, seenTween));
						for (decoration in Ttile.decorations)
							//decoration.setColor(HxlUtil.colorInt(seenTween, seenTween, seenTween));
							decoration.colorTo(seenTween, tweenSpeed);
							
							
					case Visibility.UNSEEN:
				}
				Ttile = null;
			}
		}
		tile = null;
	}

	function normalizeColor(dist:Float, maxDist:Float, minColor:Int, maxColor:Int):Int {
		var dimness = (maxDist-dist) / maxDist;
		var color = minColor + (maxColor - minColor)*dimness;
		return Math.round(color);
	}
	
	
	public function getExplorationProgress():Float {
		var explored:Float = 0.0, total:Float = 0.0;
		// return a fraction in [0,1] indicating the % of floor cells uncovered
		for (y in 0...heightInTiles) {
			for (x in 0...widthInTiles) {
				var t:Tile = cast(_tiles[y][x], Tile);
				if (!t.isBlockingMovement()) {
					total += 1.0;
					if (t.timesUncovered > 0) explored += 1.0;
				}
			}
		}
		return explored / total;
	}
	
	/**
	 * checks the directional and wasd keys, returns custompoint+direction of keys pressed
	 * @param	?fromCustomPoint if not null uses this as starting point, otherwise uses players tilePos.
	 * @return starting position + direction, or just starting position if enter is pressed, or null if nothing is pressed
	 */
	public function getTargetAccordingToKeyPress(?fromCustomPoint:HxlPoint = null):HxlPoint {
		var pos:HxlPoint = fromCustomPoint;
		if (pos == null) pos = Registery.player.tilePos;
		
		var facing:HxlPoint = new HxlPoint(0, 0);
		
		for (compass in Configuration.bindings.compasses) {
			if (HxlGraphics.keys.pressed(compass[0])) facing.y = -1;
			if (HxlGraphics.keys.pressed(compass[1])) facing.x = -1;
			if (HxlGraphics.keys.pressed(compass[2])) facing.y = 1;
			if (HxlGraphics.keys.pressed(compass[3])) facing.x = 1;
		}
		
		// now clip the request to the edge of the map (mostly for when this is used in targeting)
		if (facing.y < 0 && pos.y <= 0) facing.y = 0;
		if (facing.y > 0 && pos.y >= heightInTiles) facing.y = 0;
		if (facing.x < 0 && pos.x <= 0) facing.x = 0;
		if (facing.x > 0 && pos.x >= widthInTiles) facing.x = 0;
		
		for (waitkey in Configuration.bindings.waitkeys) {
			if (HxlGraphics.keys.pressed(waitkey)) {
				// we're returning [0, 0]
				return facing;
			}
		}
		
		
		if (facing.x == 0 && facing.y == 0) return null; // looks like no bound keys were pressed
		
		return facing;
	}
	
	
	private inline static function sgn(x:Float):Int {
		return if (x < 0) -1 else if (x > 0) 1 else 0;
	}
	
	public function getTargetAccordingToMousePosition(?secondChoice:Bool = false):HxlPoint {
		// if you don't like grabbing the player from the registry here, change it to an argument
		var player = Registery.player;
		var dx:Float = -.5 + (HxlGraphics.mouse.x - player.x) / Configuration.zoomedTileSize();
		var dy:Float = -.5 + (HxlGraphics.mouse.y - player.y) / Configuration.zoomedTileSize();
		
		var absdx:Float = Math.abs(dx);
		var absdy:Float = Math.abs(dy);
		
		var give:Float = 0.75; // exactly .5 means that you have to point at yourself precisely to wait; higher values make it fuzzier
		if (absdx < give && absdy < give) return new HxlPoint(0, 0);
		
		// here it would be nice to track more info about angle than this
		if ((absdx > absdy && !secondChoice) || (absdx < absdy && secondChoice)) {
			return new HxlPoint(sgn(dx), 0);
		} else {
			return new HxlPoint(0, sgn(dy));
		}
	}
	
	public function tick(state:HxlState) { }
	
	// implement IAStarSearchable (isWalkable, getWidth, getHeight)
	public function isWalkable(x:Int, y:Int):Bool {
		return !isBlockingMovement(x, y, false);
	}
	
	public function getWidth():Int {
		return widthInTiles;
	}
	
	public function getHeight():Int {
		return heightInTiles;
	}
}
