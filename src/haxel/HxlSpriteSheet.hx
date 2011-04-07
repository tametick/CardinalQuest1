package haxel;

import flash.display.Bitmap;

class HxlSpriteSheet extends Bitmap {
	public var spriteNames:Array<Array<String>>;
	var spriteIndex:Hash<Int>;
	
	public function new(firstIndex) {
		spriteIndex = initSpriteIndexes(firstIndex,spriteNames);
		super(); 
	}
	
	static function initSpriteIndexes(firstIndex:Int, spriteNames:Array<Array<String>>):Hash<Int> {
		var index = firstIndex;
		var spriteIndex = new Hash<Int>();
		for (spriteY in 0...spriteNames.length)
			for (spriteX in 0...spriteNames[spriteY].length)
				spriteIndex.set(spriteNames[spriteY][spriteX], index++);
				
		return spriteIndex;
	}
	
	public function getSpriteIndex(name:String):Int {
		return spriteIndex.get(name);
	}
}