package haxel;

import cq.CqGraphicKey;
import cq.states.GameState;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Stage;
import flash.system.Capabilities;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.media.Sound;

import haxel.HxlMouse;
import haxel.HxlKeyboard;
import haxel.HxlFlash;
import haxel.HxlQuake;
import haxel.HxlFade;
import haxel.HxlObject;

import data.MusicManager;
import data.Configuration;

class HxlGraphicsBMPData extends BitmapData {}
class HxlGraphics {

	/**
	 * Reference to the current HxlGame object.
	 **/
	static var _game:HxlGame;
	/**
	 * If you build and maintain your own version of flixel,
	 * you can give it your own name here.  Appears in the console.
	 */
	public static var LIBRARY_NAME:String = "haxel";
	/**
	 * Assign a major version to your library.
	 * Appears before the decimal in the console.
	 */
	public static var LIBRARY_MAJOR_VERSION:Int = 0;
	/**
	 * Assign a minor version to your library.
	 * Appears after the decimal in the console.
	 */
	public static var LIBRARY_MINOR_VERSION:Int = 5;

	/**
	 * Internal tracker for game pause state.
	 */
	static var _pause:Bool;
	static public var justUnpaused:Bool;

	/**
	 * Width of the screen in game pixels.
	 **/
	public static var width:Int;
	/**
	 * Height of the screen in game pixels.
	 */
	public static var height:Int;
	
	/**
	 * An indicator declaring whether the current screen should be treated as "small" for fluid layouts
	 */
	public static var smallScreen:Bool;
	
	/**
	 * <code>HxlGraphics.levels</code> and <code>HxlGraphics.scores</code> are generic
	 * global variables that can be used for various cross-state stuff.
	 */
	public static var levels:Array<Dynamic>;
	public static var level:Int;
	public static var scores:Array<Dynamic>;
	public static var score:Int;
	/**
	 * <code>HxlGraphics.saves</code> is a generic bucket for storing
	 * FlxSaves so you can access them whenever you want.
	 */
	public static var saves:Array<Dynamic>;
	public static var save:Int;

	/**
	 * References the active graphics buffer.
	 **/
	
	#if useHxlMobileDisplay
	public static var buffer:HxlMobileDisplay;
	#else
	public static var buffer:HxlGraphicsBMPData;
	#end
	/**
	 * Tells the camera to follow this <code>FlxCore</code> object around.
	 */
	public static var followTarget:HxlObjectI;
	/**
	 * Used to force the camera to look ahead of the <code>followTarget</code>.
	 */
	public static var followLead:Point;
	/**
	 * Used to smoothly track the camera as it follows.
	 */
	public static var followLerp:Float;
	/**
	 * Stores the top and left edges of the camera area.
	 */
	public static var followMin:Point;
	/**
	 * Stores the bottom and right edges of the camera area.
	 */
	public static var followMax:Point;
	
	/**
	 * Stores the center point of the camera area.
	 */
	public static var followCenter:Point;
	
	/**
	 * Internal, used to assist camera and scrolling.
	 */
	static var _scrollTarget:Point;
	/**
	 * Stores the basic parallax scrolling values.
	 */
	public static var scroll:Point;

	/**
	 * Internal tracker for bounding box visibility.
	 */
	static var _showBounds:Bool;

	/**
	* Represents the amount of time in seconds that passed since last frame.
	*/
	public static var elapsed:Float;

	/**
	 * Essentially locks the framerate to a minimum value - any slower and you'll get slowdown instead of frameskip; default is 1/30th of a second.
	 */
	public static var maxElapsed:Float;

	/**
	 * An attempt to fix evil behaviors on air (where it locks out rendering if we take too long to update -- only it's not documented how long that is.)
	 */
	public static var wayTooLong:Float;	
	
	/**
	 * How fast or slow time should pass in the game; default is 1.0.
	 */
	public static var timeScale:Float;

	/**
	 * Number of renders made for the current frame.
	 **/
	public static var numRenders:Int = 0;

	/**
	 * Number of updates made for the current frame.
	 **/
	public static var numUpdates:Int = 0;

