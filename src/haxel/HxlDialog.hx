package haxel;

class HxlDialog extends HxlGroup
{

	var background:HxlSprite;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super();
		x = X;
		y = Y;
		width = Width;
		height = Height;
		scrollFactor.x = 0;
		scrollFactor.y = 0;
	}

	public override function add(Object:HxlObject,?ShareScroll:Bool=true):HxlObject {
		super.add(Object, ShareScroll);
		return Object;
	}

	public override function replace(OldObject:HxlObject,NewObject:HxlObject):HxlObject {
		NewObject.scrollFactor.x = NewObject.scrollFactor.y = 0;
		super.replace(OldObject, NewObject);
		return NewObject;
	}

	public function setBackgroundColor(Color:Int):Void {
		if ( background == null ) {
			background = new HxlSprite(0, 0);
			background.zIndex = 0;
			add(background);
		}
		background.createGraphic(Std.int(width), Std.int(height), Color);
	}

	public function setBackgroundGraphic(Graphic:Class<Bitmap>):Void {
		if ( background == null ) {
			background = new HxlSprite(0, 0);
			background.zIndex = 0;
			add(background);
		}
		background.loadGraphic(Graphic);
	}


	public override function update():Void
	{
	    super.update();
	    this.reset(x, y);
	}

}
