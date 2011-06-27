package world;

import flash.display.Bitmap;
import com.baseoneonline.haxe.astar.PathMap;

import haxel.HxlPoint;
import haxel.HxlTilemap;
import haxel.HxlState;
import haxel.HxlGraphics;
import haxel.HxlUtil;
import haxel.HxlSprite;

import data.Registery;

import playtomic.PtLevel;

import cq.CqConfiguration;
import cq.states.WinState;

class Level extends HxlTilemap
{
	public var mobs:Array<Mob>;
	public var loots:Array<Loot>;
	public var startingLocation:HxlPoint;
	var _pathMap:PathMap;
	public var index(default, null):Int;
	
	
	var ptLevel:PtLevel;
	
	public function new(index:Int) {
		super();
		
		this.index = index;
		mobs = new Array();
		loots = new Array();
		_pathMap = null;
		startingIndex = 1;
		ptLevel = new PtLevel(this);
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
		addAllActors(state);
		addAllLoots(state);
		ptLevel.start();
		//follow();
		HxlGraphics.follow(Registery.player, 10);
	}
	
	public override function onRemove(state:HxlState) {
		removeAllActors(state);
		removeAllLoots(state);
		ptLevel.finish();
	}
	
	public function addMobToLevel(state:HxlState, mob:Mob) {
		mobs.push(mob);
		var tile = cast(getTile(mob.getTilePos().x, mob.getTilePos().y), Tile);
		tile.actors.push(mob);
		addObject(state, mob);
	}
	
	public function removeMobFromLevel(state:HxlState, mob:Mob) {
		mobs.remove(mob);
		
		var mobPos = mob.getTilePos();		
		var mobTile = cast(getTile(mobPos.x, mobPos.y), Tile);
		mobTile.actors.remove(mob);
		
		state.remove(mob);
		if (mobs.length == 0)
		levelComplete();
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
		state.remove(Registery.player);
			
		for (mob in mobs) {
			state.remove(mob);
			cast(mob, GameObject).destroy();
		}
	}
	
	public function removeAllLoots(state:HxlState) {			
		for (loot in loots)
			state.remove(loot);
	}
	
	public function removeLootFromLevel(state:HxlState, loot:Loot) {
		loots.remove(loot);
		
		var lootPos = loot.getTilePos();		
		var lootTile = cast(getTile(lootPos.x, lootPos.y), Tile);
		lootTile.loots.remove(loot);
		
		state.remove(loot);
	}
	
	function levelComplete():Void {
		if (index == CqConfiguration.lastLevel)
			HxlGraphics.pushState(new WinState());
	}
	
