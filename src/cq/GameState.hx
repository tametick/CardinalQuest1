package cq;
import haxel.HxlState;
import haxel.HxlButton;
import haxel.HxlButtonContainer;
import haxel.HxlTextContainer;
import haxel.HxlSlidingDialog;

class GameState extends HxlState
{

	var textcon:HxlTextContainer;
	var sliding:HxlSlidingDialog;
	
	public override function create():Void {
		super.create();

		var but1:HxlButton = new HxlButton(0, 0);
		var but2:HxlButton = new HxlButton(0, 0);
		var but3:HxlButton = new HxlButton(0, 0);

		var butcon:HxlButtonContainer = new HxlButtonContainer( 0, 0, 150, 480, HxlButtonContainer.VERTICAL, HxlButtonContainer.BOTTOM_TO_TOP, 20, 10);
		butcon.addButton(but1);
		butcon.addButton(but2);
		butcon.addButton(but3);
		add(butcon);
		butcon.setBackgroundColor(0xff333333);

		textcon = new HxlTextContainer( 170, 0, 300, 80 );
		textcon.setBackgroundColor(0xff333333);
		textcon.setFormat("Geo", 18, 0xffffff, "left", 0x000000);
		add(textcon);
		textcon.addText("Uh oh, whats that sound?");
		textcon.addText("Tick tock, tick tock");
		textcon.addText("Boom goes the dynamite!");
		textcon.addText("test?");
		textcon.addText("Button 3..");
		
		sliding = new HxlSlidingDialog( 175, 0, 290, 400);
		sliding.setBackgroundColor(0xffddbcbc);
		add(sliding);
		//sliding.show();
		
		var self = this;
		but3.setCallback(function() {
			self.testfunc();
		});
		
		but2.setCallback(sliding.show);
		but1.setCallback(sliding.hide);
	}

	public function testfunc() {
		textcon.addText("Button 3..");
	}

}
