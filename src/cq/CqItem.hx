package cq;

import items.Item;
import world.GameObject;
import haxel.HxlUtil;

class CqWeapon extends CqItem {
	public var damage:Range;
}

class CqItem extends GameObjectImpl, implements Item {

}