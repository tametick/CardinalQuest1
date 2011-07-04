package world;

import haxel.HxlObject;
import haxel.HxlSprite;
import haxel.HxlPoint;
import haxel.HxlGraphics;

import data.Configuration;
import data.Registery;

interface GameObject implements HxlObjectI {
	var hp:Int;
	var maxHp:Int;

	var tilePos(getTilePos, null):HxlPoint;
	function getTilePos():HxlPoint;
	function setTilePos(X:Int, Y:Int):HxlPoint;
	function addOnDestroy(Callback:Dynamic):Void;
	function destroy():Void;
}

class GameObjectImpl extends HxlSprite, implements GameObject
{
	public var hp:Int;
	public var maxHp:Int;
	public var tilePos(getTilePos, null):HxlPoint;
	
	var _tilePos:HxlPoint;
	
	var onDestroy:List<Dynamic>;

	public function new(x:Float, y:Float, ?hp:Int=1) 
	{
		super(x, y);
		var tileX = x / Configuration.zoomedTileSize();
		var tileY = y/Configuration.zoomedTileSize();
		_tilePos = new HxlPoint(tileX, tileY);
		
		this.hp = hp;
		maxHp = hp;
		zIndex = 1;

		onDestroy = new List();
	}

	public function getTilePos():HxlPoint {
		return _tilePos;
	}
	
	public function setTilePos(X:Int, Y:Int):HxlPoint {
		// remove from old tile
		if (_tilePos != null) {
			var tile = Registery.level.getTile(_tilePos.x, _tilePos.y);
			if (tile != null)
				if(Std.is(this,Actor))
					tile.actors.remove(this);
				else if (Std.is(this, Loot))
					tile.loots.remove(this);
		}
		
		// add to new tile
		if(_tilePos == null)
			_tilePos = new HxlPoint(X, Y);
		else {
			_tilePos.x = X;
			_tilePos.y = Y;
		}

		if(Std.is(this,Actor))
			Registery.level.getTile(_tilePos.x, _tilePos.y).actors.push(this);
		else if (Std.is(this, Loot))
			Registery.level.getTile(_tilePos.x, _tilePos.y).loots.push(this);
		
		return _tilePos;
	}

	public function addOnDestroy(Callback:Dynamic) {
		onDestroy.add(Callback);
	}

	public override function destroy() {
		for ( Callback in onDestroy ) Callback();
		super.destroy();
	}

}
