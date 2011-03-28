package cq;

import haxel.HxlDialog;
import haxel.HxlSlidingDialog;

class CqInventoryDialog extends HxlSlidingDialog {

	var dlgCharacter:HxlDialog;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?Direction:Int=0)
	{
		// Size: 472 x 480
		super(X, Y, Width, Height, Direction);

		dlgCharacter = new HxlDialog(10, 10, 216, 220);
		dlgCharacter.setBackgroundColor(0xff999999);
		add(dlgCharacter);
	}

}
