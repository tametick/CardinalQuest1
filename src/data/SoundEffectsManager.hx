package data;

import flash.media.Sound;

import haxel.HxlSound;

class SoundEffectsManager {
	static var sounds:Hash<HxlSound> = new Hash<HxlSound>();
	
	public static function play(effect:Class<Sound>) {
		var name = Type.getClassName(effect);
		
		if (sounds.get(name) == null){
			var newEffect = new HxlSound();
			newEffect.loadEmbedded(effect);
			sounds.set(name, newEffect);
		}
		
		sounds.get(name).play();
	}
}