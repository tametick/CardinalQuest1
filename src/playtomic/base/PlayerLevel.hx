package playtomic.base;

@:final extern class PlayerLevel {
	var CustomData : Dynamic;
	var Data : String;
	var LevelId : String;
	var Name : String;
	var Permalink : String;
	var PlayerId : Int;
	var PlayerName : String;
	var PlayerSource : String;
	var Plays : Int;
	var RDate : String;
	var Rating : Float;
	var SDate : Date;
	var Score : Int;
	var ThumbData : String;
	var Votes : Int;
	function new() : Void;
	function Thumb() : flash.display.BitmapData;
	function Thumbnail() : String;
}
