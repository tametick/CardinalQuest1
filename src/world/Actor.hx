package world;

interface Actor implements GameObject {
	public function attackOther(other:Actor):Void;
	public function moveToPixel(X:Float, Y:Float):Void;
	public function moveStop():Void;
	public var visionRadius:Float;
	public var moveSpeed:Float;
}