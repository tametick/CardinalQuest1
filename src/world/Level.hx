package world;

import com.eclecticdesignstudio.motion.Actuate;
import cq.CqActor;
import cq.CqItem;
import cq.CqResources;
import data.Registery;
import data.Resources;
import flash.display.Bitmap;
import flash.system.System;
import haxel.GraphicCache;
import haxel.HxlSpriteSheet;

import haxel.HxlPoint;
import haxel.HxlTilemap;
import haxel.HxlState;
import haxel.HxlGraphics;
import haxel.HxlUtil;
import haxel.HxlSprite;
import haxel.HxlRect;

import flash.geom.Point;

import data.Registery;

import playtomic.PtLevel;

import data.Configuration;
import cq.states.WinState;

import com.baseoneonline.haxe.astar.AStar;
import com.baseoneonline.haxe.astar.IAStarSearchable;
import com.baseoneonline.haxe.astar.AStarNode;

import cq.GameUI;
import cq.ui.CqMapDialog;

class Level extends HxlTilemap, implements IAStarSearchable {
	public var mobs:Array<Mob>;
	public var loots:Array<Loot>;
	public var startingLocation:HxlPoint;
	public var index(default, null):Int;
	public var ticksSinceNewDiscovery:Float; // float for convenient arithmetic
	public var stairsAreFound:Bool;

	var aStarNodes:Array<AStarNode>;
	public var aStar(default, null):AStar;
	
	public static inline var CHANCE_DECORATION:Float = 0.2;

	var ptLevel:PtLevel;

	private var fovTileAngleReach:Int;
	private var fovTileAngles:Array<Float>;	
	
	public function new(index:Int,tileW:Int,tileH:Int) {
		super(tileW,tileH);

		this.index = index;
		mobs = new Array();
		loots = new Array();
		startingIndex = 1;
		ptLevel = new PtLevel(this);
		ticksSinceNewDiscovery = 0;
		stairsAreFound = false;
		
		aStarNodes = null;
		aStar = null;
		
		fovTileAngleReach = 11;
		generateFOVTileAngles();		
		
		// give is static and initializing it every time we start on a new level is weird, but doesn't matter.
		// ideally, 5/32" on each side of the center of the player character should be allocated to the wait zone;
		// but we can't go much below one tile (.35 should do the trick) or above about .90 --
		
		#if flashmobile
		give = (5 / 32) / Configuration.inchesPerTile;
		if (give < .35) give = .35;
		if (give > 0.90) give = .90;
		#else
		give = .85; // feels right on the desktop for lazy clicking
		#end
	}

	public function isBlockingMovement(X:Int, Y:Int, ?CheckActor:Bool=false):Bool {
		if ( X < 0 || Y < 0 || X >= widthInTiles || Y >= heightInTiles )
			return true;
		if ( CheckActor && cast(_tiles[Y][X], Tile).actors.length>0 )
			return true;
		return _tiles[Y][X].blocksMovement;
	}

	public function isBlockingView(X:Int, Y:Int):Bool {
		if ( X < 0 || Y < 0 || X >= widthInTiles || Y >= heightInTiles )
			return true;
		return _tiles[Y][X].blocksView;
	}

	public override function onAdd(state:HxlState) {
		super.onAdd(state);

		addAllActors(state);
		addAllLoots(state);
		ptLevel.start();
		
		var frame:HxlRect = GameUI.getMapFrame();
		HxlGraphics.followCenter = new Point(Math.floor(frame.left + frame.right) >> 1, Math.floor(frame.top + frame.bottom) >> 1);	
		
		HxlGraphics.follow(Registery.player, Configuration.mobile ? 15 : 10);		
	
	}

	override public function destroy() {
		removeAllActors(HxlGraphics.state);
		removeAllLoots(HxlGraphics.state);
		removeAllDecorations(HxlGraphics.state);
		ptLevel.destroy();

		ptLevel = null;
		startingLocation = null;
		
		while (aStarNodes.length > 0) {
			aStarNodes.pop();
		}
		aStarNodes = null;

		HxlGraphics.unfollow();
		HxlGraphics.followCenter = null;

		Actuate.reset();

		while (fovTileAngles.length > 0) {
			fovTileAngles.pop();
		}
		fovTileAngles = null;

		super.destroy();
	}

	public override function onRemove(state:HxlState) {
		super.onRemove(state);
	}

