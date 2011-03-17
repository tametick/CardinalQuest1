package data;

class AbstractConfiguration 
{
	public static var tileSize;
	public function getLevelWidth(level:Int):Int { return -1; }
	public function getLevelHeight(level:Int):Int { return -1; }
}