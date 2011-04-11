package haxel;

import haxel.HxlObject;

class HxlObjectContainer extends HxlDialog {

	public static var VERTICAL:Int = 0;
	public static var HORIZONTAL:Int = 1;
	public static var LEFT_TO_RIGHT:Int = 0;
	public static var RIGHT_TO_LEFT:Int = 1;
	public static var TOP_TO_BOTTOM:Int = 0;
	public static var BOTTOM_TO_TOP:Int = 1;

	var alignment:Int;
	var order:Int;
	var objects:List<HxlObject>;

	/**
	 * Amount of space (in pixels) between edges of container and objects.
	 **/
	public var padding:Float;

	/**
	 * Amount of space (in pixels) between each object.
	 **/
	public var spacing:Float;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?Alignment:Int=0, ?Order:Int=0, ?Padding:Int=20, ?Spacing:Int=20) {
		super(X, Y, Width, Height);
		alignment = Alignment;
		order = Order;
		padding = Padding;
		spacing = Spacing;
		objects = new List();
	}

	public function addObject(Obj:HxlObject):Void {
		objects.add(Obj);
		Obj.zIndex = 1;
		add(Obj);
		updateLayout();
	}

	public function removeObj(Obj:HxlObject):Void {
		objects.remove(Obj);
		remove(Obj);
		updateLayout();
	}

	private function updateLayout():Void {
		var X:Float = 0;
		var Y:Float = 0;
		if ( alignment == VERTICAL && order == BOTTOM_TO_TOP ) {
			Y = height;
		} else if ( alignment == HORIZONTAL && order == RIGHT_TO_LEFT ) {
			X = width;
		}
		if ( order == TOP_TO_BOTTOM || order == LEFT_TO_RIGHT ) {
			X += padding;
			Y += padding;
		} else {
			X -= padding;
			Y -= padding;
		}
		var count:Int = 0;
		for ( Obj in objects ) {
			if ( alignment == HORIZONTAL ) {

				if ( order == LEFT_TO_RIGHT && count > 0 ) {
					X += spacing;
				} else if ( order == RIGHT_TO_LEFT ) {
					X -= Obj.width;
				}

				Y = (height / 2) - (Obj.height / 2);
				Obj.x = X;
				Obj.y = Y;
				if ( order == LEFT_TO_RIGHT ) {
					X += Obj.width;
				} else {
					X -= spacing;
				}
			} else {
				if ( order == TOP_TO_BOTTOM && count > 0 ) {
					Y += spacing;
				} else if ( order == BOTTOM_TO_TOP ) {
					Y -= Obj.height;
				}
				X = (width / 2) - (Obj.width / 2);
				Obj.y = Y;
				Obj.x = X;
				if ( order == TOP_TO_BOTTOM ) {
					Y += Obj.height;
				} else {
					Y -= spacing;
				}
			}
			count++;
		}
	}

	public override function add(Object:HxlObjectI,?ShareScroll:Bool=true):HxlObjectI {
		super.add(Object, ShareScroll);
		return Object;
	}
}