	/**
	 * A handy container for a background music object.
	 */
	public static var music:HxlSound;
	/**
	 * A list of all the sounds being played in the game.
	 */
	public static var sounds:Array<HxlSound>;
	/**
	 * Internal flag for whether or not the game is muted.
	 */
	static var _mute:Bool;
	/**
	 * Internal volume level, used for global sound control.
	 */
	static var _volume:Float;
	/**
	 * A reference to a <code>HxlMouse</code> object.  Important for input!
	 */
	public static var mouse:HxlMouse;
	/**
	 * A reference to a <code>HxlKeyboard</code> object.  Important for input!
	 */
	public static var keys:HxlKeyboard;
	/**
	 * A special effect that flashes a color on the screen.  Usage: HxlGraphics.flash.start();
	 */
	public static var flash:HxlFlash;
	/**
	 * A special effect that shakes the screen.  Usage: HxlGraphics.quake.start();
	 */
	public static var quake:HxlQuake;
	/**
	 * A special effect that fades a color onto the screen.  Usage: HxlGraphics.fade.start();
	 */
	public static var fade:HxlFade;

	/**
	 * If set to true, objects which are not currently on screen will skip rendering.
	 **/
	public static var autoVisible:Bool = true;
	
	// force all baked HxlGroups to rebake:
	public static var rebakeAll:Bool = false;

	/**
	 * If set to true, whenever an object is added to or removed from an HxlGroup, that group
	 * will sort its members according to zIndex, lowest to highest.
	 **/
	public static var autoZSort:Bool = true;

	public static var _defaultFont:String = "system";

	public function new() { }

	public static var framerate(getFramerate, setFramerate) : Int;
	public static var frameratePaused(getFrameratePaused, setFrameratePaused) : Int;
	public static var stage(getStage, null) : Stage;
	public static var showBounds(getShowBounds, setShowBounds) : Bool;
	public static var mute(getMute, setMute) : Bool;
	public static var volume(getVolume, setVolume) : Float;
	public static var state(getState, setState) : HxlState;
	public static var pause(getPause, setPause) : Bool;
	
	public static var blackBarHeight : Int = 0;

	/**
	 * Called by HxlGame to set up HxlGraphics during game constructor.
	 **/
	public static function setGameData(Game:HxlGame, Width:Int, Height:Int, Zoom:Int) {
		_game = Game;
		width = Width;
		height = Height;
		#if flashmobile
		smallScreen = true;
		#else
		smallScreen = false;
		#end
		scroll = null;
		_scrollTarget = null;
		unfollow();
		timeScale = 1.0;
		//framerate = 60;
		framerate = 30;
		frameratePaused = 10;
		maxElapsed = 0.033333;
		wayTooLong = 0.250;
		
		HxlGraphics.elapsed = 0;
		_showBounds = false;
		HxlObject._refreshBounds = false;
		_mute = false;
		_volume = 0.5;
		sounds = new Array();
		mouse = new HxlMouse();
		keys = new HxlKeyboard();
		flash = new HxlFlash();
		quake = new HxlQuake(Zoom);
		fade = new HxlFade();
	}

	/**
	 * Log data to the developer console.
	 *
	 * @param	Data		Anything you want to log to the console.
	 */
	public static function log(Data:Dynamic) {
		if ((_game != null) && (_game.console != null)) {
			_game.console.log((Data == null)?"ERROR: null object":Data.toString());
		}
	}

	/**
	 * Stops and resets the camera.
	 */
	public static function unfollow()
	{
		followTarget = null;
		followLead = null;
		followLerp = 1;
		followMin = null;
		followMax = null;
		if (scroll == null) {
			scroll = new Point();
		} else {
			scroll.x = scroll.y = 0;
		}
		if (_scrollTarget == null) {
			_scrollTarget = new Point();
		} else {
			_scrollTarget.x = _scrollTarget.y = 0;
		}
	}

	/**
	 * Tells the camera subsystem what <code>HxlCore</code> object to follow.
	 *
	 * @param	Target		The object to follow.
	 * @param	Lerp		How much lag the camera should have (can help smooth out the camera movement).
	 */
	public static function follow(Target:HxlObjectI, ?Lerp:Float=1) {
		followTarget = Target;
		followLerp = Lerp;
		_scrollTarget.x = (Math.floor(width)>>1)-followTarget.x-(Math.floor(followTarget.width)>>1);
		_scrollTarget.y = (Math.floor(height)>>1)-followTarget.y-(Math.floor(followTarget.height)>>1);
		scroll.x = _scrollTarget.x;
		scroll.y = _scrollTarget.y;
		
		if (followCenter == null) {
			followCenter = new Point(Math.floor(width) >> 1, Math.floor(height) >> 1);
		}
		
		doFollow();
	}

