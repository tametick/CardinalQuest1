package cq;

import data.Configuration;
import haxel.HxlPoint;
import world.GameObject;

class CqObject extends GameObjectImpl {
	public function new(X:Float, Y) {
		super(X, Y);
		_tilePos = new HxlPoint(X / Configuration.zoomedTileSize(), Y / Configuration.zoomedTileSize());
	}	
}