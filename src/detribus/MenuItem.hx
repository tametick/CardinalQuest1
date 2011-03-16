package detribus;

import haxel.HxlText;

class MenuItem extends HxlText
{

	public var itemCallback(getCallback, setCallback):Dynamic;
	var _itemCallback:Dynamic;
	var normalText:String;
	var hoverText:String;
	
	public function new(X:Float, Y:Float, Width:Int, ?Text:String=null, ?EmbeddedFont:Bool=true) 
	{
		super(X, Y, Width, Text, EmbeddedFont);
		hoverText = "";
		normalText = "";
		setText(Text);
	}
	
	public function doCallback():Void {
		if ( _itemCallback != null ) _itemCallback();
	}
	
	public function getCallback():Dynamic {
		return _callback;
	}
	
	public function setCallback(ItemCallback:Dynamic):Dynamic {
		_itemCallback = ItemCallback;
		return _itemCallback;
	}
	
	public function toggleHover(Toggle:Bool):Void {
		if ( Toggle ) {
			this.setText(hoverText);
		} else {
			this.setText(normalText);
		}
	}

	public override function setText(Text:String):String {
		super.setText(Text);
		if ( normalText == "" ) normalText = Text;
		if ( hoverText == "" ) hoverText = "> " + normalText + " <";
		return Text;
	}
}