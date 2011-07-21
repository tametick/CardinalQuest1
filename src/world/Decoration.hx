package world;

interface Decoration implements GameObject {
	function colorTween(params:Dynamic):Void;
	function colorTo(ToColor:Int, Speed:Float):Void;
	function setColor(Color:Int):Int;
}