package cq.ui;

import cq.CqActor;
import cq.CqResources;
import cq.CqWorld;
import world.Tile;
import data.Registery;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.geom.Rectangle;
import haxel.HxlDialog;
import haxel.HxlPoint;
import haxel.HxlSlidingDialog;
import haxel.HxlSprite;
import haxel.HxlTilemap;
import haxel.HxlUtil;

class CqMapDialog extends HxlSlidingDialog {

	var mapDialog:HxlDialog;
	var mapSprite:HxlSprite;
	var mapShape:Shape;
	var mapBitmap:Bitmap;
	var mapSize:HxlPoint;
	var cellSize:HxlPoint;

	var clearRect:Rectangle;
	
	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?Direction:Int=0) {
		// Size: 472 x 480
		// map size: 400x400
		// map pos: 36, 40
		super(X, Y, Width, Height, Direction,false);

		mapDialog = new HxlDialog(36, 40, 400, 400);
		mapDialog.setBackgroundColor(0, 15.0);
		mapDialog.setBackgroundAlpha(0);
		add(mapDialog);
		
		// map draw area size: 380x380
		// map draw area offset: 20x20
		// map draw area pos: 20x20
		mapSize = new HxlPoint(380, 380);
		clearRect = new Rectangle(0, 0, 380, 380);

		mapSprite = new HxlSprite(20, 20);
		mapDialog.add(mapSprite);

		mapShape = new Shape();
		mapBitmap = new Bitmap(new BitmapData(Std.int(mapSize.x), Std.int(mapSize.y), true, 0x0));
		mapSprite.pixels = mapBitmap.bitmapData;

		init();
		updateDialog();
	}

	function init() {
		cellSize = new HxlPoint();
		cellSize.x = Math.floor(mapSize.x / Registery.level.widthInTiles);
		cellSize.y = Math.floor(mapSize.y / Registery.level.heightInTiles);
	}

	public override function show(?ShowCallback:Dynamic=null) {
		super.show(ShowCallback);
		updateDialog();
	}

	override public function destroy() {
		super.destroy();
		mapBitmap.bitmapData.dispose();
		mapBitmap.bitmapData = null;
		mapBitmap = null;
	}
	
	public override function updateDialog() {
		var tiles = Registery.level.getTiles();
		var mapW:Int = Registery.level.widthInTiles;
		var mapH:Int = Registery.level.heightInTiles;
		var graph = mapShape.graphics;
		var Color:Int;
		var Alpha = 0.7;
		var SightColor:Int = 0x222222;
		var SeenColor:Int = 0x111111;
		var WallSightColor:Int = 0x333399;
		var WallSeenColor:Int = 0x111166;
		var StairsColor:Int = 0xffffff;
		var DoorSightColor:Int = 0x8E6B5D;
		var DoorSeenColor:Int = 0x563A2F;
		var playerColor:Int = 0xFFFED2;
		var mobColor:Int = 0xFF3333;
		var lootColor:Int = 0xFFCC00;

		var player = Registery.player;
		var playerPos = player.getTilePos();

		graph.clear();
		for ( Y in 0...mapH ) {
			for ( X in 0...mapW ) {
				Color = -1;
				
				if ( tiles[Y][X].visibility == Visibility.SEEN ) {
								Color = SeenColor;
					if ( Registery.level.isBlockingMovement(X, Y) ) {
						Color = WallSeenColor;
					}
				} else if ( tiles[Y][X].visibility == Visibility.IN_SIGHT ) {
					Color = SightColor;
					if ( Registery.level.isBlockingMovement(X, Y) ) {
						Color = WallSightColor;
					}
				}
				if ( Color != -1 ) {
					graph.beginFill(Color,Alpha);
					graph.drawRect( (X * cellSize.x), (Y * cellSize.y), cellSize.x, cellSize.y );
					graph.endFill();
					if ( HxlUtil.contains(SpriteTiles.stairsDown.iterator(), tiles[Y][X].dataNum) ) {
						// Draw stairs
						var dx:Float = X * cellSize.x + 2;
						var dy:Float = Y * cellSize.y + 2;
						graph.moveTo(dx, dy);
						graph.beginFill(StairsColor,Alpha);
						graph.lineTo(dx + (cellSize.x - 4), dy);
						graph.lineTo(dx + ((cellSize.x - 4) / 2), dy + (cellSize.y - 4));
						graph.lineTo(dx, dy);
						graph.endFill();
					} else if ( HxlUtil.contains(SpriteTiles.doors.iterator(), tiles[Y][X].dataNum) ) { 
						// Draw doors
						if ( !HxlUtil.contains(SpriteTiles.openDoors.iterator(), tiles[Y][X].dataNum) ) {
							// Dont draw open doors
							if ( tiles[Y][X].visibility == Visibility.SEEN ) 
								Color = DoorSeenColor;
							else 
								Color = DoorSightColor;
							graph.beginFill(Color,Alpha);
							graph.drawRect( (X * cellSize.x), (Y * cellSize.y), cellSize.x, cellSize.y );
							graph.endFill();			
						}
					} else if ( cast(tiles[Y][X],Tile).loots.length >0)  { 
						// Draw loot
						graph.beginFill(lootColor,Alpha);
						graph.drawRect( (X * cellSize.x+1), (Y * cellSize.y+1), cellSize.x-2, cellSize.y-2 );
						graph.endFill();			
					}
					
					
					// Render player position
					var playerPos = Registery.player.getTilePos();
					if ( playerPos.x == X && playerPos.y == Y ) {
						var dx:Float = (X * cellSize.x) + (cellSize.x / 2);
						var dy:Float = (Y * cellSize.y) + (cellSize.y / 2);
						graph.beginFill(playerColor,Alpha);
						graph.drawCircle(dx, dy, (cellSize.x / 2) - 1);
						graph.endFill();
					} else if ( tiles[Y][X].visibility == Visibility.IN_SIGHT ) {
						// Render Mobs
						var tile = cast(tiles[Y][X], CqTile);
						if ( tile.actors.length > 0 ) {
							var other = cast(tile.actors[tile.actors.length-1], CqActor);
							if ( other.faction != player.faction ) {
								var dx:Float = (X * cellSize.x) + (cellSize.x / 2);
								var dy:Float = (Y * cellSize.y) + (cellSize.y / 2);
								graph.beginFill(mobColor,Alpha);
								graph.drawCircle(dx, dy, (cellSize.x / 2) - 1);
								graph.endFill();
							}
						}
					}
				}
			}
		}

		mapBitmap.bitmapData.fillRect(clearRect, 0x0);
		mapBitmap.bitmapData.draw(mapShape);
		mapSprite.pixels = mapBitmap.bitmapData;
	}

}
