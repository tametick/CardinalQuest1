package cq;

class CqConfiguration
{
	public static var tileSize = 16;
	
	public static function getLevelWidth(?level:Int=0) { 
		return 32; 
	}
	public static function getLevelHeight(?level:Int=0) {
		return 32; 
	}
}