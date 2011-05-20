package playtomic.base;

extern class Encode {
	function new() : Void;
	static function Base64(p1 : flash.utils.ByteArray) : String;
	static function Base64Decode(p1 : String) : flash.utils.ByteArray;
	static function MD5(p1 : String) : String;
	static function PNG(p1 : flash.display.BitmapData) : flash.utils.ByteArray;
}
