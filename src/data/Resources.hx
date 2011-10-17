package data;

class Resources {
	public static var walkableTiles:Array<Int>;
	public static var seeThroughTiles:Array<Int>;
	public static var walkableAndSeeThroughTiles:Array<Int>;
	public static var solidAndBlockingTiles:Array<Int>;
	public static var descriptions:Hash<String>;
	public static var doors:Array<Int>;
	public static var stairsDown:Array<Int>;
	public static var statsFiles:Hash<StatsFile> = new Hash<StatsFile>();
}
