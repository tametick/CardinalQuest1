package cq.ui;

import cq.CqResources;

import haxel.HxlGradient;
import haxel.HxlGraphics;
import haxel.HxlSlidingDialog;
import haxel.HxlSprite;
import haxel.HxlTextContainer;
import haxel.HxlLog;

class CqMessageDialog extends HxlSlidingDialog, implements HxlLogViewer {
	var textBox:HxlTextContainer;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?Direction:Int=0) {
		// Size: 472 x 480
		super(X, Y, Width, Height, Direction);

		textBox = new HxlTextContainer( 10, 10, 452, 460 );
		
		//fixme - don't create new color arrays every time
		
		#if !flashmobile
		textBox.setBackgroundSprite(HxlGradient.Rect(452, 460, [0xd5d5d5, 0xcfcfcf, 0xbfbfbf, 0x505050, 0x333333], [0, 1, 2, 10, 255], null, Math.PI / 2, 20));
		#end

		textBox.reverseOrder = false;
		textBox.maxLines = 100;
		textBox.setFormat(null, 16, 0xffffff, "left", 0x010101);
		add(textBox);
		
		HxlLog.logViewer = this;
	}
	
	public function append(message:String) {
		textBox.addText(message);
	}
}
