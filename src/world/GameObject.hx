package world;

import haxel.HxlSprite;
import haxel.HxlPoint;


interface GameObject {
	var world:World;
	var hp:Int;
	var maxHp:Int;
	
	var tilePos(getTilePos, setTilePos) : HxlPoint;
	function getTilePos():HxlPoint;
	function setTilePos(TilePos:HxlPoint):HxlPoint
}

class GameObjectImpl extends HxlSprite
{
	var _tilePos:HxlPoint;
	
	public function new(world:AbstractWorld, x:Float, y:Float, ?hp:Int=1) 
	{
		super(x, y);
		world = world;
		_tilePos = new HxlPoint();
		hp = hp;
		maxHp = hp;
		zIndex = 1;
	}

	public function getTilePos():HxlPoint {
		return _tilePos;
	}
	
	public function setTilePos(TilePos:HxlPoint):HxlPoint {
		// todo - multiple actors & loots
		
		// remove from old tile
		if (_tilePos != null) {
			var tile = world.currentLevel.getTile(_tilePos.x, _tilePos.y);
			if(tile!=null)
				tile.actor = null;
		}
		
		// add to new tile
		_tilePos = TilePos;
		world.currentLevel.getTile(_tilePos.x, _tilePos.y).actor = this;
		return TilePos;
	}
}