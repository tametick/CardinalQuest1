package cq.ui;

import cq.CqActor;
import cq.CqLevel;
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
import haxel.HxlGraphics;
import data.Configuration;
class CqMapDialogBMPData extends BitmapData {}

class CqMapDialog extends HxlSlidingDialog {
	public var playerX(getPlayerX, null):Float;
	public var playerY(getPlayerY, null):Float;
	public var cellSize(default, null):HxlPoint;

	var px:Float;
	var py:Float;
	var mapDialog:HxlDialog;
	var mapSprite:HxlSprite;
	var mapShape:Shape;
	var mapBitmap:Bitmap;
	var mapSize:HxlPoint;

	var clearRect:Rectangle;
	
	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?Direction:Int=0) {
		// Size: 472 x 480
		// map size: 400x400
		// map pos: 36, 40
		super(X, Y, Width, Height, Direction,false);

		if (!HxlGraphics.smallScreen) {
			mapDialog = new HxlDialog(36, 40, 400, 400);
			mapDialog.setBackgroundColor(0, 15.0);
			mapDialog.setBackgroundAlpha(0);
			mapSprite = new HxlSprite(20, 20);
			
			// map draw area size: 380x380
			// map draw area offset: 20x20
			// map draw area pos: 20x20
			mapSize = new HxlPoint(380, 380);
			clearRect = new Rectangle(0, 0, 380, 380);
		} else {
			mapDialog = new HxlDialog(0, 0, 338, 283);
			mapDialog.setBackgroundColor(0);
			mapDialog.setBackgroundAlpha(0);
			mapSprite = new HxlSprite((338 - 224) / 2, (283 - 244) / 2);
			
			mapSize = new HxlPoint(224, 224); // at this size, tiles will be 7x7
			clearRect = new Rectangle(0, 0, 224, 224);
			
			var bg:HxlSprite = new HxlSprite(-22, 0, MobileSpriteMapPaper);
			bg.zIndex = -1;
			add(bg);
		}
		add(mapDialog);

		mapDialog.add(mapSprite);

		mapShape = new Shape();
		mapBitmap = new Bitmap(new CqMapDialogBMPData(Std.int(mapSize.x), Std.int(mapSize.y), true, 0x0));
		mapSprite.pixels = mapBitmap.bitmapData;
		
		/*if (HxlGraphics.smallScreen) {
			mapSprite.scale.x = .5;
			mapSprite.scale.y = .5;
			mapSprite.x -= .5 * (1.0 - mapSprite.scale.x) * mapSprite.width;
			mapSprite.y -= .5 * (1.0 - mapSprite.scale.y) * mapSprite.height;
		}*/

		px = 0;
		py = 0;
		
		init();
	}

	function init() {
		cellSize = new HxlPoint();
		cellSize.x = Math.floor(mapSize.x / Registery.level.widthInTiles);
		cellSize.y = Math.floor(mapSize.y / Registery.level.heightInTiles);
		
		// make sure cells are an odd number of pixels on each side
		if (cellSize.x % 2 == 0) cellSize.x -= 1.0;
		if (cellSize.y % 2 == 0) cellSize.y -= 1.0;
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
		var Alpha = 0.7;
		
		var schemes = [
			// sight/sensed/seen:
			{
				floor: 0x222222,
				wall: 0x333399,
				door: 0x8E6B5D,
				loot: 0xFFCC00,
				lootcore: 0xFFAA00
			},
			{
				floor: 0x060606,
				wall: 0x151520,
				door: 0x302520,
				loot: 0xEEBB00,
				lootcore: 0xF8A800
			},
			{
				floor: 0x111111,
				wall: 0x111166,
				door: 0x563A2F,
				loot: 0xCC9900,
				lootcore: 0xDD9900,
			}
		];
		
		var colors = {
			stairs: 0xffffff,
			player: 0xFFFED2,
			friend: 0xCFCFA2,
			mob: 0xFF3333
		};
		
		var player = Registery.player;
		var playerPos = player.getTilePos();
		var level:CqLevel = Registery.level;

		graph.clear();
		for ( Y in 0...mapH ) {
			for ( X in 0...mapW ) {
				var visibility:Visibility = tiles[Y][X].visibility;
				
				if (visibility != Visibility.UNSEEN) {
					var Color:Int = -1;
					var scheme_number = if (visibility == Visibility.SEEN) 2 else if (visibility == Visibility.IN_SIGHT) 0 else if (visibility == Visibility.SENSED) 1;
					var scheme = schemes[scheme_number];
					
					if (level.isBlockingMovement(X, Y)) {
						if (tiles[Y][X].isDoor) { 
							Color = scheme.door;
						} else {
							Color = scheme.wall;
						}						
					} else {
						Color = scheme.floor;
					}
					
					graph.beginFill(Color,Alpha);
					graph.drawRect( (X * cellSize.x), (Y * cellSize.y), cellSize.x, cellSize.y );
					graph.endFill();
					
					// render stairs and loot:
					if ( tiles[Y][X].isStairs ) {
						var dx:Float = X * cellSize.x;
						var dy:Float = Y * cellSize.y;
						
						// draw the stairs slightly bigger than the cell (notice that it only overlaps cells
						// above it, so we don't clobber it as we draw cells to the right or south.)
						graph.beginFill(colors.stairs, Alpha);
						graph.moveTo(dx - 1, dy - 2);
						graph.lineTo(dx + 1 + cellSize.x, dy - 2);
						graph.lineTo(dx + cellSize.x / 2, dy + cellSize.y);
						graph.lineTo(dx - 1, dy - 2);
						graph.endFill();
						
						graph.beginFill(colors.stairs, Alpha);
						graph.moveTo(dx + 2, dy);
						graph.lineTo(dx - 2 + cellSize.x, dy);
						graph.lineTo(dx + cellSize.x / 2, dy + cellSize.y - 4);
						graph.lineTo(dx + 2, dy);
						graph.endFill();
					} else if ( cast(tiles[Y][X],Tile).loots.length >0)  {
						graph.beginFill(scheme.loot,Alpha);
						graph.drawRect( (X * cellSize.x + 2), (Y * cellSize.y + 2), cellSize.x - 4, cellSize.y - 4);
						graph.endFill();
						
						// add a redder center to loot to make it tastier:
						graph.beginFill(scheme.loot, 1.0);
						graph.drawRect( (X * cellSize.x + 3), (Y * cellSize.y + 3), cellSize.x - 6, cellSize.y - 6);
						graph.endFill();
					}
					
					// render mobs
					if ( tiles[Y][X].visibility == Visibility.IN_SIGHT ) {
						// Render Mobs
						var tile = cast(tiles[Y][X], CqTile);
						if ( tile.actors.length > 0 ) {
							var other = tile.actors[tile.actors.length - 1];
							if (Std.is(other, CqMob)) {
								var mob = cast(other, CqMob);
							
								var dx:Float = (X * cellSize.x) + (cellSize.x / 2);
								var dy:Float = (Y * cellSize.y) + (cellSize.y / 2);
							
								graph.beginFill(mob.averageColor, 1.0);
								graph.drawCircle(dx, dy, (cellSize.x * .5) - 1);
								graph.endFill();
								
								graph.beginFill(colors.mob, 1.0);
								graph.drawCircle(dx, dy, (cellSize.x * .30) - 1);
								graph.endFill();
							}
						}
					}
				}
			}
		}

		// draw the player
		px = (player.tilePos.x * cellSize.x) + (cellSize.x / 2);
		py = (player.tilePos.y * cellSize.y) + (cellSize.y / 2);
		
		graph.beginFill(colors.friend, Alpha);
		graph.drawCircle(px, py, (cellSize.x * .45) - 1); // make the player a little bigger (.70 instead of .5)
		graph.endFill();
		
		graph.beginFill(colors.player, Alpha);
		graph.drawCircle(px, py, (cellSize.x * .70) - 1); // make the player a little bigger (.70 instead of .5)
		graph.endFill();

		mapBitmap.bitmapData.fillRect(clearRect, 0x0);
		mapBitmap.bitmapData.draw(mapShape);
		mapSprite.pixels = mapBitmap.bitmapData;
	}
	
	
	private function getPlayerX():Float {
		return px + mapSprite.x;
	}
	
	private function getPlayerY():Float {
		return py + mapSprite.y;
	}
}