	/**
	 * Specify an additional camera component - the velocity-based "lead",
	 * or amount the camera should track in front of a sprite.
	 *
	 * @param	LeadX		Percentage of X velocity to add to the camera's motion.
	 * @param	LeadY		Percentage of Y velocity to add to the camera's motion.
	 */
	public static function followAdjust(?LeadX:Float = 0, ?LeadY:Float = 0) {
		followLead = new Point(LeadX,LeadY);
	}

	/**
	 * Specify the boundaries of the level or where the camera is allowed to move.
	 *
	 * @param	MinX				The smallest X value of your level (usually 0).
	 * @param	MinY				The smallest Y value of your level (usually 0).
	 * @param	MaxX				The largest X value of your level (usually the level width).
	 * @param	MaxY				The largest Y value of your level (usually the level height).
	 * @param	UpdateWorldBounds	Whether the quad tree's dimensions should be updated to match.
	 */
	public static function followBounds(?MinX:Int=0, ?MinY:Int=0, ?MaxX:Int=0, ?MaxY:Int=0, ?UpdateWorldBounds:Bool=true) {
		followMin = new Point(-MinX,-MinY);
		followMax = new Point(-MaxX+width,-MaxY+height);
		if (followMax.x > followMin.x) {
			followMax.x = followMin.x;
		}
		if (followMax.y > followMin.y) {
			followMax.y = followMin.y;
		}
		if (UpdateWorldBounds) {
			HxlUtil.setWorldBounds(MinX,MinY,MaxX-MinX,MaxY-MinY);
		}
		doFollow();
	}

	/**
	 * Used to counter the flickering of dithered surfaced when scrolling
	 */
	static function makeEven(val:Float):Int {
		var intVal = Math.round(val);
		if (intVal / 2 == Std.int(intVal / 2))
			return intVal;
		else
			return intVal + 1;
	}

	/**
	 * Internal function that updates the camera and parallax scrolling.
	 */
	public static function doFollow() {
		// TODO: Port me!
		if (followTarget != null) {
			_scrollTarget.x = followCenter.x - followTarget.x - (Math.floor(followTarget.width)>>1);
			_scrollTarget.y = followCenter.y - followTarget.y - (Math.floor(followTarget.height)>>1);
			
			if ((followLead != null) && (Std.is( followTarget, HxlSprite))) {
				_scrollTarget.x -= (cast( followTarget, HxlSprite)).velocity.x*followLead.x;
				_scrollTarget.y -= (cast( followTarget, HxlSprite)).velocity.y*followLead.y;
			}
			
			if (followLerp > 0) {
				scroll.x += makeEven((_scrollTarget.x-scroll.x)*followLerp*HxlGraphics.elapsed);
				scroll.y += makeEven((_scrollTarget.y-scroll.y)*followLerp*HxlGraphics.elapsed);
			} else {
				scroll.x = _scrollTarget.x;
				scroll.y = _scrollTarget.y;
			}

			if (followMin != null) {
				if (scroll.x > followMin.x) {
					scroll.x = followMin.x;
				}
				if (scroll.y > followMin.y) {
					scroll.y = followMin.y;
				}
			}

			if (followMax != null) {
				if (scroll.x < followMax.x) {
					scroll.x = followMax.x;
				}
				if (scroll.y < followMax.y) {
					scroll.y = followMax.y;
				}
			}
		}
	}

	/**
	 * Reset the input helper objects (useful when changing screens or states)
	 */
	public static function resetInput() {
		keys.reset();
		mouse.reset();
	}

	/**
	 * Retrieves the Flash stage object (required for event listeners)
	 *
	 * @return	A Flash <code>MovieClip</code> object.
	 */
	public static function getStage():Stage {
		#if !useHxlMobileDisplay
		if ((_game.state != null)  && (_game.state.parent != null)) {
			return _game.state.parent.stage;
		}

		return null;
		#else
			return buffer.stage;
		#end
	}

