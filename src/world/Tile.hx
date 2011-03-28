package world;
import haxel.HxlTilemap;

import flash.geom.Rectangle;

class Tile extends HxlTile
{
	public var actors:Array<Actor>;
	public var loots:Array<Loot>;
	public var level:Level;
	
	public function new(?X:Int = 0, ?Y:Int = 0, ?Rect:Rectangle = null) {
		super(X, Y, Rect);
		
		actors = new Array<Actor>();
		loots = new Array<Loot>();
	}
}