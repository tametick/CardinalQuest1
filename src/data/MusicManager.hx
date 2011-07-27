package data;

import flash.media.Sound;

import haxel.HxlSound;

class MusicManager {
	static var tracks:Hash<HxlSound> = new Hash<HxlSound>();
	static var currentlyPlaying:HxlSound;
	static var paused:Bool = false;
	
	public static function play(track:Class<Sound>) {
		//plays a new one, or if paused,only sets the current track to the new one
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
		if (!paused)currentlyPlaying.play();
	}
	
	public static function stop() {
		if (paused) return;
		//stops and forgets last played track
		if (currentlyPlaying != null) {
			currentlyPlaying.stop();
			currentlyPlaying = null;
		}
	}
	public static function pause()
	{
		//stops but retains last played track
		if (!paused)
		{
			paused = true;
			if (currentlyPlaying != null) {
				currentlyPlaying.pause();
			}
		}
	}
	public static function resume()
	{
		if (paused)
		{
			paused = false;
			if (currentlyPlaying != null) {
				currentlyPlaying.play();
			}
		}
	}
}