	/**
	 * The game and SWF framerate; default is 60.
	 */
	public static function getFramerate():Int {
		return _game.framerate;
	}

	/**
	 * @private
	 */
	public static function setFramerate(Framerate:Int):Int {
		_game.framerate = Framerate;
		if (!_game.paused && (_game.stage != null)) {
			_game.stage.frameRate = Framerate;
		}
		return Framerate;
	}

	/**
	 * The game and SWF framerate while paused; default is 10.
	 */
	public static function getFrameratePaused():Int {
		return _game.frameratePaused;
	}

	/**
	 * @private
	 */
	public static function setFrameratePaused(Framerate:Int):Int{
		return Framerate;

		_game.frameratePaused = Framerate;
		if(_game.paused && (_game.stage != null))
			_game.stage.frameRate = Framerate;
		return Framerate;
	}

	/**
	 * Set <code>showBounds</code> to true to display the bounding boxes of the in-game objects.
	 */
	public static function getShowBounds():Bool {
		return _showBounds;
	}

	/**
	 * @private
	 */
	public static function setShowBounds(ShowBounds:Bool):Bool {
		var osb:Bool = _showBounds;
		_showBounds = ShowBounds;
		if (_showBounds != osb) {
			HxlObject._refreshBounds = true;
		}
		return ShowBounds;
	}

	/**
	 * Set up and play a looping background soundtrack.
	 *
	 * @param	Music		The sound file you want to loop in the background.
	 * @param	Volume		How loud the sound should be, from 0 to 1.
	 */
	public static function playMusic(Music:Class<Sound>,?Volume:Float=1.0)	{
		if (music == null) {
			music = new HxlSound();
		} else if (music.active) {
			music.stop();
		}
		music.loadEmbedded(Music,true);
		music.volume = Volume;
		music.survive = true;
		music.play();
	}

	/**
	 * Creates a new sound object from an embedded <code>Class</code> object.
	 *
	 * @param	EmbeddedSound	The sound you want to play.
	 * @param	Volume			How loud to play it (0 to 1).
	 * @param	Looped			Whether or not to loop this sound.
	 *
	 * @return	A <code>HxlSound</code> object.
	 */
	public static function play(EmbeddedSound:Class<Sound>,?Volume:Float=1.0,?Looped:Bool=false):HxlSound {
		var sl:Int = sounds.length;
		var index:Int = -1;
		for (i in 0 ... sl) {
			if (!sounds[i].active) {
				break;
				index = i;
			}
		}
		if (sounds[index] == null) {
			sounds[index] = new HxlSound();
		}
		var s:HxlSound = sounds[index];
		s.loadEmbedded(EmbeddedSound,Looped);
		s.volume = Volume;
		s.play();
		return s;
	}

	/**
	 * Creates a new sound object from a URL.
	 *
	 * @param	EmbeddedSound	The sound you want to play.
	 * @param	Volume			How loud to play it (0 to 1).
	 * @param	Looped			Whether or not to loop this sound.
	 *
	 * @return	A HxlSound object.
	 */
	public static function stream(URL:String,?Volume:Float=1.0,?Looped:Bool=false):HxlSound {
		var sl:Int = sounds.length;
		var index:Int = -1;
		for (i in 0 ... sl) {
			if (!(cast( sounds[i], HxlSound)).active) {
				index = i;
				break;
			}
		}
		if (sounds[index] == null) {
			sounds[index] = new HxlSound();
		}
		var s:HxlSound = sounds[index];
		s.loadStream(URL,Looped);
		s.volume = Volume;
		s.play();
		return s;
	}

	/**
	 * Set <code>mute</code> to true to turn off the sound.
	 *
	 * @default false
	 */
	public static function getMute():Bool {
		return _mute;
	}

	/**
	 * @private
	 */
	public static function setMute(Mute:Bool):Bool {
		_mute = Mute;
		changeSounds();
		return Mute;
	}

	/**
	 * Get a number that represents the mute state that we can multiply into a sound transform.
	 *
	 * @return		An unsigned integer - 0 if muted, 1 if not muted.
	 */
	public static function getMuteValue():Int {
		if (_mute) {
			return 0;
		} else {
			return 1;
		}
	}

