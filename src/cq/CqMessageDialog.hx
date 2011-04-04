package cq;

import cq.CqResources;
import haxel.HxlSlidingDialog;
import haxel.HxlTextContainer;

class CqMessageDialog extends HxlSlidingDialog {

	var textBox:HxlTextContainer;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?Direction:Int=0)
	{
		// Size: 472 x 480
		super(X, Y, Width, Height, Direction);

		textBox = new HxlTextContainer( 0, 0, 472, 480 );
		textBox.reverseOrder = false;
		textBox.maxLines = 27;
		textBox.setFormat(null, 12, 0xffffff, "left", 0xff000000);
		add(textBox);
		textBox.addText("Test 1..");
		textBox.addText("Test 2..");
		for ( i in 0...30 ) {
			textBox.addText("Test "+i+"..");
		}
	}

}
