package cq;

import data.Configuration;

class CqConfiguration extends Configuration {
	public static var chestsPerLevel = 1;
	
	public static function getLevelWidth(?level:Int=0) { 
		return 32; 
	}
	public static function getLevelHeight(?level:Int=0) {
		return 32; 
	}
}