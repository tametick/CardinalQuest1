package haxel;

import cq.states.GameState;
import data.Configuration;
import data.MusicManager;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filters.BlurFilter;
import flash.geom.Point;
import flash.system.Capabilities;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.media.Sound;
import flash.Lib;

import haxel.HxlConsole;
import haxel.HxlPause;
import haxel.HxlGraphics;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.actuators.SimpleActuator;


#if flash
import flash.text.AntiAliasType;
import flash.text.GridFitType;
import flash.ui.Mouse;
import flash.utils.Timer;
import flash.display.StageDisplayState;
#end

class HxlGameBMPData extends HxlGraphicsBMPData {
	public function new(width : Int, height : Int, transparent : Bool = true, fillColor : UInt = 0xFFFFFFFF) {
		super(width, height, transparent, fillColor);
	}
}
class HxlGame extends Sprite {
	/**
	 * Sets 0, -, and + to control the global volume and P to pause.
	 * @default true
	 */
	public var useDefaultHotKeys:Bool;
	/**
	 * Displayed whenever the game is paused.
	 * Override with your own <code>HxlLayer</code> for hot custom pause action!
	 * Defaults to <code>data.HxlPause</code>.
	 */
	public var pause:HxlGroup;

	// initialization stuff
	var _created:Bool;
	var _iState:Class<HxlState>;

	// game timer stuff
	public var framerate:Int;
	public var frameratePaused:Int;
	var _elapsed:Float;
	var _total:Int;

	// basic display stuff
	public var state:HxlState;
	var _screen:Sprite;
	var _zoom:Int;
	var _gameXOffset:Int;
	var _gameYOffset:Int;
	var _frame:Class<Bitmap>;
	var _zeroPoint:Point;
	var stateStack:Array<HxlState>;

	// basic update stuff
	public var paused:Bool;
	var _autoPause:Bool;

	// misc objects and helpers
	public var console:HxlConsole;

	//Pause screen, sound tray, support panel, dev console, and special effects objects
	var _soundTray:Sprite;
	var _soundTrayTimer:Float;
	var _soundTrayBars:Array<Bitmap>;
	var _defaultFont:String;

	public function new(GameSizeX:Int, GameSizeY:Int, InitialState:Class<HxlState>, ?Zoom:Int=1, ?DefaultFont:String="system") {
		super();
		_zoom = Zoom;
		HxlState.bgColor = 0xff000000;
		HxlGraphics.setGameData(this, GameSizeX, GameSizeY, Zoom);
		HxlTimer.setGameData(this);
		_defaultFont = DefaultFont;
		HxlGraphics._defaultFont = DefaultFont;
		_elapsed = 0;
		_total = 0;
		pause = new HxlPause();
		state = null;
		_iState = InitialState;
		_zeroPoint = new Point();
		stateStack = new Array();

		useDefaultHotKeys = true;

		_frame = null;
		_gameXOffset = 0;
		_gameYOffset = 0;
		paused = false;
		_autoPause = true;
		_created = false;
		
		lastTurnTime = 0;

		// adding to this, not to stage
		addEventListener(Event.ENTER_FRAME, create, false, 0, true);
	}

	/**
	 * Makes the little volume tray slide out.
	 *
	 * @param	Silent	Whether or not it should beep.
	 */
	public function showSoundTray(?Silent:Bool=false) {
		if (!Silent) {
			//HxlGraphics.play(SndBeep);
		}
		_soundTrayTimer = 1;
		_soundTray.y = _gameYOffset*_zoom;
		_soundTray.visible = true;
		var gv:Int = Math.round(HxlGraphics.volume*10);
		if (HxlGraphics.mute) {
			gv = 0;
		}
		for (i in 0..._soundTrayBars.length) {
			if (i < gv) _soundTrayBars[i].alpha = 1;
			else _soundTrayBars[i].alpha = 0.5;
		}
	}

