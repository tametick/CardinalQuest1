package haxel;

class HxlDialog extends HxlGroup
{

	public function new(X:Int, Y:Int, Width:Int, Height:Int) {
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


	public override function update():Void
	{
	    super.update();
	    //this.reset(x, y);
	}

}
