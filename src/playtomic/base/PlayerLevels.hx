package playtomic.base;

extern class PlayerLevels {
	function new() : Void;
	static function DeferToKongregate(p1 : Dynamic, p2 : Dynamic) : Void;
	static function Flag(p1 : String) : Void;
	static function List(?p1 : Dynamic, ?p2 : Dynamic) : Void;
	static function Load(p1 : String, ?p2 : Dynamic) : Void;
	static function LogQuit(p1 : String) : Void;
	static function LogRetry(p1 : String) : Void;
	static function LogStart(p1 : String) : Void;
	static function LogWin(p1 : String) : Void;
	static function Rate(p1 : String, p2 : Int, ?p3 : Dynamic) : Void;
	static function Save(p1 : PlayerLevel, ?p2 : flash.display.DisplayObject, ?p3 : Dynamic) : Void;
}
