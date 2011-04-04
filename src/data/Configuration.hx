package data;

class Configuration {
	public static var tileSize:Int;
	public static var zoom:Float;
	public static function zoomedTileSize():Int { 
		return Std.int(tileSize * zoom); 
	}
}