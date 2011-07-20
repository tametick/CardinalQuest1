package cq.states;

import cq.CqResources;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import haxel.HxlGraphics;
import haxel.HxlState;
import haxel.HxlText;
import haxel.HxlTimer;

class CreditsState extends CqState {
	var fadeTime:Float;

	public override function create() {
		super.create();

		fadeTime = 0.5;
		HxlGraphics.fade.start(false, 0xff000000, fadeTime);
		
		var textColor = 0xffffff;
		var y:Int = 10;
		
		var title:HxlText = new HxlText(0, y, 640, "Credits", true,null , 60, textColor, "center");
		y += Std.int(title.height+10);
		add(title);

		var titleProgramming:HxlText = new HxlText(0, y, 640, "Credits", true,null , 60, textColor, "center");
		y += Std.int(title.height+10);
		add(title);
		
		
		var col1:String = 
"Programming:\n\tIdo Yehieli & Joris Cizikas\n" +
"Graphics:\n\tJagosh Kalezich\n" ;//+
"\n" +
"Music:\tWhitaker Blackall\n";


/*
		scroller.addColumn(40, 270, col1, false, FontAnonymousPro.instance.fontName,18);
		scroller.addColumn(40+270+20, 270, col2, false, FontAnonymousPro.instance.fontName);
*/
		//add(scroller);
	}
	

	public override function update() {
		super.update();
		setDiagonalCursor();
		
	}

	override function onMouseDown(event:MouseEvent) {
		nextScreen();
	}
	
	override function onKeyUp(event:KeyboardEvent) { 
		nextScreen();
	}

	function nextScreen() {

		HxlGraphics.fade.start(true, 0xff000000, fadeTime, function() {
			var newState = new MainMenuState();
			HxlGraphics.state = newState;
		}, true);
	}

}
