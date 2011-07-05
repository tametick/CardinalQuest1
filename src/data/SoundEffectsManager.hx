package data;

import flash.media.Sound;

import haxel.HxlSound;

class SoundEffectsManager {
	public static function play(effect:Class<Sound>) {
		var snd = new HxlSound();
		snd.loadEmbedded(effect);
		snd.play();
	}
}