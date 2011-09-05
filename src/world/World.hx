package world;

import haxel.HxlState;

class World {
	public var currentLevel:Level;
	public var currentLevelIndex:Int;
	
	public function new() {
		currentLevelIndex = 0;
	}
	
	public function goToNextLevel(state:HxlState,?jumpToLevel:Int = -1){}
}