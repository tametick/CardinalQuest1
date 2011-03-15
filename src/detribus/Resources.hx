import flash.text.Font;
import flash.display.Bitmap;
import flash.media.Sound;

class FontGeo extends Font { public function new(){super();} }
class SpritesSmall extends Bitmap { public function new(){super();} }
class Tileset extends Bitmap { public function new() { super(); } }
class Rain extends Sound { public function new() { super(); } }
class Nohighscore extends Sound { public function new() { super(); } }
class Innerfight extends Sound { public function new() { super(); } }
class Victory extends Sound { public function new() { super(); } }
class Death extends Sound { public function new() { super(); } }
class Powerdown extends Sound { public function new() { super(); } }
class Powerup extends Sound { public function new() { super(); } }
class Shot extends Sound { public function new() { super(); } }
class Shot2 extends Sound { public function new() { super(); } }
class Dodge extends Sound { public function new() { super(); } }
class Scroll extends Sound { public function new() { super(); } }
class Select extends Sound { public function new() { super(); } }


class Resources { 
	public static var walkableTiles:Array<Int> = 
		[7, 8, 16, 22, 29, 51, 54, 64];
	public static var seeThroughTiles:Array<Int> = 
		[7, 9, 10, 11, 15, 17, 18, 19, 20, 21, 23, 24, 25, 26, 27, 33, 34, 37, 38, 41, 42, 43, 44, 45, 46, 47, 48, 55, 56, 58, 59, 60, 61, 62, 63, 64];
	public static var debrisTiles:Array<Int> = 
		[37, 38, 59];
		
	public static var tileSize = 16; // in pixels
	
	public static var wildernessWidth = 45; // in tiles
	public static var wildernessHeight = 30;
	
	public static var cavesWidth = 30; // in tiles
	public static var cavesHeight = 30;
}