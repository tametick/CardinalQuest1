package cq;

import data.Configuration;

class CqConfiguration extends Configuration {
	public static var chestsPerLevel = 12;
	public static var spellsPerLevel = 1;
	public static var mobsPerLevel = 24;
	public static var lastLevel = 7;
	
	public static function getLevelWidth(?level:Int=0) { 
		return 32; 
	}
	public static function getLevelHeight(?level:Int=0) {
		return 32; 
	}
}
