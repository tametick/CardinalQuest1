package world;

import com.eclecticdesignstudio.motion.Actuate;
import cq.CqActor;
import cq.ui.CqDecoration;
import cq.CqRegistery;
import cq.states.GameState;
import data.Resources;
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
	
	public static inline var CHANCE_DECORATION:Float = 0.2;
	
	var ptLevel:PtLevel;
	
	public function new(index:Int,tileW:Int,tileH:Int) {
		super(tileW,tileH);
		
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
		removeAllDecorations(state);
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
		if (cast(mob, CqActor).healthBar != null) 
			state.remove(cast(mob, CqActor).healthBar);
		
		for (m in mobs) {
			if (cast(m, CqActor).faction != CqRegistery.player.faction) 
				return;
			if (cast(m, CqActor).isCharmed)
				return;
		}
			
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
		if (player.tilePos.x != startingLocation.x || player.tilePos.y  != startingLocation.y)
		{
			trace(player.tilePos.x + " " + startingLocation.x);
			trace(player.tilePos.y + " " + startingLocation.y);
			trace("positions not equal! Is there a chest on player starting pos??");
		}
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
	//public function 
	function levelComplete() {
		if (index == CqConfiguration.lastLevel)
			cast(HxlGraphics.state,GameState).startBossAnim();
			//HxlGraphics.pushState(new WinState());
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
	public function addDecoration(t:Tile,state:HxlState)
	{
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
	public function removeAllDecorations(state:HxlState)
	{
		for (y in 0...heightInTiles) {
			for (x in 0...widthInTiles) {
				var t:Tile = cast(_tiles[y][x], Tile);
				for(dec in t.decorations)
				{
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

					firstSeen(state, this, new HxlPoint(x, y));
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
	}

	/** gets called for each tile first time seen. */
	static function firstSeen(state:HxlState,map:Level,p:HxlPoint) { 
		var t:Tile = map.getTile(Math.round(p.x), Math.round(p.y));
		if (t.visibility == Visibility.UNSEEN && Math.random() < CHANCE_DECORATION)
			map.addDecoration(t, state);
		t.visibility = Visibility.IN_SIGHT ; 
	}
	
	var dest:HxlPoint;
	public function updateFieldOfView(state:HxlState,?otherActorHighlight:Actor,?skipTween:Bool = false, ?gradientColoring:Bool = true, ?seenTween:Int = 64, ?inSightTween:Int=255) {
		var actor:Actor = null;
		if (otherActorHighlight == null)
			actor = Registery.player;
		else
			actor = otherActorHighlight;
		
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
			var adjacent = new Array();
			adjacent = [[ -1, -1], [0, -1], [1, -1], [ -1, 0], [1, 0], [ -1, 1], [0, 1], [1, 1]];
			for ( i in adjacent ) {
				var xx = Std.int(actor.tilePos.x + i[0]);
				var yy = Std.int(actor.tilePos.y + i[1]);
				if (yy < heightInTiles && xx < widthInTiles && yy >= 0 && xx >= 0) {
					cast(getTile(xx, yy), Tile).visibility = Visibility.IN_SIGHT;
				}
			}
		} else {
			var map:Level = this;
			
			HxlUtil.markFieldOfView(actor.tilePos, actor.visionRadius, this, true, function(p:HxlPoint) { firstSeen(state, map, p); } );
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
					
				var dist = HxlUtil.distance(actor.tilePos, dest);
				var Ttile:Tile = cast(tile, Tile);
				var normColor:Int = normalizeColor(dist, actor.visionRadius, seenTween, inSightTween);
				var dimness = (actor.visionRadius-dist) / actor.visionRadius;
				switch (tile.visibility) {
					case Visibility.IN_SIGHT:
						tile.visible = true;
						
						for (loot in Ttile.loots)
							cast(loot,HxlSprite).visible = true;
						for (actor in Ttile.actors)
							cast(actor,HxlSprite).visible = true;
						Ttile.colorTo(normColor, actor.moveSpeed);
						//Ttile.setColor(HxlUtil.colorInt(normColor, normColor, normColor));
						for (decoration in Ttile.decorations)
							//decoration.setColor(HxlUtil.colorInt(normColor, normColor, normColor));
							decoration.colorTo(normColor, actor.moveSpeed);
					case Visibility.SEEN:
						tile.visible = true;
						
						for (loot in Ttile.loots)
							cast(loot,HxlSprite).visible = false;
						for (actor in Ttile.actors)
							cast(actor,HxlSprite).visible = false;
						
						Ttile.colorTo(seenTween, actor.moveSpeed);
						//Ttile.setColor(HxlUtil.colorInt(seenTween, seenTween, seenTween));
						for (decoration in Ttile.decorations)
							//decoration.setColor(HxlUtil.colorInt(seenTween, seenTween, seenTween));
							decoration.colorTo(seenTween, actor.moveSpeed);
							
					case Visibility.UNSEEN:
				}
			}
		}
	}
	function colorTo(target:Dynamic,Speed:Float,ToColor:Float,onComplete:Dynamic) {
		Actuate.update(target, Speed, {Color: HxlUtil.colorRGB(_color)[0]}, {Color: ToColor})
				.onComplete(onComplete);
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
		if ( HxlGraphics.keys.LEFT || HxlGraphics.keys.A) {
			if ( player.tilePos.x > 0) {
				targetTile.x = -1;
			}
		} else if ( HxlGraphics.keys.RIGHT || HxlGraphics.keys.D) {
			if ( player.tilePos.x < widthInTiles) {
				targetTile.x = 1;
			}
		} else if ( HxlGraphics.keys.UP || HxlGraphics.keys.W) {
			if ( player.tilePos.y > 0 ) {
					targetTile.y = -1;
			}
		} else if ( HxlGraphics.keys.DOWN || HxlGraphics.keys.S) {
			if ( player.tilePos.y < heightInTiles ) {
					targetTile.y = 1;
			}
		} else if ( HxlGraphics.keys.ENTER )
		{
			return targetTile;
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