	public function addMobToLevel(state:HxlState, mob:Mob) {
		mobs.push(mob);
		var tile = getTile(mob.getTilePos().x, mob.getTilePos().y);
		tile.actors.push(mob);
		addObject(state, mob);
	}

	public function removeMobFromLevel(state:HxlState, mob:Mob) {
		if (mob == null) return; // safety against timing issues

		// take the monster out of the global list of monsters
		mobs.remove(mob);

		// take the monster out of the tile it was in
		var mobPos = mob.getTilePos();

		if (mobPos!=null) {
			var mobTile = null;
			mobTile = getTile(mobPos.x, mobPos.y);

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
		var tile = getTile(loot.getTilePos().x, loot.getTilePos().y);
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
		var lootTile = getTile(lootPos.x, lootPos.y);
		lootTile.loots.remove(loot);

		state.remove(loot);

		lootPos = null;
		lootTile  = null;
	}
	

	override public function loadMap(MapFrame:HxlRect, MapData:Array<Array<Int>>, TileGraphic:Class<Bitmap>, Decorations:Class<Bitmap>, ?TileWidth:Int = 0, ?TileHeight:Int = 0, ?ScaleX:Float=1.0, ?ScaleY:Float=1.0):HxlTilemap {
		var map = super.loadMap(MapFrame, MapData, TileGraphic, Decorations, TileWidth, TileHeight, ScaleX, ScaleY);

		for (y in 0...map.heightInTiles) {
			for (x in 0...map.widthInTiles) {
				cast(_tiles[y][x], Tile).level = this;
				_tiles[y][x].color = 0x000000;
			}
		}

		if ( aStarNodes != null ) {
			while ( aStarNodes.length > 0 ) {
				aStarNodes.pop();
			}
		} else {
			aStarNodes = new Array<AStarNode>();
		}
		
		for ( i in 0 ... map.widthInTiles * map.heightInTiles ) {
			var x:Int = i % map.widthInTiles;
			var y:Int = Std.int( i / map.widthInTiles );
			aStarNodes.push( new AStarNode( x, y, this.isWalkable( x, y ) ) );
		}
		
		aStar = new AStar( this );
		
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
				t.decorationIndices = new Array<Int>();
			}
		}
	}

	inline function isBlockedFromAllSides(x:Int,y:Int):Bool {
		var blocked = (x == 0 || getTile(x - 1, y).blocksMovement);
		blocked = blocked && (x == widthInTiles - 1 || getTile(x + 1, y).blocksMovement);
		blocked = blocked && (y == heightInTiles - 1 || getTile(x, y + 1).blocksMovement);
		blocked = blocked && (y == 0 || getTile(x, y - 1).blocksMovement);

		blocked = blocked && ((x==0 || y==0)  ||  getTile(x - 1, y-1).blocksMovement);
		blocked = blocked && ((x==widthInTiles-1 || y==heightInTiles-1)  ||  getTile(x + 1, y+1).blocksMovement);
		blocked = blocked && ((x==0 || y==heightInTiles-1) ||  getTile(x-1, y + 1).blocksMovement);
		blocked = blocked && ((x==widthInTiles-1 || y==0)  ||  getTile(x+1, y - 1).blocksMovement);

		return blocked;
	}

	public function hideAll(state:HxlState) {
		// Reset previously seen tiles.
		var tile:Tile;		
		for ( x in 0...widthInTiles-1 ) {
			for ( y in 0...heightInTiles - 1) {
				tile = getTile(x, y);
				if ( tile.visibility == Visibility.IN_SIGHT ) {
					tile.visibility = Visibility.SEEN;
					tile.visAmount = 0.0;
					
					tile.setColor(0xff404040);
				}
			}
		}		

		// Hide all mobs and loot..
		for ( m in mobs ) {
			cast(m, CqActor).setVisible( false );
			var pop = cast(m, HxlSprite).getPopup();
			if (pop != null)
				pop.visible = false;
			pop = null;
		}
		
		for (loot in loots) {
			cast(loot, HxlSprite).visible = false;
		}		
	}
	
	public function showAll(state:HxlState) {
		var p:HxlPoint = new HxlPoint(0, 0);
		for ( x in 0...widthInTiles-1 ) {
			for ( y in 0...heightInTiles - 1) {
				if(!isBlockedFromAllSides(x,y)){
					var tile = cast(getTile(x, y), Tile);
					p.x = x;
					p.y = y;

					firstSeen(state, this, p, Visibility.SENSED);
					tile.visible = true;
					tile.color = 0xffffff;

					for (loot in tile.loots)
						cast(loot,HxlSprite).visible = true;
					for (actor in tile.actors)
						cast(actor,CqActor).setVisible( true );
				}
			}
		}

		updateFieldOfView(state, Registery.player);
	}

	public function foundStairs(magically:Bool) {
		stairsAreFound = true;
	}

	/** gets called for each tile EVERY time it is seen (not just the first time) **/
	static function firstSeen(state:HxlState, map:Level, p:HxlPoint, newvis:Visibility, visAmount:Float=1.0) {
		if (map == null || p == null)
			return;

		var t:Tile = map.getTile(Math.floor(p.x), Math.floor(p.y));
		if (t == null)
			return;

		if (t.visibility == Visibility.UNSEEN) {
			if (Math.random() < CHANCE_DECORATION) {
				map.addDecoration(t, state);
			}

			if (newvis == Visibility.SENSED) {
				t.visibility = Visibility.SENSED;
			}

			if (t.isStairs) {
				map.foundStairs(newvis == Visibility.SENSED);
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
			t.visAmount = Math.min( 1.0, t.visAmount + visAmount );
		}
	}

	private function generateFOVTileAngles() {
		var centre:Int = fovTileAngleReach;
		var width:Int = fovTileAngleReach * 2 + 1;
		
		fovTileAngles = new Array();
		
		for ( y in 0 ... width ) {
			for ( x in 0 ... width ) {
				var minTileAngle:Float = 0;
				var maxTileAngle:Float = 0;
				
				var distance:Float = Math.sqrt( Math.pow(x - centre, 2) + Math.pow(y - centre, 2) );
				
				// Check the max. and min. angles of the tiles observed.
				if ( x < centre ) {
					if ( y < centre ) {
						minTileAngle = Math.atan2( x + 0.5 - centre, y - 0.5 - centre );
						maxTileAngle = Math.atan2( x - 0.5 - centre, y + 0.5 - centre );
					} else if ( y > centre ) {
						minTileAngle = Math.atan2( x - 0.5 - centre, y - 0.5 - centre );
						maxTileAngle = Math.atan2( x + 0.5 - centre, y + 0.5 - centre );
					} else {
						minTileAngle = Math.atan2( x + 0.5 - centre, y - 0.5 - centre );
						maxTileAngle = Math.atan2( x + 0.5 - centre, y + 0.5 - centre );
					}
				} else if ( x > centre ) {
					if ( y < centre ) {
						minTileAngle = Math.atan2( x + 0.5 - centre, y + 0.5 - centre );
						maxTileAngle = Math.atan2( x - 0.5 - centre, y - 0.5 - centre );
					} else if ( y > centre ) {
						minTileAngle = Math.atan2( x - 0.5 - centre, y + 0.5 - centre );
						maxTileAngle = Math.atan2( x + 0.5 - centre, y - 0.5 - centre );
					} else {
						minTileAngle = Math.atan2( x - 0.5 - centre, y + 0.5 - centre );
						maxTileAngle = Math.atan2( x - 0.5 - centre, y - 0.5 - centre );
					}
				} else {
					if ( y < centre ) {
						minTileAngle = Math.atan2( x + 0.5 - centre, y + 0.5 - centre );
						maxTileAngle = Math.atan2( x - 0.5 - centre, y + 0.5 - centre ) + 2 * Math.PI;
					} else {
						minTileAngle = Math.atan2( x - 0.5 - centre, y - 0.5 - centre );
						maxTileAngle = Math.atan2( x + 0.5 - centre, y - 0.5 - centre );
					}
				}
				
				fovTileAngles.push( minTileAngle );
				fovTileAngles.push( maxTileAngle );
				fovTileAngles.push( distance );
			}
		}
	}
	
	// Brand spanky new field-of-view test.
	private function updateFieldOfViewAtRange( _state:HxlState, _centreX:Int, _centreY:Int, _range:Int, _maxRange:Float, _radMin:Float, _radMax:Float ) {
		var hxlPoint:HxlPoint = new HxlPoint(0, 0);
		var testX:Int = _centreX;
		var testY:Int = _centreY - _range;
		var testXDir:Int = -1;
		var testYDir:Int = 0;
		var firstTile:Bool = true;
		var prevWasBlocking:Bool = true;
		var subRadMin:Float = _radMin;

		if ( _range > _maxRange ) {
			return;
		}

		if ( _radMin > 0.5 * Math.PI ) {
			testX = _centreX + _range;
			testY = _centreY + 1;
			testXDir = 0;
			testYDir = -1;
			firstTile = false;
		} else if ( _radMin > 0 ) {
			testX = _centreX - 1;
			testY = _centreY + _range;
			testXDir = 1;
			testYDir = 0;
			firstTile = false;
		} else if ( _radMin > -0.5 * Math.PI ) {
			testX = _centreX - _range;
			testY = _centreY - 1;
			testXDir = 0;
			testYDir = 1;
			firstTile = false;
		}
		
		// Loop round all tiles at this distance, finding those in our range.
		while (true) {
			var offsetX:Int = testX - _centreX;
			var offsetY:Int = testY - _centreY;
			var arrayOffset:Int = ((offsetY + fovTileAngleReach) * (2 * fovTileAngleReach + 1) + (offsetX + fovTileAngleReach)) * 3;
			
			var minTileAngle:Float = fovTileAngles[arrayOffset];
			var maxTileAngle:Float = fovTileAngles[arrayOffset+1];
			var distance:Float = fovTileAngles[arrayOffset+2];

			if ( firstTile && offsetX == 0 && offsetY < 0 ) {
				minTileAngle -= 2 * Math.PI;
				maxTileAngle -= 2 * Math.PI;
			}			
		
			// Is this tile inside the range?
			if ( maxTileAngle > _radMin && minTileAngle < _radMax ) {
				var blocking:Bool = isBlockingView(testX, testY);
				var visibleFraction:Float = (Math.min( maxTileAngle, _radMax ) - Math.max( minTileAngle, _radMin )) / (maxTileAngle - minTileAngle);
				
				if ( blocking ) {
					// Blocking tiles are always visible if we can see any of them.
					hxlPoint.x = testX;
					hxlPoint.y = testY;

					if ( distance < _maxRange + 0.2 ) {
						firstSeen(_state, this, hxlPoint, Visibility.IN_SIGHT, 0.5 + visibleFraction);
					}
					
					// If the previous *wasn't* blocking, scan deeper on the range prior to this tile.
					if ( !prevWasBlocking ) {
						updateFieldOfViewAtRange( _state, _centreX, _centreY, _range + 1, _maxRange, subRadMin, minTileAngle );
					}
					
					prevWasBlocking = true;
					
					// Update the min. range to after this tile.
					subRadMin = maxTileAngle;
				} else {
					hxlPoint.x = testX;
					hxlPoint.y = testY;

					if ( distance < _maxRange + 0.2 ) {
						firstSeen(_state, this, hxlPoint, Visibility.IN_SIGHT, 0.3 + 0.7 * visibleFraction);
					}
					
					prevWasBlocking = false;
				}
			}
			
			if ( maxTileAngle > _radMax ) { // Once we pass our max, we're done.
				break;
			}
			
			// Continue looping round.
			testX += testXDir;
			testY += testYDir;
			
			if ( Math.abs(testX-_centreX) == Math.abs(testY-_centreY) ) {
				var t:Int = testXDir;
				testXDir = testYDir;
				testYDir = -t;
			}
			
			firstTile = false;
		}
		
		// We ended on an open range. Scan it.
		if ( !prevWasBlocking ) {
			updateFieldOfViewAtRange( _state, _centreX, _centreY, _range + 1, _maxRange, subRadMin, _radMax );
		}
	}
	
	public function updateFieldOfView(state:HxlState, ?otherActorHighlight:Actor, ?skipTween:Bool = false, ?gradientColoring:Bool = true, ?seenTween:Int = 64, ?inSightTween:Int = 255) {
		var actor:Actor = if ( otherActorHighlight != null ) otherActorHighlight else Registery.player;

		// Bounds. Only update tiles in this region.
		var top = Std.int(Math.max(0, actor.tilePos.y - (actor.visionRadius+1)));
		var bottom = Std.int(Math.min(heightInTiles, actor.tilePos.y + (actor.visionRadius+1) + 1));
		var left = Std.int(Math.max(0, actor.tilePos.x - (actor.visionRadius+1)));
		var right = Std.int(Math.min(widthInTiles, actor.tilePos.x + (actor.visionRadius+1) + 1));

		// First, reset previously seen tiles.
		var tile:Tile;		
		for ( x in left...right ) {
			for ( y in top...bottom ) {
				tile = getTile(x, y);
				if ( tile.visibility == Visibility.IN_SIGHT ) {
					tile.visibility = Visibility.SEEN;
					tile.visAmount = 0.0;
				}
			}
		}
		
		// Hide all mobs and loot..
		for ( m in mobs ) {
			cast(m, CqActor).setVisible( false );
			var pop = cast(m, HxlSprite).getPopup();
			if (pop != null)
				pop.visible = false;
			pop = null;
		}
		
		for (loot in loots) {
			cast(loot, HxlSprite).visible = false;
		}
		
		// Set the tile we're on to visible.
		var x:Int = Std.int( actor.tilePos.x );
		var y:Int = Std.int( actor.tilePos.y );
		firstSeen(state, this, new HxlPoint( x, y ), Visibility.IN_SIGHT, 1.0);
		
		// Now recurse outwards, scanning visible-angle ranges.
		updateFieldOfViewAtRange( state, x, y, 1, Std.int(actor.visionRadius), -Math.PI, Math.PI );
		
		// Update tile and item attributes based on visibility.
		var dest = new HxlPoint(0, 0);
		for ( x in left...right ) {
			for ( y in top...bottom ) {
				tile = getTile(x, y);

				dest.x = x;
				dest.y = y;

				var dist = HxlUtil.distance(actor.tilePos, dest);
				switch (tile.visibility) {
					case Visibility.IN_SIGHT:
						tile.visible = true;
						
						// Light tile.
						var lightColor:Int = Std.int( seenTween + (inSightTween - seenTween) * tile.visAmount );
						var normColor:Int = normalizeColor(dist, actor.visionRadius, seenTween, lightColor);
						
						tile.colorTo(normColor, actor.moveSpeed);
						//Ttile.setColor(HxlUtil.colorInt(normColor, normColor, normColor));
						
						// Set loot and mobs visible.
						for (loot in tile.loots)
							cast(loot,HxlSprite).visible = true;
						for (actor in tile.actors) {
							cast(actor, CqActor).setVisible( true );

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
					case Visibility.SEEN, Visibility.SENSED:
						tile.visible = true;

						// Darken tile.
						tile.colorTo(seenTween, actor.moveSpeed);
						//Ttile.setColor(HxlUtil.colorInt(seenTween, seenTween, seenTween));

					case Visibility.UNSEEN:
						// Nothing to do :D
				}
				tile = null;
			}
		}
	}

	static var adjacent = [[ -1, -1], [0, -1], [1, -1], [ -1, 0], [1, 0], [ -1, 1], [0, 1], [1, 1]];

	// This now bears almost no resemblance to the proper field of view calcs above, but it'll do.
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
							cast(actor, CqActor).setVisible( true );
						}
						Ttile.colorTo(normColor, tweenSpeed);
						//Ttile.setColor(HxlUtil.colorInt(normColor, normColor, normColor));
					case Visibility.SEEN:
						tile.visible = true;

						for (loot in Ttile.loots)
							cast(loot,HxlSprite).visible = false;
						for (actor in Ttile.actors)
							cast(actor, CqActor).setVisible( false );

						Ttile.colorTo(seenTween, tweenSpeed);
						//Ttile.setColor(HxlUtil.colorInt(seenTween, seenTween, seenTween));

					case Visibility.SENSED:
						tile.visible = true;

						for (loot in Ttile.loots)
							cast(loot,HxlSprite).visible = false;
						for (actor in Ttile.actors)
							cast(actor, CqActor).setVisible( false );

						Ttile.colorTo(seenTween, tweenSpeed);
						//Ttile.setColor(HxlUtil.colorInt(seenTween, seenTween, seenTween));

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
				if (!t.blocksMovement) {
					total += 1.0;
					if (t.timesUncovered > 0) explored += 1.0;
				}
			}
		}
		return explored / total;
	}

	public function restartExploration(minTimesSeen:Int) {
		ticksSinceNewDiscovery = 0;

		for (y in 0...heightInTiles) {
			for (x in 0...widthInTiles) {
				var t:Tile = cast(_tiles[y][x], Tile);
				if (t.timesUncovered > minTimesSeen) t.timesUncovered = minTimesSeen;
			}
		}
	}

	/**
	 * checks the directional and wasd keys, returns custompoint+direction of keys pressed
	 * @param	?fromCustomPoint if not null uses this as starting point, otherwise uses players tilePos.
	 * @return starting position + direction, or just starting position if enter is pressed, or null if nothing is pressed
	 */
	public function getFacingAccordingToKeyPress(?fromCustomPoint:HxlPoint = null):HxlPoint {
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

	/**
	 * checks the directional and wasd keys and tab, returns custompoint+direction of keys pressed
	 * @param	?fromCustomPoint if not null uses this as starting point, otherwise uses players tilePos.
	 * @return starting position + direction, or just starting position if enter is pressed, or null if nothing is pressed
	 */
	public function getCursorTargetAccordingToKeyPress(?fromCustomPoint:HxlPoint = null):HxlPoint {
		var pos:HxlPoint = fromCustomPoint;
		if (pos == null) pos = Registery.player.tilePos;
	
		for (nextkey in Configuration.bindings.nexttarget) {
			if (HxlGraphics.keys.pressed(nextkey)) {
				var nextTargetMob = Registery.player.getClosestEnemy(pos, true);

				// If there are no mobs visible, do nothing.
				// If there's one mob visible, move to it or do nothing.
				// If there's more than one visible and we can't find a more distant mob than the current, cycle back to the nearest.
				if (nextTargetMob == null) {
					var firstTargetMob = Registery.player.getClosestEnemy(null, true);
					if (firstTargetMob == null || firstTargetMob.tilePos.intEquals(pos)) {
						return null;
					} else {
						nextTargetMob = firstTargetMob;
					}
				}
				
				return new HxlPoint(nextTargetMob.tilePos.x - pos.x, nextTargetMob.tilePos.y  - pos.y);
			}
		}
		
		return getFacingAccordingToKeyPress(fromCustomPoint);
	}
	
	private inline static function sgn(x:Float):Int {
		return if (x < 0) -1 else if (x > 0) 1 else 0;
	}


	// the slope determines how close to horizontal/vertical you have to get before the game treats it as perfectly
	// vertical or perfectly horizontal
	static inline var slope = Math.tan(Math.PI * 12.5 / 180); // 12.5 degrees
	
	// the value of give defines how close to the center of your character you have to click to stand still:
	// exactly .5 means that you have to point at yourself precisely; higher values make it fuzzier.
	static var give:Float = 0.85; // .85 is great on a small screen, .45 or less is better on an iPad -- oy, vey
	
	public function getFacingAccordingToMousePosition(?FourWayTargeting:Bool = false):HxlPoint {
		// if you don't like grabbing the player from the registry here, change it to an argument
		var player = Registery.player;
		
		var dx:Float = -.5 + (HxlGraphics.mouse.x - player.x) / Configuration.zoomedTileSize();
		var dy:Float = -.5 + (HxlGraphics.mouse.y - player.y) / Configuration.zoomedTileSize();

		var absdx:Float = Math.abs(dx);
		var absdy:Float = Math.abs(dy);

		if (absdx < give && absdy < give) {
			return new HxlPoint(0, 0);
		}

		if (absdx > absdy) {
			if (FourWayTargeting || slope * (absdx - give) > (absdy - give)) {
				return new HxlPoint(sgn(dx), 0);
			} else {
				return new HxlPoint(sgn(dx), .5 * sgn(dy));
			}
		} else {
			if (FourWayTargeting || slope * (absdy - give) > (absdx - give)) {
				return return new HxlPoint(0, sgn(dy));
			} else {
				return new HxlPoint(.5 * sgn(dx), sgn(dy));
			}
		}
	}

	public function ticks(state:HxlState, player:CqActor) { }

	// implement IAStarSearchable (isWalkable, getWidth, getHeight)
	public function getAStarNodes():Array<AStarNode> {
		return aStarNodes;
	}
	
	public function updateWalkable(x:Int, y:Int) {
		aStarNodes[y * getWidth() + x].walkable = !isBlockingMovement(x, y, false);
		aStarNodes[y * getWidth() + x].cost = 1;
	}
	
	private function isWalkable(x:Int, y:Int):Bool {
		return !isBlockingMovement(x, y, false);
	}

	public function getWidth():Int {
		return widthInTiles;
	}

	public function getHeight():Int {
		return heightInTiles;
	}
}
