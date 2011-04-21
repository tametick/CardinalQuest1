package cq;

import cq.CqItem;

class CqSpell extends CqItem {
	public function new(X:Float, Y:Float, typeName:String) {
		super(X, Y, typeName);
		equipSlot = SPELL;
		visible = false;
		name = "Spell name not available";
	}
}
