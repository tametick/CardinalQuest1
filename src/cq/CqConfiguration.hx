package cq;

import data.Configuration;

class CqConfiguration extends Configuration {
	public static var chestsPerLevel = 18;
	public static var spellsPerLevel = 2;
	public static var mobsPerLevel = 36;
	public static var lastLevel = 7;
	
	public static function getLevelWidth(?level:Int=0) { 
		return 32; 
	}
	public static function getLevelHeight(?level:Int=0) {
		return 32; 
	}
}
