package cq;
import world.World;

class CqWorld extends World 
{

	public function new() 
	{
		super();
		
		levels.push(new CqLevel());
		currentLevel = levels[0];
	}
	
}