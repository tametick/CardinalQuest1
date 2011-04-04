package cq;

import data.Registery;
import haxel.HxlState;
import world.Loot;
import world.GameObject;
import cq.CqResources;
import cq.CqWorld;

import haxel.HxlUtil;


/**
 * Chests are encountered in the dungeon and once detroyed drop a random item
 */
class CqChest extends CqObject, implements Loot{
	// fixme
	static var sprites = SpriteItems.instance;
	
	public function new(X:Float, Y:Float) {
		super(X, Y);
		loadGraphic(SpriteItems, false, false, 16, 16, false, 2.0, 2.0);
		addAnimation("idle", [sprites.getSpriteIndex("chest")], 0 );
		play("idle");
	}
	
	public function bust(state:HxlState) {
		// remove chest
		Registery.world.currentLevel.removeLootFromLevel(state, this);
		
		// add random item
		var newItemType = Type.createEnum(CqItemType,  HxlUtil.getRandomElement(Type.getEnumConstructs(CqItemType)));
		trace(newItemType);
	}
}

class CqWeapon extends CqItem {
	public var damage:Range;
}

class CqItem extends GameObjectImpl, implements Loot {

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