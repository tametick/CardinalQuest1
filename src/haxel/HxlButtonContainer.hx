package haxel;

class HxlButtonContainer extends HxlDialog {

	public static var VERTICAL:Int = 0;
	public static var HORIZONTAL:Int = 1;
	public static var LEFT_TO_RIGHT:Int = 0;
	public static var RIGHT_TO_LEFT:Int = 1;
	public static var TOP_TO_BOTTOM:Int = 0;
	public static var BOTTOM_TO_TOP:Int = 1;

	var alignment:Int;
	var order:Int;
	var buttons:List<HxlButton>;

	/**
	 * Amount of space (in pixels) between edges of container and buttons.
	 **/
	public var padding:Float;

	/**
	 * Amount of space (in pixels) between each button.
	 **/
	public var spacing:Float;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?Alignment:Int=0, ?Order:Int=0, ?Padding:Int=20, ?Spacing:Int=20) {
		super(X, Y, Width, Height);
		alignment = Alignment;
		order = Order;
		padding = Padding;
		spacing = Spacing;
		buttons = new List();
	}

	public function addButton(Button:HxlButton):Void {
		buttons.add(Button);
		add(Button);
		updateLayout();
	}

	public function removeButton(Button:HxlButton):Void {
		buttons.remove(Button);
		add(Button);
		updateLayout();
	}

	private function updateLayout():Void {
		var X:Float = 0;
		var Y:Float = 0;
		var offset:HxlPoint = new HxlPoint(0, 0);
		X += padding;
		Y += padding;
		var count:Int = 0;
		for ( Button in buttons ) {
			if ( alignment == HORIZONTAL ) {
				if ( count > 0 ) X += spacing;
				Y = (height / 2);
				Button.x = X;
				Button.y = Y;
				X += Button.width;
			} else {
				if ( count > 0 ) Y += spacing;
				X = (width / 2);
				Button.y = Y;
				Button.x = X;
				Y += Button.height;
			}
			count++;
		}
	}

	public override function add(Object:HxlObject,?ShareScroll:Bool=true):HxlObject {
		super.add(Object, ShareScroll);
		return Object;
	}
}