	/**
	 * Switch from one <code>HxlState</code> to another.
	 * Usually called from <code>HxlGraphics</code>.
	 *
	 * @param	State		The class name of the state you want (e.g. PlayState)
	 */
	public function switchState(State:HxlState, ?Push:Bool = false) {
		var oldState = state;

		// Swap the new state for the old one and dispose of it
		_screen.addChild(State);
		state = State;
		if (oldState != null) {
			if ( Push ) {
				// destroy old unstacked state
				if (!HxlUtil.contains(stateStack.iterator(),oldState)) {
					oldState.destroy();
					_screen.removeChild(oldState);
				}

				State.stackId = stateStack.length;
				if(stateStack.length>0)
					stateStack[stateStack.length-1].isStacked = true;
				stateStack.push(State);
				HxlGraphics.unfollow();
				HxlGraphics.resetInput();
				HxlGraphics.destroySounds();
				HxlGraphics.flash.stop();
				HxlGraphics.fade.stop();
				HxlGraphics.quake.stop();
				_screen.x = 0;
				_screen.y = 0;
			} else {
				// If we aren't pushing a state to the stack, we should clear out any previously stacked states

				if (stateStack.length > 0) {
					var i:HxlState;
					while ( stateStack.length > 0 ) {
						i = stateStack.pop();
						if ( i != null ) {
							i.destroy();
							_screen.removeChild(i);
						}
						i  = null;
					}
				}

				System.gc();
				System.gc();

				if(!oldState.destroyed){
					// destroy old state that wasn't in the state stack
					oldState.destroy();
					_screen.removeChild(oldState);
				}


				HxlGraphics.unfollow();
				HxlGraphics.resetInput();
				HxlGraphics.destroySounds();
				HxlGraphics.flash.stop();
				HxlGraphics.fade.stop();
				HxlGraphics.quake.stop();
				_screen.x = 0;
				_screen.y = 0;
				State.stackId = 0;
				stateStack.push(State);
			}
		} else {
			HxlGraphics.unfollow();
			HxlGraphics.resetInput();
			HxlGraphics.destroySounds();
			HxlGraphics.flash.stop();
			HxlGraphics.fade.stop();
			HxlGraphics.quake.stop();
			_screen.x = 0;
			_screen.y = 0;
			State.stackId = 0;
			stateStack.push(State);
		}
		state.scaleX = state.scaleY = _zoom;
		
		// Finally, create the new state

		#if flashmobile
		HxlGraphics.stage.quality = HIGH;
		#end
		
		disableEsc();
		
		state.create();
		state.isStacked = false;

		oldState = null;
	}

	public function popState() {
		if ( stateStack.length < 1 )
			return;

		var State:HxlState = stateStack.pop();
		State.destroy();
		_screen.removeChild(State);

		State = stateStack[stateStack.length-1];
		HxlGraphics.unfollow();
		HxlGraphics.resetInput();
		HxlGraphics.destroySounds();
		HxlGraphics.flash.stop();
		HxlGraphics.fade.stop();
		HxlGraphics.quake.stop();
		_screen.x = 0;
		_screen.y = 0;
		state = State;
		if(state!=null)
			state.isStacked = false;

		State = null;
		System.gc();
		System.gc();
	}

	function onKeyUp(event:KeyboardEvent) {
		// todo: use HxlKeyboard constants instead of keycodes
		if (((event.keyCode == 192) || (event.keyCode == 220)) && Configuration.debug) {
			console.toggle();
			return;
		}
		if (useDefaultHotKeys) {
			var c:Int = event.keyCode;
			var code:String = String.fromCharCode(event.charCode);
			switch(c) {
				case 48:
				case 96:
					HxlGraphics.mute = !HxlGraphics.mute;
					showSoundTray();
					return;
				case 109:
				case 189:
					HxlGraphics.mute = false;
					HxlGraphics.volume = HxlGraphics.volume - 0.1;
					showSoundTray();
					return;
				case 107:
				case 187:
					HxlGraphics.mute = false;
					HxlGraphics.volume = HxlGraphics.volume + 0.1;
					showSoundTray();
					return;
				case 80:
					//HxlGraphics.pause = !HxlGraphics.pause;
				default:
			}
		}
		HxlGraphics.keys.handleKeyUp(event);

	}

