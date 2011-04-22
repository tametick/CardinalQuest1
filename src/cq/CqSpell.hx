package cq;

import cq.CqItem;
import data.Resources;

class CqSpellFactory {
	static function initDescriptions() {
		if(Resources.descriptions==null)
			Resources.descriptions = new Hash<String>();
		
		//...
	}
	
	public static function newSpell(X:Float, Y:Float, typeName:String):CqSpell {
		var type = Type.createEnum(CqSpellType,  typeName);
		var spell = new CqSpell(X, Y, typeName.toLowerCase());
		
		spell.name = StringTools.replace(typeName.toLowerCase(),"_"," ");
		
		return spell;
	}
}

class CqSpell extends CqItem {
	
	
	
	public function new(X:Float, Y:Float, typeName:String) {
		super(X, Y, typeName);
		equipSlot = SPELL;
		visible = false;
	}
}

enum CqSpellType {
	FREEZE; 
	FIREBALL; 
	BERSERK; 
	ENFEEBLE_MONSTER; 
	BLESS_WEAPON; 
	HASTE; 
	SHADOW_WALK;
}