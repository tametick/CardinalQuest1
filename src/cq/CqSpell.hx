package cq;

import cq.ui.CqSpellButton;
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
		Resources.descriptions.set("Fireball", "Hurls a ball of fire that explodes on impact. Its power increases alongside your's");
		Resources.descriptions.set("Berserk", "Induces a berserked rage that greatly increases you strength and speed.");
		Resources.descriptions.set("Enfeeble monster", "Weakens monsters and renders them less dangerous.");
		Resources.descriptions.set("Bless weapon", "Blesses the currently wielded weapon, providing a temporary boost to its effectivness.");
		Resources.descriptions.set("Haste", "Makes you faster and more nimble.");
		Resources.descriptions.set("Shadow walk", "Renders you invisible for a few seconds.");
		Resources.descriptions.set("Charm monster","Charms a foe and temporarily brings them to your side."); 
		Resources.descriptions.set("Polymorph","Transoform a creature into another form."); 
		Resources.descriptions.set("Sleep","Puts a monster into a deep slumber."); 
		Resources.descriptions.set("Fear","Makes a monster flee in horror."); 
		Resources.descriptions.set("Magic mirror","Creates a duplicate to draw enemies away from you."); 
		Resources.descriptions.set("Stone skin","Hardens your skin, rendering you tough but slow."); 
		Resources.descriptions.set("Blink","Transports you to a random location.");
		Resources.descriptions.set("Magic armor","Engulfs you in a magical protective aura."); 
		Resources.descriptions.set("Pass wall","Enables walking through walls as if they were thin air.");
		Resources.descriptions.set("Teleport","Transports you to a specific location of your choice."); 
		Resources.descriptions.set("Reveal map","Reveals the laout of the current floor"); 
		Resources.descriptions.set("Heal","Restores health and vigor.");
		inited = true;
	}
	public static function resetRemainigSpells()
	{
		CqSpellFactory.remainingSpells = [];
		for(line in SpriteSpells.instance.spriteNames)
			CqSpellFactory.remainingSpells = CqSpellFactory.remainingSpells.concat(line);
		// no passwall for now
		CqSpellFactory.remainingSpells.remove("pass_wall");
	}
	public static function newRandomSpell(X:Float, Y:Float) {
		if (remainingSpells.length < 1)
			resetRemainigSpells();
		
		var newSpellName = HxlUtil.getRandomElement(remainingSpells);
		
		// uncomment if you want every spell is only be given once
		remainingSpells.remove(newSpellName);
		
		initDescriptions();
		return newSpell(X, Y, Type.createEnum(CqSpellType,  newSpellName.toUpperCase()));
	}
	public static function getfireBalldamageByLevel(level:Int):Range
	{
		var dmg:Range;
		switch(level) {
			case 0:
				dmg = new Range(1, 3);
			case 1:
				dmg = new Range(2, 3);
			case 2:
				dmg = new Range(2, 4);
			case 3:
				dmg = new Range(3, 5);
			case 4:
				dmg = new Range(3, 7);
			case 5:
				dmg = new Range(4, 8);
			case 6:
				dmg = new Range(5, 9);
			case 7:
				dmg = new Range(5, 11);
			default:
				dmg = new Range(6, 12);
			
		}
		return dmg;
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
				spell.spiritPointsRequired = 1440;
			case FIREBALL:
				spell.targetsOther = true;
				//gets modified to character level when spell is casted
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
				spell.specialEffects.add(new CqSpecialEffectValue("invisible"));
				spell.spiritPointsRequired = 720;
			case CHARM_MONSTER:
				spell.duration = 120;
				spell.targetsOther = true;
				spell.specialEffects.add(new CqSpecialEffectValue("charm"));
				spell.spiritPointsRequired = 1440;
			case POLYMORPH:
				spell.duration = 180;
				spell.targetsOther = true;
				spell.specialEffects.add(new CqSpecialEffectValue("polymorph", "true"));
				spell.spiritPointsRequired = 2160;
			case SLEEP:
				spell.duration = 90;
				spell.targetsOther = true;
				spell.specialEffects.add(new CqSpecialEffectValue("sleep", 0));
				spell.spiritPointsRequired = 1440;
			case FEAR:
				spell.duration = 180;
				spell.targetsOther = true;
				spell.specialEffects.add(new CqSpecialEffectValue("fear"));
				spell.spiritPointsRequired = 960;
			case MAGIC_MIRROR: 
				spell.duration = 360;
				spell.targetsEmptyTile = true;
				spell.specialEffects.add(new CqSpecialEffectValue("magic_mirror"));
				spell.spiritPointsRequired = 720*2;
			case STONE_SKIN: 
				spell.duration = 120;
				spell.buffs.set("defense", 5);
				spell.buffs.set("speed", -1);
				spell.spiritPointsRequired = 720;			
			case BLINK:
				spell.specialEffects.add(new CqSpecialEffectValue("blink"));
				spell.spiritPointsRequired = 720;
			case MAGIC_ARMOR: 
				spell.duration = 120;
				spell.buffs.set("defense", 3);
				spell.spiritPointsRequired = 720;
			case TELEPORT:
				spell.targetsEmptyTile = true;
				spell.specialEffects.add(new CqSpecialEffectValue("teleport"));
				spell.spiritPointsRequired = 720*2;
			case REVEAL_MAP:
				spell.specialEffects.add(new CqSpecialEffectValue("reveal"));
				spell.spiritPointsRequired = 7200;
			case HEAL:
				spell.specialEffects.add(new CqSpecialEffectValue("heal","full"));
				spell.spiritPointsRequired = 720*4;
		}
		
		return spell;
	}
}

class CqSpell extends CqItem {
	public var targetsOther:Bool;
	public var targetsEmptyTile:Bool;
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
	POLYMORPH; 
	SHADOW_WALK;
	MAGIC_ARMOR;
	CHARM_MONSTER; 
	REVEAL_MAP; 
	BLINK;
	SLEEP;
	HEAL;
	FEAR; 
	MAGIC_MIRROR; 
	STONE_SKIN; 
	//PASS_WALL;
	TELEPORT; 
}