package cq;

import data.Configuration;

class CqConfiguration extends Configuration {
	public inline static var chestsPerLevel = 12;
	public inline static var spellsPerLevel = 2;
	public inline static var mobsPerLevel = 18;
	public inline static var lastLevel = 7;
	
	public inline static var playerLives = 9;
	
	public inline static var dropPotionChance:Float = 0.4;
	public inline static var betterItemChance:Float = 0.1;
	public inline static var EnchantItemChance:Float = 0.1;
	public inline static var BetterEnchantItemChance:Float = 0.01;
	
	public inline static var strongerEnemyChance:Float = 0.7;
	
	public inline static function getLevelWidth(?level:Int=0) { 
		return 32; 
	}
	public inline static function getLevelHeight(?level:Int=0) {
		return 32; 
	}
}
