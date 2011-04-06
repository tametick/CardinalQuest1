package world;

import haxel.HxlPoint;
import haxel.HxlState;

interface Player implements Actor {
	public function act(state:HxlState, targetTile:HxlPoint):Void;
}