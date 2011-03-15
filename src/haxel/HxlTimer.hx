package haxel;

class HxlTimer {

	static var _game:HxlGame;
	public static var _total:Float = 0;

	var target:Float;
	var base:Float;
	var last:Float;

	public static function setGameData(Game:HxlGame):Void {
		_game = Game;
	}

	public function new(?Target:Int=0) {
		base = _total;
		last = _total;
		target = Target;
	}

	/**
	 * Returns the time (in seconds) relative to the target time.
	 **/
	public function delta():Float {
		return _total - base - target;
	}


}
