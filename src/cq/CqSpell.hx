package cq;

import cq.CqItem;
import data.Resources;

class CqSpellFactory {
	static function initDescriptions() {
		if(Resources.descriptions==null)
			Resources.descriptions = new Hash<String>();
		
		Resources.descriptions.set("Freeze", "description 1");
		Resources.descriptions.set("Fireball", "description 2");
		Resources.descriptions.set("Berserk", "description 3");
		Resources.descriptions.set("Enfeeble monster", "description 4");
		Resources.descriptions.set("Bless weapon", "description 5");
		Resources.descriptions.set("Haste", "description 6 ");
		Resources.descriptions.set("Shadow walk", "description 7");
	}
	
	public static function newSpell(X:Float, Y:Float, typeName:String):CqSpell {
		var type = Type.createEnum(CqSpellType,  typeName);
		var spell = new CqSpell(X, Y, typeName.toLowerCase());
		
		spell.name = StringTools.replace(typeName.toLowerCase(), "_", " ");
		spell.name = spell.name.substr(0, 1).toUpperCase() + spell.name.substr(1);
		
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