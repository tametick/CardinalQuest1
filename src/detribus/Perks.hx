

class Perks {

	public static var PERK_DAMAGE:Int = 0;
	public static var PERK_DODGE:Int = 1;
	public static var PERK_ARMOR:Int = 2;

	private var perkNames:Array<String>;
	private var perkValues:Array<Int>;

	public var player:Player;
	
	public function new() {
		perkNames = new Array();
		perkValues = new Array();
		perkNames[0] = "Damage";
		perkValues[0] = 0;
		perkNames[1] = "Dodge";
		perkValues[1] = 0;
		perkNames[2] = "Armor";
		perkValues[2] = 0;
	}

	public function getPerkNames():Array<String> {
		return perkNames;
	}

	public function perkName(Idx:Int):String {
		if ( Idx < 0 || Idx >= perkNames.length ) return "";
		return perkNames[Idx];
	}

	public function getAllPerkValues():Array<Int> {
		return perkValues;
	}
	
	public function getPerkValue(Idx:Int):Int {
		if ( Idx < 0 || Idx >= perkValues.length ) return 0;
		return perkValues[Idx];
	}

	public function setPerkValue(Idx:Int, Value:Int):Int {
		if ( Idx < 0 || Idx >= perkValues.length ) return 0;
		perkValues[Idx] = Value;
		return perkValues[Idx];
	}

	/*  use this function for level gain! */
	public function incrementPerkValue(idx:Int) {
		perkValues[idx]++;
		switch(idx) {
			case PERK_ARMOR:
				player.armor++;
			case PERK_DODGE:
				player.dodge++;
			case PERK_DAMAGE:
				player.damage++;
		}
	}
}
