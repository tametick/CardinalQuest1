package cq;

import cq.CqItem;
import data.Resources;

class CqSpellFactory {
	static var inited = false;
	static function initDescriptions() {
		if(Resources.descriptions==null)
			Resources.descriptions = new Hash<String>();
		
		Resources.descriptions.set("Freeze", "Freezes monsters in place for a short duration.");
		Resources.descriptions.set("Fireball", "Hurls a ball of fire that explodes on impact.");
		Resources.descriptions.set("Berserk", "Induces berserk rage that greatly increases strength and speed.");
		Resources.descriptions.set("Enfeeble monster", "Weakens monsters and renders them less dangerous.");
		Resources.descriptions.set("Bless weapon", "Blesses the currently wielded weapon, providing a temporary boost to its effectivness.");
		Resources.descriptions.set("Haste", "Turns the caster fast and nimble.");
		Resources.descriptions.set("Shadow walk", "Renders the caster invisible for a few seconds.");
	}
	
	public static function newSpell(X:Float, Y:Float, typeName:String):CqSpell {
		if(!inited) {
			initDescriptions();
			inited = true;
		}
		
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