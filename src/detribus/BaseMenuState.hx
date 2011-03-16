package detribus;

import haxel.HxlState;
import haxel.HxlSound;
import detribus.Resources;

class BaseMenuState extends HxlState
{
	static public var scroll:HxlSound;
	static public var select:HxlSound;
	
	static public function playScrollSound() {
		if (scroll == null) {
			scroll = new HxlSound();
			scroll.loadEmbedded(Scroll, false);
		}
		scroll.play();
	}
	
	static public function playSelectSound() {
		if (select == null) {
			select = new HxlSound();
			select.loadEmbedded(Select, false);
		}
		select.play();
	}
	
}