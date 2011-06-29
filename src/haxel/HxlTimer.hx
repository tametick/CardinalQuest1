package haxel;

class HxlTimer {

	static var _game:HxlGame;
	public static var _total:Float = 0;

	var target:Float;
	var targetCallback:Dynamic;
	var callbackFired:Bool;
	var base:Float;
	var last:Float;

	public static function setGameData(Game:HxlGame) {
		_game = Game;
	}

	public function new(?Target:Float=0, ?TargetCallback:Dynamic=null) {
		reset(Target, TargetCallback);
	}

	public function reset(?Target:Float=0, ?TargetCallback:Dynamic=null) {
		base = _total;
		last = _total;
		target = Target;
		targetCallback = TargetCallback;
		callbackFired = false;
	}

	/**
	 * Returns the time (in seconds) relative to the target time.
	 **/
	public function delta():Float {
		var Delta:Float = _total - base - target;
		if ( !callbackFired && Delta >= target ) {
			if ( targetCallback != null ) targetCallback();
			callbackFired = true;
		}
		return Delta;
	}


}
