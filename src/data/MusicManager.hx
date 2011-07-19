package data;

import flash.media.Sound;

import haxel.HxlSound;

class MusicManager {
	static var tracks:Hash<HxlSound> = new Hash<HxlSound>();
	static var currentlyPlaying:HxlSound;
	
	public static function play(track:Class<Sound>) {
		var name = Type.getClassName(track);
		
		if (currentlyPlaying != null) {
			if (currentlyPlaying == tracks.get(name))
				// already playing chosen tune
				return;
			currentlyPlaying.stop();
		}
		
		if (tracks.get(name) == null){
			var newTrack = new HxlSound();
			newTrack.loadEmbedded(track, true);
			tracks.set(name, newTrack);
		}
		
		currentlyPlaying = tracks.get(name);
		currentlyPlaying.play();
	}
	
	public static function stop() {
		if (currentlyPlaying != null) {
			currentlyPlaying.stop();
			currentlyPlaying = null;
		}
	}
}