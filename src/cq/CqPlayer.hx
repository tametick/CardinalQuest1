package cq;
import world.Player;
import world.GameObject;

class CqPlayer extends GameObjectImpl, implements Player
{

	public function new(?x:Int=-1, ?y:Int=-1) 
	{
		super(x,y);
	}
	
}