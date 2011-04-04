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


/**
 * Chests are encountered in the dungeon and once detroyed drop a random item
 */
class CqChest extends CqItem {
	public function new(X:Float, Y:Float) {
		super(X, Y);
		loadGraphic(SpriteItems, false, false, Configuration.tileSize, Configuration.tileSize, false, 2.0, 2.0);
		addAnimation("idle", [CqItem.sprites.getSpriteIndex("chest")], 0 );
		play("idle");
	}
	
	public function bust(state:HxlState) {
		// remove chest
		Registery.world.currentLevel.removeLootFromLevel(state, this);
		
		// add random item
		var newItem = null;
		do {
			newItem	= HxlUtil.getRandomElement(Type.getEnumConstructs(CqItemType)); 
		} while (newItem == "CHEST");
		var newItemType = Type.createEnum(CqItemType,  newItem);
		
		trace(newItemType);
	}
}

class CqWeapon extends CqItem {
	public var damage:Range;
}

class CqItem extends GameObjectImpl, implements Loot {
	static var sprites = SpriteItems.instance;
	public function new(X:Float, Y:Float) {
		super(X, Y);
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