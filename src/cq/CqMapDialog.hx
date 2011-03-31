package cq;

import data.Registery;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import haxel.HxlDialog;
import haxel.HxlPoint;
import haxel.HxlSlidingDialog;
import haxel.HxlSprite;
import haxel.HxlTilemap;

class CqMapDialog extends HxlSlidingDialog {

	var mapDialog:HxlDialog;
	var mapSprite:HxlSprite;
	var mapShape:Shape;
	var mapBitmap:Bitmap;
	var mapSize:HxlPoint;
	var cellSize:HxlPoint;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?Direction:Int=0)
	{
		// Size: 472 x 480
		// map size: 400x400
		// map pos: 36, 40
		super(X, Y, Width, Height, Direction);

		mapDialog = new HxlDialog(36, 40, 400, 400);
		mapDialog.setBackgroundColor(0x222222, 15.0);
		add(mapDialog);

		// map draw area size: 380x380
		// map draw area offset: 20x20
		// map draw area pos: 20x20
		mapSize = new HxlPoint(380, 380);

		mapSprite = new HxlSprite(20, 20);
		mapDialog.add(mapSprite);

		mapShape = new Shape();
		mapBitmap = new Bitmap(new BitmapData(Std.int(mapSize.x), Std.int(mapSize.y), true, 0x0));
		mapSprite.pixels = mapBitmap.bitmapData;

		init();
		updateMap();
	}

	function init():Void {
		cellSize = new HxlPoint();
		cellSize.x = Math.floor(mapSize.x / Registery.world.currentLevel.widthInTiles);
		cellSize.y = Math.floor(mapSize.y / Registery.world.currentLevel.heightInTiles);
	}

	public override function show(?ShowCallback:Dynamic=null):Void {
		super.show(ShowCallback);
		updateMap();
	}

	public function updateMap():Void {
		var tiles:Array<Array<HxlTile>> = Registery.world.currentLevel.getTiles();
		var mapW:Int = Registery.world.currentLevel.widthInTiles;
		var mapH:Int = Registery.world.currentLevel.heightInTiles;
		var graph = mapShape.graphics;
		var Color:Int = 0x339933;
		var SightColor:Int = 0x339933;
		var SeenColor:Int = 0x116611;
		var WallSightColor:Int = 0x333399;
		var WallSeenColor:Int = 0x111166;
		graph.clear();
		for ( Y in 0...mapH ) {
			for ( X in 0...mapW ) {
				Color = -1;
				if ( tiles[Y][X].visibility == Visibility.SEEN ) {
					Color = SeenColor;
					if ( Registery.world.currentLevel.isBlockingMovement(X, Y) ) {
						Color = WallSeenColor;
					}
				} else if ( tiles[Y][X].visibility == Visibility.IN_SIGHT ) {
					Color = SightColor;
					if ( Registery.world.currentLevel.isBlockingMovement(X, Y) ) {
						Color = WallSightColor;
					}
				}
				if ( Color != -1 ) {
					graph.beginFill(Color);
					graph.drawRect( (X * cellSize.x), (Y * cellSize.y), cellSize.x, cellSize.y );
					graph.endFill();
				}
			}
		}
		mapBitmap = new Bitmap(new BitmapData(Std.int(mapSize.x), Std.int(mapSize.y), true, 0x0));
		mapBitmap.bitmapData.draw(mapShape);
		mapSprite.pixels = mapBitmap.bitmapData;
	}

}