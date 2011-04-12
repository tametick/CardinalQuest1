package cq;

import cq.CqItem;

class CqSpell extends CqItem {
	public function new(X:Float, Y:Float, typeName:String) {
		super(X, Y, typeName);
		equipSlot = SPELL;
	}

	public function use(self:CqActor, other:CqActor) {
		// todo
	
	}
}
