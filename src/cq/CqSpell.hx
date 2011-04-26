package cq;

import haxel.HxlUtil;

import cq.CqItem;
import cq.CqResources;

import data.Resources;

class CqSpellFactory {
	static var inited = false;
	public static var remainingSpells:Array<String>;
	
	static function initDescriptions() {
		if (inited)
			return;
		
		if(Resources.descriptions==null)
			Resources.descriptions = new Hash<String>();
		
		Resources.descriptions.set("Freeze", "Freezes monsters in place for a short duration.");
		Resources.descriptions.set("Fireball", "Hurls a ball of fire that explodes on impact.");
		Resources.descriptions.set("Berserk", "Induces berserk rage that greatly increases strength and speed.");
		Resources.descriptions.set("Enfeeble monster", "Weakens monsters and renders them less dangerous.");
		Resources.descriptions.set("Bless weapon", "Blesses the currently wielded weapon, providing a temporary boost to its effectivness.");
		Resources.descriptions.set("Haste", "Turns the caster fast and nimble.");
		Resources.descriptions.set("Shadow walk", "Renders the caster invisible for a few seconds.");
		
		inited = true;
	}
	
	public static function newRandomSpell(X:Float, Y:Float) {
		if (remainingSpells.length < 1){
			trace("todo: add more spells");
			return null;
		}
		
		var newSpellName = HxlUtil.getRandomElement(remainingSpells);
		// every spell is only given once
		remainingSpells.remove(newSpellName);
		
		initDescriptions();
		return newSpell(X, Y, newSpellName.toUpperCase());
	}
	
	public static function newSpell(X:Float, Y:Float, typeName:String):CqSpell {
		initDescriptions();
		
		var type = Type.createEnum(CqSpellType,  typeName);
		var spell = new CqSpell(X, Y, typeName.toLowerCase());
		
		spell.name = StringTools.replace(typeName.toLowerCase(), "_", " ");
		spell.name = spell.name.substr(0, 1).toUpperCase() + spell.name.substr(1);
		
		switch(type) {
			case FREEZE:
			case FIREBALL:
			case BERSERK:
			case ENFEEBLE_MONSTER:
			case BLESS_WEAPON:
			case HASTE:
			case SHADOW_WALK:
		}
		
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