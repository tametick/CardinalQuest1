package cq;
import haxel.HxlState;
import haxel.HxlButton;
import haxel.HxlButtonContainer;
import haxel.HxlTextContainer;

class GameState extends HxlState
{

	var textcon:HxlTextContainer;

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

		var self = this;
		but3.setCallback(function() {
			self.testfunc();
		});
	}

	public function testfunc() {
		textcon.addText("Button 3..");
	}

}
