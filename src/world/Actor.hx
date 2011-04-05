package world;

import haxel.HxlState;

interface Actor implements GameObject {
	function attackObject(state:HxlState, other:GameObject):Void;
	function attackOther(state:HxlState, other:GameObject):Void;
	function moveToPixel(X:Float, Y:Float):Void;
	function moveStop():Void;
	var visionRadius:Float;
	var moveSpeed:Float;
}