package world;

import haxel.HxlState;

class World 
{
	public var currentLevel:Level;
	public var currentLevelIndex:Int;
	//var levels:Array<Level>;
	
	public function new() {
		currentLevelIndex = 0;
		//levels = new Array<Level>();
	}
	
	public function goToNextLevel(state:HxlState,?jumpToLevel:Int = -1){}
}