	/**
	 * Internal function to help with basic pause game functionality.
	 */
	public function unpauseGame() {

		flash.ui.Mouse.hide();

		HxlGraphics.resetInput();
		paused = false;
		stage.frameRate = framerate;
		Actuate.resumeAll();
	}

	/**a
	 * Internal function to help with basic pause game functionality.
	 */
	public function pauseGame() {
		if ((x != 0) || (y != 0)) {
			x = 0;
			y = 0;
		}

		flash.ui.Mouse.show();

		paused = true;
		stage.frameRate = frameratePaused;
		Actuate.pauseAll();
	}

	/**
	 * Internal event handler for input and focus.
	 */
	function onFocus(?event:Event=null) {
		if ( _autoPause /*&& HxlGraphics.pause*/) {
			//HxlGraphics.pause = false;
			if(HxlState.musicOn)
				MusicManager.resume();
		}
	}

	/**
	 * Internal event handler for input and focus.
	 */
	function onFocusLost(?event:Event=null) {
		if ( _autoPause ) {
			//HxlGraphics.pause = true;
			MusicManager.pause();
			if (Std.is(HxlGraphics.state, GameState)) {
				cast(HxlGraphics.state, GameState).isPlayerActing = false;
				HxlGraphics.keys.reset();
			}
		}
	}

	public function create(event:Event) : Void {
		if ( stage == null ) {
			return;
		}
		var i:Int;
		var soundPrefs:HxlSave;

		//Set up the view window and double buffering
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		stage.frameRate = framerate;

		var tmp:Bitmap;
		
		_screen = new Sprite();
		addChild(_screen);

		#if !useHxlMobileDisplay
		tmp = new Bitmap(new HxlGameBMPData(HxlGraphics.width, HxlGraphics.height, false, HxlState.bgColor));
		tmp.x = 0;
		tmp.y = 0;
		tmp.scaleX = tmp.scaleY = _zoom;
		_screen.addChild(tmp);
		HxlGraphics.buffer = cast(tmp.bitmapData, HxlGameBMPData);
		tmp = null;
		#else
		// _screen.visible = false;
		HxlGraphics.buffer = new HxlMobileDisplay();
		#end

		// Initialize console
		console = new HxlConsole(0, 0, _zoom, _defaultFont);
		//console.log("console created!");
		addChild(console);

		// Initialize input event listeners
		_addEventListener(KeyboardEvent.KEY_DOWN, HxlGraphics.keys.handleKeyDown,false,0,true);
		_addEventListener(KeyboardEvent.KEY_UP, onKeyUp,false,0,true);
		_addEventListener(MouseEvent.MOUSE_DOWN, HxlGraphics.mouse.handleMouseDown,false,0,true);
		_addEventListener(MouseEvent.MOUSE_UP, HxlGraphics.mouse.handleMouseUp,false,0,true);
		_addEventListener(MouseEvent.MOUSE_OUT, HxlGraphics.mouse.handleMouseUp,false,0,true);
		_addEventListener(MouseEvent.MOUSE_OVER, HxlGraphics.mouse.handleMouseOver,false,0,true);

		//Sound Tray popup
		_soundTray = new Sprite();
		_soundTray.visible = false;
		_soundTray.scaleX = 2;
		_soundTray.scaleY = 2;
		tmp = new Bitmap(new HxlGameBMPData(80, 30, true, 0x7F000000));
		_soundTray.x = (_gameXOffset+HxlGraphics.width/2)*_zoom-(tmp.width/2)*_soundTray.scaleX;
		_soundTray.addChild(tmp);

		var text:TextField = new TextField();
		text.width = tmp.width;
		text.height = tmp.height;
		tmp = null;
		text.multiline = true;
		text.wordWrap = true;
		text.selectable = false;
		#if flash
		text.embedFonts = true;
		text.antiAliasType = AntiAliasType.NORMAL;
		text.gridFitType = GridFitType.PIXEL;
		#else
		#end
		text.defaultTextFormat = new TextFormat("system",8,0xffffff,null,null,null,null,null,TextFormatAlign.CENTER);
		_soundTray.addChild(text);
		text.text = "VOLUME";
		text.y = 16;

		var bx:Int = 10;
		var by:Int = 14;
		_soundTrayBars = new Array();
		for(i in 0...10) {
			tmp = new Bitmap(new HxlGameBMPData(4,i+1,false,0xffffff));
			tmp.x = bx;
			tmp.y = by;
			_soundTray.addChild(tmp);
			_soundTrayBars.push(tmp);
			bx += 6;
			by--;
			tmp = null;
		}
		addChild(_soundTray);

		//Initialize the pause screen
		root.addEventListener(Event.DEACTIVATE, onFocusLost,false,0,true);
		root.addEventListener(Event.ACTIVATE, onFocus, false, 0, true);
		stage.focus = null;

		//Check for saved sound preference data
		soundPrefs = new HxlSave();
		if (soundPrefs.bind("haxegame") && (soundPrefs.data.sound != null)) {
			if (soundPrefs.data.volume != null) {
				HxlGraphics.volume = soundPrefs.data.volume;
			}
			if (soundPrefs.data.mute != null) {
				HxlGraphics.mute = soundPrefs.data.mute;
			}
			//showSoundTray(true);
		}

		//All set!
		_created = true;

		var args = new Array();
		var newState = Type.createInstance(_iState, args);

		switchState(newState);

		args = null;
		newState = null;

		
		#if !useHxlMobileDisplay
		HxlState.screen.unsafeBind(HxlGraphics.buffer);
		#end

		_addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		//_addEventListener(Event.CLOSING, destroy, false, 0, true);


		// remove from this, all future event listeners should be on stage
		removeEventListener(Event.ENTER_FRAME, create);
	}

	
	private var frameTimer:HxlText;
	private var lastTurnTime:Int;
	
