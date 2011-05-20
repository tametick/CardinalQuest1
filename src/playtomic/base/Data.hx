package playtomic.base;

extern class Data {
	function new() : Void;
	static function CustomMetric(p1 : String, p2 : Dynamic, ?p3 : Dynamic) : Void;
	static function LevelAverageMetric(p1 : String, p2 : Dynamic, p3 : Dynamic, ?p4 : Dynamic) : Void;
	static function LevelCounterMetric(p1 : String, p2 : Dynamic, p3 : Dynamic, ?p4 : Dynamic) : Void;
	static function LevelRangedMetric(p1 : String, p2 : Dynamic, p3 : Dynamic, ?p4 : Dynamic) : Void;
	static function PlayTime(p1 : Dynamic, ?p2 : Dynamic) : Void;
	static function Plays(p1 : Dynamic, ?p2 : Dynamic) : Void;
	static function Views(p1 : Dynamic, ?p2 : Dynamic) : Void;
}
