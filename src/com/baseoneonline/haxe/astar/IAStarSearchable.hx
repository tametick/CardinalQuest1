package com.baseoneonline.haxe.astar;
	
interface IAStarSearchable
{
	function getAStarNodes():Array<AStarNode>;
//	function getNode(x:Int, y:Int):AStarNode;
//	function isWalkable(x:Int, y:Int):Bool;
	function getWidth():Int;
	function getHeight():Int;
}