package haxel;

import flash.display.Bitmap;

class HxlSpriteSheet extends Bitmap {
	var spriteNames:Array<Array<String>>;
	var spriteIndex:Hash<Int>;
	
	public function new(?firstIndex:Int=1) {
		initSpriteIndexes(firstIndex);
		super(); 
	}
	
	function initSpriteIndexes(firstIndex:Int) {
		var index = firstIndex;
		spriteIndex = new Hash<Int>();
		for (spriteY in 0...spriteNames.length)
			for (spriteX in 0...spriteNames[spriteY].length)
				spriteIndex.set(spriteNames[spriteY][spriteX], index++);
	}
	
	public function getSpriteIndex(name:String):Int {
		return spriteIndex.get(name);
	}
}