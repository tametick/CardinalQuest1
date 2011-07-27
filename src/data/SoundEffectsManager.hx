package data;

import flash.media.Sound;

import haxel.HxlSound;

class SoundEffectsManager {
	public static var enabled:Bool = true;
	public static function play(effect:Class<Dynamic>) {
		if (!enabled)
			return;
		var snd = new HxlSound();
		snd.loadEmbedded(effect);
		snd.play();
	}
}