package cq;
import haxel.HxlState;
import haxel.HxlButton;
import haxel.HxlButtonContainer;

class GameState extends HxlState
{
	public override function create():Void {
		super.create();

		var but1:HxlButton = new HxlButton(0, 0, function(){trace("but1");});
		var but2:HxlButton = new HxlButton(0, 0, function(){trace("but2");});
		var but3:HxlButton = new HxlButton(0, 0, function(){trace("but3");});
		var butcon:HxlButtonContainer = new HxlButtonContainer( 0, 0, 150, 480, HxlButtonContainer.VERTICAL, HxlButtonContainer.TOP_TO_BOTTOM, 20, 10);
		butcon.addButton(but1);
		butcon.addButton(but2);
		butcon.addButton(but3);
		add(butcon);
		butcon.setBackgroundColor(0xff333333);
	}
	
}
