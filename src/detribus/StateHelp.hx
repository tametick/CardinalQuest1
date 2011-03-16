package detribus;

import flash.events.KeyboardEvent;
import haxel.HxlGraphics;
import haxel.HxlState;

class StateHelp extends HxlState {

	var helpBox:MessageBox;
	public var startGame:Bool;
	public var paused:Bool;

	public override function create() {
		super.create();

		paused = false;
		startGame = false;
		
		helpBox = new MessageBox(30, 20, 300, 200);
		//helpBox = new MessageBox(30, 20, 300, 100);

		add(helpBox);
		helpBox.setBackground(false);
		helpBox.messageText.text = "Your ship crash-landed on an alien planet and you require a new SpaceGizmo3000 to fix it!\n\nLuckily, you have spotted a cave entry right before you crashed - perhaps you can steal one from the Xuuth bandits living inside?\n\nUse the arrow keys to move and space to fire your laser pistol.\n\nUsing shift+arrow you can change the direction you're facing without moving.";
		helpBox.setFontSize(15);
		
		helpBox.messageText.alpha = 0.0;
		HxlGraphics.fade.start(false, 0xffffffff, 0.25, null, true);

		HxlGraphics.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}
	
	public override function destroy():Void {
		if (HxlGraphics.stage != null) {
			HxlGraphics.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
	}
	
	function onKeyUp(event:KeyboardEvent):Void {
		if(!paused) {
			var c:Int = event.keyCode;
			if ( c == 27) {	// Escape
				HxlGraphics.fade.start(true, 0xffffffff, 0.25, function() {
					HxlGraphics.state = new StateTitle(); 
				}, true);
			} else if (startGame) {
				HxlGraphics.fade.start(true, 0xffffffff, 0.25, function() {
					HxlGraphics.state = new StateCreateChar(); 
				}, true);
			} 
		}
	}	
	
}