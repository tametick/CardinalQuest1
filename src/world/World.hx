package world;

import haxel.HxlState;

class World {
	public var currentLevel:Level;
	public var currentLevelIndex:Int;
	
	public function new() {
		currentLevelIndex = 0;
	}
	
	public function destroy() {
		currentLevel.kill();
		currentLevel = null;
	}
	
	public function goToNextLevel(?jumpToLevel:Int = -1){}
}