	static public var tookATurn:Bool;
	static public var noTurnTaking:Bool;
	
	public function update(event:Event) : Void {
		var i:Int;
		var soundPrefs:HxlSave;

		var mark:Int = Lib.getTimer();
		//Frame timing
		var ems:Int = mark - _total;
		_elapsed = ems/1000;
		console.mtrTotal.add(ems);
		_total = mark;

		HxlGraphics.elapsed = _elapsed;
		noTurnTaking = false;
		
		if (HxlGraphics.elapsed > HxlGraphics.maxElapsed) {
			if (HxlGraphics.elapsed > HxlGraphics.wayTooLong) {
				noTurnTaking = true;
				return;
			} else {
				HxlGraphics.elapsed = HxlGraphics.maxElapsed;
			}
		}
		
		var activeTurn:Bool = tookATurn;
		
		if (tookATurn) {
			lastTurnTime = ems;
			tookATurn = false;
		}
		
		HxlGraphics.elapsed *= HxlGraphics.timeScale;
		HxlTimer._total += HxlGraphics.elapsed;
		
		#if flashmobile
		HxlGraphics.stage.quality = MEDIUM;
		#end

		//Sound tray crap
		if (_soundTray != null) {
			if (_soundTrayTimer > 0) {
				_soundTrayTimer -= _elapsed;
			} else if (_soundTray.y > -_soundTray.height) {
				_soundTray.y -= _elapsed*HxlGraphics.height*2;
				if (_soundTray.y <= -_soundTray.height) {
					_soundTray.visible = false;

					//Save sound preferences
					soundPrefs = new HxlSave();
					if (soundPrefs.bind("haxegame")) {
						if (soundPrefs.data.sound == null) {
							soundPrefs.data.sound = {};
						}
						soundPrefs.data.mute = HxlGraphics.mute;
						soundPrefs.data.volume = HxlGraphics.volume;
						soundPrefs.forceSave();
					}
				}
			}
		}

		// Animate HUD elements
		if ( console.visible ) {
			console.update();
		}

		// State updating
		HxlGraphics.numUpdates = 0;
		HxlObject._refreshBounds = false;
		HxlGraphics.updateInput();
		HxlGraphics.updateSounds();

		if ( paused ) {
			pause.update();
		} else {
			// Update camera and game state
			HxlGraphics.doFollow();
			state.update();

			// Update special effects
			if ( HxlGraphics.flash.exists ) {
				HxlGraphics.flash.update();
			}
			if ( HxlGraphics.fade.exists ) {
				HxlGraphics.fade.update();
			}
			HxlGraphics.quake.update();
			_screen.x = HxlGraphics.quake.x;
			_screen.y = HxlGraphics.quake.y;
		}

		//Keep track of how long it took to update everything
		var updateMark:Int = Lib.getTimer();
		console.mtrUpdate.add(updateMark-mark);

		HxlGraphics.buffer.lock();
		state.preProcess();

		// todo
		// rough state stack rendering code, not currently working..
		if ( stateStack.length > 1 ) {
			var startState:Int = 0;
			for ( i in 0...stateStack.length ) {
				if ( stateStack[i].stackBlockRender )
					startState = i;
			}
			if ( startState != state.stackId ) {
				for ( i in startState...stateStack.length-1 ) {
					stateStack[i].render();
				}
			}
		}
				
		#if flashmobile
		HxlGraphics.stage.quality = LOW;
		#end

		state.render();

		#if debug_flashmobile
		if (frameTimer == null) frameTimer = new HxlText(0, 0, 300, "", false, null, 20, 0xffffff);
		frameTimer.scrollFactor.x = 0;
		frameTimer.scrollFactor.y = 0;
		
		var timeString = ems + "ms";
		
		if (lastTurnTime > 0) timeString = lastTurnTime + "ms (" + timeString + ")";
		
		frameTimer.setText(timeString);
		frameTimer.zIndex = 10000;
		frameTimer.render();
		#end

		if ( HxlGraphics.flash.exists ) {
			HxlGraphics.flash.render();
			activeTurn = true;
		}
		if ( HxlGraphics.fade.exists ) {
			HxlGraphics.fade.render();
			activeTurn = true;
		}

		state.postProcess();
		if ( paused ) {
			pause.render();
		}
		HxlGraphics.buffer.unlock();
		console.mtrRender.add(Lib.getTimer() - updateMark);
		
		HxlGraphics.rebakeAll = false;
	}