	override public function loadMap(MapData:Array<Array<Int>>, TileGraphic:Class<Bitmap>, ?TileWidth:Int = 0, ?TileHeight:Int = 0, ?ScaleX:Float=1.0, ?ScaleY:Float=1.0):HxlTilemap {
		var map = super.loadMap(MapData, TileGraphic, TileWidth, TileHeight, ScaleX, ScaleY);
		
		_pathMap = new PathMap(widthInTiles, heightInTiles);
		
		for (y in 0...map.heightInTiles) {
			for (x in 0...map.widthInTiles) {
				cast(_tiles[y][x], Tile).level = this;
				_tiles[y][x].color = 0x000000;
				if ( isBlockingMovement(x, y) ) 
					_pathMap.setWalkable(x, y, false);
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
	
	
	function tweenToColor(tween:Int):Int {
		var hex = StringTools.hex(tween);
		return Std.parseInt("0x"+hex+hex+hex);
	}
	
	var dest:HxlPoint;
	public function updateFieldOfView(?skipTween:Bool = false, ?gradientColoring:Bool = true, ?seenTween:Int = 64, ?inSightTween:Int=255) {
		var player = Registery.player;
		
		var bottom = Std.int(Math.min(heightInTiles - 1, player.tilePos.y + (player.visionRadius+1)));
		var top = Std.int(Math.max(0, player.tilePos.y - (player.visionRadius+1)));
		var right = Std.int(Math.min(widthInTiles - 1, player.tilePos.x + (player.visionRadius+1)));
		var left = Std.int(Math.max(0, player.tilePos.x - (player.visionRadius+1)));
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

		if ( isBlockingView(Std.int(player.tilePos.x), Std.int(player.tilePos.y)) ) {
			// if player is on a view blocking tile, only show adjacent tiles
			var adjacent = new Array();
			adjacent = [[ -1, -1], [0, -1], [1, -1], [ -1, 0], [1, 0], [ -1, 1], [0, 1], [1, 1]];
			for ( i in adjacent ) {
				var xx = Std.int(player.tilePos.x + i[0]);
				var yy = Std.int(player.tilePos.y + i[1]);
				if(yy<heightInTiles && xx<widthInTiles && yy>=0 && xx>=0)
					cast(getTile(xx, yy), Tile).visibility = Visibility.IN_SIGHT;
			}
		} else {
			HxlUtil.markFieldOfView(player.tilePos, player.visionRadius, this);
		}
		
		for ( x in left...right+1 ) {
			for ( y in top...bottom+1 ) {
				tile = getTile(x, y);
				if (dest == null){
					dest = new HxlPoint(x, y);
				} else {
					dest.x = x;
					dest.y = y;
				}
					
				var dist = HxlUtil.distance(player.tilePos, dest);
				
				switch (tile.visibility) {
					case Visibility.IN_SIGHT:
						tile.visible = true;
						
						for (loot in cast(tile, Tile).loots)
							cast(loot,HxlSprite).visible = true;
						for (actor in cast(tile, Tile).actors)
							cast(actor,HxlSprite).visible = true;
						
						if ( skipTween ) {
							if (gradientColoring) {
								var normTween = normalizeColor(dist, player.visionRadius, seenTween, inSightTween);
								tile.color = tweenToColor(normTween);
							} else {
								var inSightColor = tweenToColor(inSightTween);
								tile.color = inSightColor;
							}
						} else {
							if (gradientColoring)
								cast(tile,Tile).colorTo(normalizeColor(dist, player.visionRadius, seenTween, inSightTween), player.moveSpeed);
							else
								cast(tile,Tile).colorTo(inSightTween, player.moveSpeed);
						}
					case Visibility.SEEN:
						tile.visible = true;
						
						for (loot in cast(tile, Tile).loots)
							cast(loot,HxlSprite).visible = false;
						for (actor in cast(tile, Tile).actors)
							cast(actor,HxlSprite).visible = false;
						
						if ( skipTween ) {
							var seenColor = tweenToColor(seenTween);
							tile.color = seenColor;
						} else {
							cast(tile,Tile).colorTo(seenTween, player.moveSpeed);
						}
					case Visibility.UNSEEN:
				}
			}
		}
	}
	
	function normalizeColor(dist:Float, maxDist:Float, minColor:Int, maxColor:Int):Int {
		var dimness = (maxDist-dist) / maxDist;
		var color = minColor + (maxColor - minColor)*dimness;
		return Math.round(color);
	}
	
	var targetTile:HxlPoint;
	public function getTargetAccordingToKeyPress():HxlPoint {
		var player = Registery.player;
		
		if (targetTile == null)
			targetTile = new HxlPoint(0, 0);
		else{
			targetTile.x = 0;
			targetTile.y = 0;
		}
		if ( HxlGraphics.keys.LEFT ) {
			if ( player.tilePos.x > 0) {
				targetTile.x = -1;
			}
		} else if ( HxlGraphics.keys.RIGHT ) {
			if ( player.tilePos.x < widthInTiles) {
				targetTile.x = 1;
			}
		} else if ( HxlGraphics.keys.UP ) {
			if ( player.tilePos.y > 0 ) {
					targetTile.y = -1;
			}
		} else if ( HxlGraphics.keys.DOWN ) {
			if ( player.tilePos.y < heightInTiles ) {
					targetTile.y = 1;
			}
		} 
		
		if (targetTile.x == 0 && targetTile.y == 0)
			return null;
		return targetTile;
	}
	
	public function getTargetAccordingToMousePosition(dx:Float, dy:Float):HxlPoint {
		if (targetTile == null)
			targetTile = new HxlPoint(0, 0);
		else{
			targetTile.x = 0;
			targetTile.y = 0;
		}
		
		if (Math.abs(dx) > Math.abs(dy)){
			if (dx < 0) {
				targetTile.x = -1;
			} else {
				targetTile.x = 1;
			}
		} else {
			if (dy < 0) {
				targetTile.y = -1;
			} else {
				targetTile.y = 1;
			}
		}
		
		if (targetTile.x == 0 && targetTile.y == 0)
			return null;
		return targetTile;
	}
	
	public function tick(state:HxlState) { }
}
