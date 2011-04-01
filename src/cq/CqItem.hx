package cq;

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
	static var sprites = new SpriteItems();
	
	public function new(?X:Float = 0, ?Y:Float = 0) {
		super(X, Y);
		loadGraphic(SpriteItems, false, false, 16, 16, false, 2.0, 2.0);
		addAnimation("idle", [sprites.getSpriteIndex("chest")], 0 );
		play("idle");
	}
}

class CqWeapon extends CqItem {
	public var damage:Range;
}

class CqItem extends GameObjectImpl, implements Loot {

}