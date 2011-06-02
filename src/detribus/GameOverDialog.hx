package detribus;

import haxel.HxlGraphics;
import haxel.HxlObject;
import haxel.HxlText;
import haxel.HxlSprite;
import flash.events.KeyboardEvent;
import com.eclecticdesignstudio.motion.Actuate;

class GameOverDialog extends StatsDialog {

	private var defeatText:HxlText;
	private var victoryText:HxlText;

	public function new(Width:Int, Height:Int) {
		super(Width, Height);

		defeatText = new HxlText(0, 65, 300, "Game Over!", true);
		defeatText.setFormat(null, 50, 0xffffff, "center", 0x010101);
		add(defeatText);
		defeatText.visible = false;

		victoryText = new HxlText(0, 65, 300, "You Win!", true);
		victoryText.setFormat(null, 50, 0xffffff, "center", 0x010101);
		add(victoryText);
		victoryText.visible = false;

		var o:HxlObject;
		for (i in 0...members.length) {
			o = cast( members[i], HxlObject);
			o.scrollFactor.x = o.scrollFactor.y = 0;
		}
	}

	public function disable():Void {
		HxlGraphics.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		defeatText.visible = false;
		victoryText.visible = false;
	}

	public function fadeIn():Void {
		var self = this;
		Actuate.update(function(params:Dynamic):Void {
			var o:HxlSprite;
			for (i in 0...self.members.length) {
				o = cast( self.members[i], HxlSprite);
				o.alpha = params.Alpha;
			}
		}, 1.5, {Alpha: 0.1}, {Alpha: 1.0});
	}

	public function showVictory():Void {
		defeatText.visible = false;
		victoryText.visible = true;
		visible = true;
		fadeIn();
		HxlGraphics.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown,false,0,true);
	}

	public function showDefeat():Void {
		victoryText.visible = false;
		defeatText.visible = true;
		visible = true;
		fadeIn();
		HxlGraphics.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown,false,0,true);
	}

	function onKeyDown(event:KeyboardEvent):Void {
		HxlGraphics.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		HxlGraphics.fade.start(true, 0xffffffff, 0.25, function() {
			HxlGraphics.state = new StateTitle(); 
		}, true);	
	}

	public override function destroy():Void {
		HxlGraphics.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		super.destroy();
	}
}
