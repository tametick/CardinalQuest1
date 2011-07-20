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
		
/*		
Programming
 Ido Yehieli
 Joris Cizikas

Graphics
 Jagosh Kalezich
 
Music
 Whitaker Blackall
 
Additional Contributors 
 Corey Martin (programming)
 West Clendinning (graphics) 
 Stephen Challener (graphics)
*/

/*
Supporters
 Champion of the Land
  Eronarn

 Saviors of the Developers
  Ainars Skromanis
  Joshua Day
  Mister Dilettante
 
 Master Supporters
  Mike Welsh
  Ido Rosen
  Madrobby
 
 Hero Supporters
  Kornel Kisielewicz
  Jens Bergensten
  Eben Howard
  Mongrol
  Tam Toucan
  Twpage
  Brian Rinaldi
*/

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
