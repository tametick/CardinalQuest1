package world;

import haxel.HxlState;

interface Mob implements Actor 
{
	function act(state:HxlState):Bool;
}