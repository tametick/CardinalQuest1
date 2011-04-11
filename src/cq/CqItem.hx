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
		
		return item;
	}
}

class CqItem extends GameObjectImpl, implements Loot {
	public var equipSlot:CqEquipSlot;
	public var type:Dynamic;
	public var spriteIndex:String;
	public var damage:Range;
	
	public function new(X:Float, Y:Float, typeName:String) {
		super(X, Y);
		
		if (Std.is(this, CqSpell)) {
			loadGraphic(SpriteSpells, false, false, Configuration.tileSize, Configuration.tileSize, false, Configuration.zoom, Configuration.zoom);
			type = Type.createEnum(CqSpellType,  typeName.toUpperCase());
			addAnimation("idle", [SpriteSpells.instance.getSpriteIndex(typeName)], 0 );
		} else {
			loadGraphic(SpriteItems, false, false, Configuration.tileSize, Configuration.tileSize, false, Configuration.zoom, Configuration.zoom);
			type = Type.createEnum(CqItemType,  typeName.toUpperCase());
			addAnimation("idle", [SpriteItems.instance.getSpriteIndex(typeName)], 0 );
		}
		
		spriteIndex = typeName;
		damage = new Range(0, 0);
		play("idle");
	}

	public function doPickupEffect():Void {
		HxlGraphics.state.add(this);
		var self = this;
		Actuate.update(function(params:Dynamic) {
			self.x = params.X;
			self.y = params.Y;
			self.alpha = params.Alpha;
		}, 1.0, {X: x, Y: y, Alpha: 1.0}, {X: x, Y: y-48, Alpha: 0.0}).onComplete(function() {
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
