package cq;

import world.Tile;
import flash.geom.Rectangle;

class CqTile extends Tile {
	public function new(?X:Int = 0, ?Y:Int = 0, ?Rect:Rectangle = null) {
		super(X, Y, Rect);
		visible = false;
	}
}