package playtomic.base;

@:final extern class LogRequest {
	var Ready : Bool;
	function new() : Void;
	function MassQueue(p1 : Array<Dynamic>) : Void;
	function Queue(p1 : String) : Void;
	function Send() : Void;
	static function Create() : LogRequest;
}
