package cq;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Cubic;

import data.Configuration;
import data.Registery;
import haxel.HxlState;
import haxel.HxlGraphics;
import world.Loot;
import world.GameObject;
import cq.CqConfiguration;
import cq.CqResources;
import cq.CqWorld;

import haxel.HxlUtil;

class CqSpecialEffectValue {
	public var name:String;
	public var value:Dynamic;
	public function new(name:String, value:Dynamic) {
		this.name = name;
		this.value = value;
	}
}

class CqLootFactory {
	public static function newItem(X:Float, Y:Float, typeName:String):CqItem {
		var type = Type.createEnum(CqItemType,  typeName);
		var item = new CqItem(X, Y, typeName.toLowerCase());
		
		switch(type) {
			case WINGED_SANDLES, BOOTS:
				item.equipSlot = CqEquipSlot.SHOES;
			case LEATHER_ARMOR, BRESTPLATE:
				item.equipSlot = CqEquipSlot.ARMOR;
			case RING, AMULET:
				item.equipSlot = CqEquipSlot.JEWELRY;
			case CAP, HELM:
				item.equipSlot = CqEquipSlot.HAT;
			case GLOVE, BRACLET:
				item.equipSlot = CqEquipSlot.GLOVES;
			case STAFF, DAGGER, SHORT_SWORD, LONG_SWORD:
				item.equipSlot = CqEquipSlot.WEAPON;
			default:
		}
		
		switch(type) {
			case GREEN_POTION:
				item.consumable = true;
				item.specialEffects.add(new CqSpecialEffectValue("heal","full"));
			case PURPLE_POTION:
				item.consumable = true;
				item.specialEffects.add(new CqSpecialEffectValue("damage","double"));
				item.duration = 120;
			case BLUE_POTION:
				item.consumable = true;
				item.buffs.set("defense", 3);
				item.duration = 120;
			case YELLOW_POTION:
				item.consumable = true;
				item.buffs.set("speed", 3);
				item.duration = 120;
			case RED_POTION:
				item.consumable = true;
				item.buffs.set("attack", 3);
				item.duration = 120;
			
			case BOOTS:
				item.buffs.set("speed", 1);
			case WINGED_SANDLES:
				item.buffs.set("speed", 2);
				
			case LEATHER_ARMOR:
				item.buffs.set("defense", 1);
			case BRESTPLATE:
				item.buffs.set("defense", 2);
			
			case RING:
				item.buffs.set("spirit", 1);
			case AMULET:
				item.buffs.set("spirit", 2);
			
			case CAP:
				item.buffs.set("life", 1);
			case HELM:
				item.buffs.set("life", 2);
			
			case GLOVE:
				item.buffs.set("attack", 1);
			case BRACLET:
				item.buffs.set("attack", 2);
			
			case DAGGER:
				item.damage = new Range(1, 2);
			case STAFF:
				item.damage = new Range(1, 3);
			case SHORT_SWORD:
				item.damage = new Range(1, 3);
			case LONG_SWORD:
				item.damage = new Range(2, 4);
			
			default:
		}
		
		return item;
	}
}

class CqItem extends GameObjectImpl, implements Loot {
	public var equipSlot:CqEquipSlot;
	public var consumable:Bool;
	public var spriteIndex:String;
	public var damage:Range;
	// changes to basic abilities (attack, defense, speed, spirit)
	public var buffs:Hash<Int>;
	// special effects beyond changes to basic abilities
	public var specialEffects:List<CqSpecialEffectValue>;
	
	public var duration:Int;
	
	public function new(X:Float, Y:Float, typeName:String) {
		super(X, Y);

		zIndex = 1;
		
		if (Std.is(this, CqSpell)) {
			loadGraphic(SpriteSpells, false, false, Configuration.tileSize, Configuration.tileSize, false, Configuration.zoom, Configuration.zoom);
			addAnimation("idle", [SpriteSpells.instance.getSpriteIndex(typeName)], 0 );
		} else {
			loadGraphic(SpriteItems, false, false, Configuration.tileSize, Configuration.tileSize, false, Configuration.zoom, Configuration.zoom);
			addAnimation("idle", [SpriteItems.instance.getSpriteIndex(typeName)], 0 );
		}
		
		consumable = false;
		spriteIndex = typeName;
		damage = new Range(0, 0);
		buffs = new Hash<Int>();
		specialEffects = new List<CqSpecialEffectValue>();
		duration = -1;
		play("idle");
	}

	public function doPickupEffect():Void {
		HxlGraphics.state.add(this);
		var self = this;
		var oldX = x;
		var oldY = y;
		Actuate.update(function(params:Dynamic) {
			self.x = params.X;
			self.y = params.Y;
			self.alpha = params.Alpha;
		}, 1.0, {X: x, Y: y, Alpha: 1.0}, {X: x, Y: y-48, Alpha: 0.0}).onComplete(function() {
			self.x = oldX;
			self.y = oldY;
			HxlGraphics.state.remove(self);
			self.destroy();
		}).ease(Cubic.easeOut); 
	}
}

/**
 * Chests are encountered in the dungeon and once detroyed drop a random item
 */
class CqChest extends CqItem {

	var onBust:List<Dynamic>;

	public function new(X:Float, Y:Float) {
		super(X, Y,"chest");
		onBust = new List();
		visible = false;
	}
	
	public function addOnBust(Callback:Dynamic):Void {
		onBust.add(Callback);
	}

	public function bust(state:HxlState) {

		for ( Callback in onBust ) Callback(this);

		// create random item
		var type = null;
		do {
			type = HxlUtil.getRandomElement(Type.getEnumConstructs(CqItemType)); 
		} while (type == "CHEST");
		var item = CqLootFactory.newItem(x, y, type);		
		
		// add item to level
		Registery.world.currentLevel.addLootToLevel(state, item);
		
		// remove chest
		Registery.world.currentLevel.removeLootFromLevel(state, this);
	}
}

enum CqItemType {
	AMULET;
	BOOTS;
	LEATHER_ARMOR;
	BRESTPLATE;
	CHEST;
	GLOVE;
	CAP;
	RING;
	BRACLET;
	WINGED_SANDLES;
	STAFF;
	DAGGER;
	SHORT_SWORD;
	LONG_SWORD;
	PURPLE_POTION;
	GREEN_POTION;
	BLUE_POTION;
	YELLOW_POTION;
	RED_POTION;
	HELM;
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

enum CqEquipSlot {
	SHOES;
	ARMOR;
	JEWELRY;
	HAT;
	GLOVES;
	WEAPON;
	SPELL;
}
