package cq;

import world.Decoration;
import world.GameObject;

class CqDecoration extends GameObjectImpl, implements Decoration{
	public function new(X:Float, Y:Float, typeName:String) {
		super(X, Y, typeName);
	}
}