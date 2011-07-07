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
		
		Resources.descriptions.set("Freeze", "Freezes a monster in place for a short duration.");
		Resources.descriptions.set("Fireball", "Hurls a ball of fire that explodes on impact.");
		Resources.descriptions.set("Berserk", "Induces a berserked rage that greatly increases you strength and speed.");
		Resources.descriptions.set("Enfeeble monster", "Weakens monsters and renders them less dangerous.");
		Resources.descriptions.set("Bless weapon", "Blesses the currently wielded weapon, providing a temporary boost to its effectivness.");
		Resources.descriptions.set("Haste", "Makes you faster and more nimble.");
		Resources.descriptions.set("Shadow walk", "Renders you invisible for a few seconds.");
		
		inited = true;
	}
	
	public static function newRandomSpell(X:Float, Y:Float) {
		if (remainingSpells.length < 1){
			trace("todo: add more spells");
			return null;
		}
		
		var newSpellName = HxlUtil.getRandomElement(remainingSpells);
		
		// every spell is only given once
		//remainingSpells.remove(newSpellName);
		
		initDescriptions();
		return newSpell(X, Y, Type.createEnum(CqSpellType,  newSpellName.toUpperCase()));
	}
	
	public static function newSpell(X:Float, Y:Float, type:CqSpellType):CqSpell {
		initDescriptions();
		
		var typeName:String = Type.enumConstructor(type).toLowerCase();
		var spell = new CqSpell(X, Y, type);
		
		spell.name = StringTools.replace(typeName, "_", " ");
		spell.name = spell.name.substr(0, 1).toUpperCase() + spell.name.substr(1);
		
		switch(type) {
			case FREEZE:
				spell.targetsOther = true;
				spell.duration = 120;
				spell.buffs.set("speed", -3);
				spell.spiritPointsRequired = 720;
			case FIREBALL:
				spell.targetsOther = true;
				spell.damage = new Range(1, 6);
				spell.spiritPointsRequired = 720;
			case BERSERK:
				spell.duration = 60;
				spell.buffs.set("attack", 3);
				spell.buffs.set("speed", 3);
				spell.spiritPointsRequired = 720;
			case ENFEEBLE_MONSTER:
				spell.targetsOther = true;
				spell.duration = 120;
				spell.buffs.set("attack", -3);
				spell.spiritPointsRequired = 720;
			case BLESS_WEAPON:
				spell.duration = 120;
				spell.buffs.set("attack", 3);
				spell.spiritPointsRequired = 720;
			case HASTE:
				spell.duration = 120;
				spell.buffs.set("speed", 3);
				spell.spiritPointsRequired = 720;
			case SHADOW_WALK:
				spell.duration = 120;
				spell.specialEffects.add(new CqSpecialEffectValue("invisible", "true"));
				spell.spiritPointsRequired = 720;
			case CHARM_MONSTER:
				spell.duration = 120;
				spell.targetsOther = true;
				spell.specialEffects.add(new CqSpecialEffectValue("charm", "true"));
				spell.spiritPointsRequired = 720;
			case POLYMORPH:
			case SLEEP: 
			case FEAR: 
			case MAGIC_MIRROR: 
			case STONE_SKIN: 
				spell.duration = 120;
				spell.buffs.set("defense", 5);
				spell.buffs.set("speed", -1);
				spell.spiritPointsRequired = 720;			
			
			case BLINK:
			case MAGIC_ARMOR: 
				spell.duration = 120;
				spell.buffs.set("defense", 3);
				spell.spiritPointsRequired = 720;
			case PASS_WALL:
			case TELEPORT: 
			case REVEAL_MAP:
			case HEAL:
				spell.specialEffects.add(new CqSpecialEffectValue("heal","full"));
				spell.spiritPointsRequired = 720*4;
		}
		
		return spell;
	}
}

class CqSpell extends CqItem {
	public var targetsOther:Bool;
	public var spiritPoints:Int;
	public var spiritPointsRequired:Int;
	
	public function new(X:Float, Y:Float, type:CqSpellType) {
		super(X, Y, type);
		equipSlot = SPELL;
		visible = false;
		spiritPoints = 0;
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
	CHARM_MONSTER; 
	POLYMORPH; 
	SLEEP; 
	FEAR; 
	MAGIC_MIRROR; 
	STONE_SKIN; 
	BLINK;
	MAGIC_ARMOR; 
	PASS_WALL;
	TELEPORT; 
	REVEAL_MAP; 
	HEAL;
}