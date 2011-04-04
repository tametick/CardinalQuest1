package world;

import haxel.HxlObject;
import haxel.HxlSprite;
import haxel.HxlPoint;

import data.Registery;

interface GameObject implements HxlObjectI {
	var hp:Int;
	var maxHp:Int;
	
	var tilePos(getTilePos, setTilePos):HxlPoint;
	function getTilePos():HxlPoint;
	function setTilePos(TilePos:HxlPoint):HxlPoint;
}

class GameObjectImpl extends HxlSprite, implements GameObject
{
	public var hp:Int;
	public var maxHp:Int;	
	public var tilePos(getTilePos, setTilePos):HxlPoint;
	
	var _tilePos:HxlPoint;
	
	public function new(x:Float, y:Float, ?hp:Int=1) 
	{
		super(x, y);
		_tilePos = new HxlPoint();
		this.hp = hp;
		maxHp = hp;
		zIndex = 1;
	}

	public function getTilePos():HxlPoint {
		return _tilePos;
	}
	
	public function setTilePos(TilePos:HxlPoint):HxlPoint {
		// remove from old tile
		if (_tilePos != null) {
			var tile = Registery.world.currentLevel.getTile(_tilePos.x, _tilePos.y);
			if (tile != null)
				if(Std.is(this,Actor))
					tile.actors.remove(this);
				else if (Std.is(this, Loot))
					tile.loots.remove(this);
		}
		
		// add to new tile
		_tilePos = TilePos;

		if(Std.is(this,Actor))
			Registery.world.currentLevel.getTile(_tilePos.x, _tilePos.y).actors.push(this);
		else if (Std.is(this, Loot))
			Registery.world.currentLevel.getTile(_tilePos.x, _tilePos.y).loots.push(this);
		
		return TilePos;
	}
}