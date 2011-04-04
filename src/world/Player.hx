package world;

import haxel.HxlPoint;
import haxel.HxlState;

interface Player implements Actor {
	public var isMoving:Bool;
	public function act(state:HxlState, targetTile:HxlPoint):Void;
}