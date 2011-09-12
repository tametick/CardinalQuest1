package world;

import haxel.HxlState;
import haxel.HxlPoint;
import haxel.HxlUIBar;

interface Actor implements GameObject {
	function attackObject(state:HxlState, other:GameObject):Void;
	function attackOther(state:HxlState, other:GameObject):Void;
	function actInDirection(state:HxlState, targetTile:HxlPoint):Bool;
	function moveToPixel(state:HxlState, X:Float, Y:Float):Void;
	function moveStop():Void;
	var visionRadius:Float;
	var moveSpeed:Float;
	var isMoving:Bool;
	var actionPoints:Int;
	public var healthBar:HxlUIBar;
}