	var eventListeners:Array<Dynamic>;

	function _addEventListener(Type:String, Listener:Dynamic, UseCapture:Bool = false, Priority:Int = 0, UseWeakReference:Bool = true) {
		if (eventListeners == null)
			eventListeners = new Array();

		stage.addEventListener(Type, Listener, UseCapture, Priority, UseWeakReference);
		eventListeners.push( {Type: Type, Listener: Listener, UseCapture: UseCapture, Priority: Priority} );
	}

	function _removeEventListener(Type:String, Listener:Dynamic) {
		stage.removeEventListener(Type, Listener);
		for ( i in 0...eventListeners.length ) {
			var ev:Dynamic = eventListeners[i];
			if ( ev.Type == Type && ev.Listener == Listener ) {
				eventListeners.splice(i, 1);
				break;
			}
		}
	}

	function _clearEventListeners() {
		while ( eventListeners.length > 0 ) {
			var i:Dynamic = eventListeners.pop();
			stage.removeEventListener(i.Type, i.Listener);
		}
	}
	
	public static function disableEsc() {		
		#if flash
		if (Configuration.standAlone && !Configuration.mobile) {
			if ( Configuration.fullscreen ) {
				#if flash
				if (!StringTools.startsWith(Capabilities.os, "Mac")) {
					Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
					// for windows
					Lib.fscommand("trapallkeys", "true");
					Lib.current.stage.showDefaultContextMenu = false;
				}
				#end
			}
		}
		#end
	}

	public function destroy() {

		_clearEventListeners();
		HxlGraphics.buffer.dispose();
		HxlGraphics.buffer = null;
		removeChild(_soundTray);
		removeChild(_screen);
		removeChild(console);

		root.removeEventListener(Event.DEACTIVATE, onFocusLost);
		root.addEventListener(Event.ACTIVATE, onFocus);
	}
}