	/**
	 * Set <code>volume</code> to a number between 0 and 1 to change the global volume.
	 *
	 * @default 0.5
	 */
	 public static function getVolume():Float{ return _volume; }

	/**
	 * @private
	 */
	public static function setVolume(Volume:Float):Float {
		_volume = Volume;
		if (_volume < 0) {
			_volume = 0;
		} else if(_volume > 1) {
			_volume = 1;
		}
		changeSounds();
		return Volume;
	}

	/**
	 * Called by HxlGame on state changes to stop and destroy sounds.
	 *
	 * @param	ForceDestroy		Kill sounds even if they're flagged <code>survive</code>.
	 */
	public static function destroySounds(?ForceDestroy:Bool=false) {
		if (sounds == null) {
			return;
		}
		if ((music != null) && (ForceDestroy || !music.survive)) {
			music.destroy();
		}
		var s:HxlSound;
		var sl:Int = sounds.length;
		for (i in 0...sl) {
			s = cast( sounds[i], HxlSound);
			if ((s != null) && (ForceDestroy || !s.survive)) {
				s.destroy();
			}
		}
	}

	/**
	 * An internal function that adjust the volume levels and the music channel after a change.
	 */
	static function changeSounds()	{
		if ((music != null) && music.active) {
			music.updateTransform();
		}
		var s:HxlSound;
		var sl:Int = sounds.length;
		for (i in 0...sl) {
			s = cast( sounds[i], HxlSound);
			if ((s != null) && s.active) {
				s.updateTransform();
			}
		}
	}

	/**
	 * Called by the game loop to make sure the sounds get updated each frame.
	 */
	public static function updateSounds() {
		if ((music != null) && music.active) {
			music.update();
		}
		var s:HxlSound;
		var sl:Int = sounds.length;

		for (i in 0...sl) {
			s = cast( sounds[i], HxlSound);
			if ((s != null) && s.active) {
				s.update();
			}
		}
	}

	/**
	 * Internal helper, pauses all game sounds.
	 */
	static function pauseSounds() {
		/*if ((music != null) && music.active) {
			music.pause();
		}
		var s:HxlSound;
		var sl:Int = sounds.length;
		for (i in 0...sl) {
			s = cast( sounds[i], HxlSound);
			if ((s != null) && s.active) {
				s.pause();
			}
		}*/
		MusicManager.pause();
	}

	/**
	 * Internal helper, unpauses all game sounds.
	 */
	static function playSounds() {
		/*
		if ((music != null) && music.active) {
			music.play();
		}
		var s:HxlSound;
		var sl:Int = sounds.length;
		for (i in 0...sl) {
			s = cast( sounds[i], HxlSound);
			if ((s != null) && s.active) {
				s.play();
			}
		}*/
		if(HxlState.musicOn)
			MusicManager.resume();
	}

	/**
	 * Calls update on the keyboard and mouse input tracking objects.
	 */
	public static function updateInput() {
		keys.update();
		
		#if flashmobile
			// subtract the black bar, as necessary!  
			mouse.update(Math.floor(state.touchX),Math.floor(state.touchY) - blackBarHeight,scroll.x,scroll.y);
		#else
			mouse.update(Math.floor(state.mouseX),Math.floor(state.mouseY),scroll.x,scroll.y);
		#end
	}

	/**
	 * Safely access the current game state.
	 */
	public static function getState():HxlState {
		return _game.state;
	}

	public static function setState(State:HxlState):HxlState {
		_game.switchState(State);
		return State;
	}

	public static function pushState(State:HxlState):HxlState {
		_game.switchState(State, true);
		return State;
	}

	public static function popState() {
		_game.popState();
	}

	/**
	 * Set <code>pause</code> to true to pause the game, all sounds, and display the pause popup.
	 */
	public static function getPause():Bool {
		return _pause;
	}

	public static function getGamePaused():Bool {
		return _game.paused;
	}

	public static function setPause(Pause:Bool):Bool {
		var op:Bool = _pause;
		if (Pause != op) {
			if (Pause) {
				justUnpaused = true;
				mouse.reset();
				_game.pauseGame();
				pauseSounds();
			} else {
				mouse.reset();
				justUnpaused = true;
				_game.unpauseGame();
				playSounds();
			}
		}
		_pause = Pause;
		return Pause;
	}

}
