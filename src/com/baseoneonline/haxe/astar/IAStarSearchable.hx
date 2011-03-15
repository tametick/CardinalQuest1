package com.baseoneonline.haxe.astar;
	
interface IAStarSearchable
{
	function isWalkable(x:Int, y:Int):Bool;
	function getWidth():Int;
	function getHeight():Int;
}