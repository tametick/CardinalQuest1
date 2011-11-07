package data;

import data.StatsFile;

class Resources {
	public static var walkableTiles:Array<Int>;
	public static var seeThroughTiles:Array<Int>;
	public static var walkableAndSeeThroughTiles:Array<Int>;
	public static var solidAndBlockingTiles:Array<Int>;
	public static var doors:Array<Int>;
	public static var stairsDown:Array<Int>;
	public static var statsFiles:Hash<StatsFile> = new Hash<StatsFile>();
	
	public static function getString( _id:String, _description:Bool = false ) : String {
		var strings:StatsFile = Resources.statsFiles.get( if ( _description ) "descriptions.txt" else "strings.txt" );
		
		var desc:StatsFileEntry = strings.getEntry( "ID", _id );
		var descText:String = if (desc != null) desc.getField( "Data" ); else "???";

		var descTextLines:Array<String> = descText.split( "\\n" );
		descText = "";
		for ( l in 0 ... descTextLines.length-1 ) {
			descText += descTextLines[l] + "\n";
		}
		descText += descTextLines[descTextLines.length-1];
		
		return descText;
	}
}
