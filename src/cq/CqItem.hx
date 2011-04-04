package cq;

import data.Configuration;
import data.Registery;
import haxel.HxlState;
import world.Loot;
import world.GameObject;
import cq.CqConfiguration;
import cq.CqResources;
import cq.CqWorld;

import haxel.HxlUtil;

class CqItem extends GameObjectImpl, implements Loot {
	static var sprites = SpriteItems.instance;
	public var equipSlot:CqEquipSlot;
	public var spriteIndex:String;
	public function new(X:Float, Y:Float, typeName:String) {
		super(X, Y);
		loadGraphic(SpriteItems, false, false, Configuration.tileSize, Configuration.tileSize, false, Configuration.zoom, Configuration.zoom);
		addAnimation("idle", [CqItem.sprites.getSpriteIndex(typeName)], 0 );
		play("idle");
		equipSlot = null;
		spriteIndex = typeName;
	}
}

/**
 * Chests are encountered in the dungeon and once detroyed drop a random item
 */
class CqChest extends CqItem {
	public function new(X:Float, Y:Float) {
		super(X, Y,"chest");
	}
	
	public function bust(state:HxlState) {
		// create random item
		var type = null;
		do {
			type = HxlUtil.getRandomElement(Type.getEnumConstructs(CqItemType)); 
		} while (type == "CHEST");
		var item = CqLootFactory.newItem(x, y, type);		
		
		
		// add item to level loot list
		Registery.world.currentLevel.loots.push(item);
		// add item to tile loot list
		cast(Registery.world.currentLevel.getTile(getTilePos().x, getTilePos().y), CqTile).loots.push(item);
		// make item viewable on level
		Registery.world.currentLevel.addLoot(state, item);
		
		// remove chest
		Registery.world.currentLevel.removeLootFromLevel(state, this);
	}
}

class CqLootFactory {
	public static function newItem(X:Float, Y:Float, typeName:String):CqItem {
		var type = Type.createEnum(CqItemType,  typeName);
		var item:CqItem = null;
		
		switch(type) {
			case PURPLE_POTION,	GREEN_POTION, BLUE_POTION,	YELLOW_POTION, RED_POTION:
				item = new CqConsumable(X, Y, typeName.toLowerCase());
			case WINGED_SANDLES, BOOTS:
				item = new CqShoes(X, Y, typeName.toLowerCase());
			case LEATHER_ARMOR, BRESTPLATE:
				item = new CqArmor(X, Y, typeName.toLowerCase());
			case RING, AMULET:
				item = new CqJewelry(X, Y, typeName.toLowerCase());
			case CAP, HELM:
				item = new CqHat(X, Y, typeName.toLowerCase());
			case GLOVE, BRACLET:
				item = new CqGloves(X, Y, typeName.toLowerCase());
			case STAFF, DAGGER, SHORT_SWORD, LONG_SWORD:
				item = new CqWeapon(X, Y, typeName.toLowerCase());
			case CHEST:
		}
		
		return item;
	}
}

class CqConsumable extends CqItem {

}
class CqShoes extends CqItem {
	public function new(X:Float, Y:Float, typeName:String) {
		super(X, Y, typeName);
		equipSlot = SHOES;
	}
}
class CqArmor extends CqItem {
	public function new(X:Float, Y:Float, typeName:String) {
		super(X, Y, typeName);
		equipSlot = ARMOR;
	}
}
class CqJewelry extends CqItem {
	public function new(X:Float, Y:Float, typeName:String) {
		super(X, Y, typeName);
		equipSlot = JEWELRY;
	}
}
class CqHat extends CqItem {
	public function new(X:Float, Y:Float, typeName:String) {
		super(X, Y, typeName);
		equipSlot = HAT;
	}
}
class CqGloves extends CqItem {
	public function new(X:Float, Y:Float, typeName:String) {
		super(X, Y, typeName);
		equipSlot = GLOVES;
	}
}
class CqWeapon extends CqItem {
	public var damage:Range;
	public function new(X:Float, Y:Float, typeName:String) {
		super(X, Y, typeName);
		equipSlot = WEAPON;
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

enum CqEquipSlot {
	SHOES;
	ARMOR;
	JEWELRY;
	HAT;
	GLOVES;
	WEAPON;
}
