package playtomic;

extern class Log {
	function new() : Void;
	static var BaseUrl : String;
	static var Cookie : flash.net.SharedObject;
	static var Enabled : Bool;
	static var GUID : String;
	static var Queue : Bool;
	static var Request : LogRequest;
	static var SWFID : Int;
	static var SourceUrl : String;
	static function CustomMetric(p1 : String, ?p2 : String, p3 : Bool = false) : Void;
	static function ForceSend() : Void;
	static function Freeze() : Void;
	static function Funnel(p1 : String, p2 : String, p3 : Int) : Void;
	static function Heatmap(p1 : String, p2 : String, p3 : Int, p4 : Int) : Void;
	static function IncreasePlays() : Void;
	static function IncreaseViews() : Void;
	static function LevelAverageMetric(p1 : String, p2 : Dynamic, p3 : Int, p4 : Bool = false) : Void;
	static function LevelCounterMetric(p1 : String, p2 : Dynamic, p3 : Bool = false) : Void;
	static function LevelRangedMetric(p1 : String, p2 : Dynamic, p3 : Int, p4 : Bool = false) : Void;
	static function Link(p1 : String, p2 : String, p3 : String, p4 : Int, p5 : Int, p6 : Int) : Void;
	static function Play() : Void;
	static function PlayerLevelFlag(p1 : String) : Void;
	static function PlayerLevelQuit(p1 : String) : Void;
	static function PlayerLevelRetry(p1 : String) : Void;
	static function PlayerLevelStart(p1 : String) : Void;
	static function PlayerLevelWin(p1 : String) : Void;
	static function UnFreeze() : Void;
	static function View(p1 : Int = 0, ?p2 : String, ?p3 : String) : Void;
}
