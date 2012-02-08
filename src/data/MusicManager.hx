package data;

import flash.media.Sound;

import haxel.HxlSound;

class MusicManager {
	static var currentlyPlaying:HxlSound;
	static var currentlyPlayingName:String;
	static var paused:Bool = false;
	
	public static function play(track:Class<Dynamic>) {
		//plays a new one, or if paused,only sets the current track to the new one
		var name = Type.getClassName(track);
		
		if (currentlyPlaying != null) {
			if (currentlyPlayingName == name){
				// already playing chosen tune
				return;
			}
			currentlyPlaying.stop();
			currentlyPlayingName = null;
		}
		
		
		currentlyPlaying = new HxlSound();
		currentlyPlaying.loadEmbedded(track, true);
		currentlyPlayingName = name;
		
		if (!paused)
			currentlyPlaying.play();
			
			
		name = null;
	}
	
	public static function stop() {
		if (paused) 
			return;
			
		//stops and forgets last played track
		if (currentlyPlaying != null) {
			currentlyPlaying.stop();
			//currentlyPlaying.kill();
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