package data.io;

/**
 * ...
 * @author randomnine
 */

interface SaveGameIO 
{
	public function hasSave():Bool;
	public function clearSave():Void;
	
	public function startLoad():Void;
	public function seekToBlock( _name:String, ?_prev:Int = -1 ) : Int;
	public function readInt():Int;
	public function readString():String;
	
	public function startWrite():Void;
	public function startBlock( _name:String ):Void;
	public function writeInt( _v:Int ):Void;
	public function writeString( _s:String ):Void;
	public function completeWrite():Void;
}
