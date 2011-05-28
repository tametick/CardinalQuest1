package cq;
import cq.CqResources;
import haxel.HxlState;
import haxel.HxlButton;
import haxel.HxlButtonContainer;
import haxel.HxlTextContainer;
import haxel.HxlSlidingDialog;
import haxel.HxlSprite;
import haxel.HxlGradient;
import haxel.HxlUIBar;

class UITestState extends HxlState
{

	var textcon:HxlTextContainer;
	var sliding:HxlSlidingDialog;
	var bar:HxlUIBar;

	public override function create():Void {
		super.create();

		var but1:HxlButton = new HxlButton(0, 0, 64, 64);
		var but2:HxlButton = new HxlButton(0, 0, 64, 64);
		var but3:HxlButton = new HxlButton(0, 0, 64, 64);

		var butcon:HxlButtonContainer = new HxlButtonContainer( 0, 0, 84, 480, HxlButtonContainer.VERTICAL, HxlButtonContainer.TOP_TO_BOTTOM, 10, 10);
		butcon.addButton(but1);
		butcon.addButton(but2);
		butcon.addButton(but3);
		add(butcon);
		//butcon.setBackgroundColor(0xff333333, 30);
		butcon.setBackgroundGraphic(SpriteTiles, true, 30);

		textcon = new HxlTextContainer( 170, 0, 300, 80 );
		textcon.setBackgroundColor(0xff333333);
		textcon.setFormat("FontDungeon", 18, 0xffffff, "left", 0x000000);
		add(textcon);
		textcon.setColorStep(true);
		textcon.addText("Uh oh, whats that sound?");
		textcon.addText("Tick tock, tick tock");
		textcon.addText("Boom goes the dynamite!");
		textcon.addText("test?");
		textcon.addText("Button 3..");
		
		sliding = new HxlSlidingDialog( 84, 0, 472, 480);
		sliding.setBackgroundColor(0xffddbcbc);
		add(sliding);
		//sliding.show();

		var but4:HxlButton = new HxlButton(200, 200, 64, 64);
		sliding.add(but4);
		//add(but4);

		
		but2.setCallback(sliding.show);
		but1.setCallback(sliding.hide);

		var grad1:HxlSprite = HxlGradient.Rect(64, 64, [0xffcccc, 0xff3333, 0xff0000], [0, 128, 255], null, Math.PI/2, 10);
		grad1.x = 300;
		grad1.y = 200;
		add(grad1);
		grad1.toggleDrag(true);
		//grad1.onDragStart(function() { trace("Started dragging!"); });
		//grad1.onDragStop(function() { trace("Stopped dragging!"); });

		var myspr:HxlSprite = new HxlSprite();
		myspr.loadGraphic(SpritePlayer, true, false, 32, 32, false, 2, 2);
		myspr.x = 200;
		myspr.y = 200;
		myspr.setFrame(3);
		add(myspr);
		myspr.toggleDrag(true);

		bar = new HxlUIBar(200, 300, 300, 20);
		bar.setFrameColor(0xff444444);
		bar.setInteriorColor(0xff000000);
		bar.setBarColor(0xffff5555);
		add(bar);
		//bar.setPercent(Math.random() * 1.0);

		var self = this;
		but3.setCallback(function() {
			self.testfunc();
			self.randBarValue();
		});

	}

	public function randBarValue() {
		bar.setPercent(Math.random() * 1.0);
	}

	public function testfunc() {
		textcon.addText("Button 3..");
	}

}
