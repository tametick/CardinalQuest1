package detribus;

import haxel.HxlSprite;
import haxel.HxlPoint;

class GameObject extends HxlSprite
{
	var _world:World;
	
	public var tilePos(getTilePos, setTilePos) : HxlPoint;
	var _tilePos:HxlPoint;

	var _hp:Int;
	var _maxHp:Int;
	
	public function new(world:World, x:Float, y:Float, ?hp:Int=1) 
	{
		super(x, y);
		_world = world;
		_tilePos = new HxlPoint();
		_hp = hp;
		_maxHp = hp;
		zIndex = 1;
	}

	public function getTilePos():HxlPoint {
		return _tilePos;
	}
	
	public function setTilePos(TilePos:HxlPoint):HxlPoint {
		// remove from old tile
		if (_tilePos != null) {
			var tile = _world.currentLevel.getTile(_tilePos.x, _tilePos.y);
			if(tile!=null)
				tile.actor = null;
		}
		
		// add to new tile
		_tilePos = TilePos;
		_world.currentLevel.getTile(_tilePos.x, _tilePos.y).actor = this;
		return TilePos;
	}
}
