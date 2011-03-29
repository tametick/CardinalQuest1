package haxel;

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
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.media.Sound;
import flash.Lib;
import detribus.Resources;

import haxel.HxlConsole;
import haxel.HxlPause;

import com.eclecticdesignstudio.motion.Actuate;

#if flash9
import flash.text.AntiAliasType;
import flash.text.GridFitType;
import flash.ui.Mouse;
import flash.utils.Timer;
#end

//import Game1;

class HxlGame extends Sprite {

	/*[Embed(source="data/beep.mp3")]*/ 
	/*[Embed(source="data/flixel.mp3")]*/ 
	var SndFlixel:Class<Sound>;
	var SndBeep:Class<Sound>;

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
	public var pause:HxlGroup;	// initialization stuff

	public var _created:Bool;
	public var _iState:Class<HxlState>;

	// game timer stuff
	public var _elapsed:Float;
	public var _total:Int;
	public var _framerate:Int;
	public var _frameratePaused:Int;

	// basic display stuff
	public var _screen:Sprite;
	public var _state:HxlState;
	public var _buffer:Bitmap;
	public var _zoom:Int;
	public var _gameXOffset:Int;
	public var _gameYOffset:Int;
	public var _frame:Class<Bitmap>;
	public var _zeroPoint:Point;
	public var stateStack:Array<HxlState>;

	// basic update stuff
	public var _paused:Bool;
	public var _autoPause:Bool;

	// misc objects and helpers
	public var _console:HxlConsole;

	//Pause screen, sound tray, support panel, dev console, and special effects objects
	public var _soundTray:Sprite;
	public var _soundTrayTimer:Float;
	public var _soundTrayBars:Array<Bitmap>;
	public var defaultFont:String;

	public function new(GameSizeX:Int, GameSizeY:Int, InitialState:Class<HxlState>, ?Zoom:Int=1, ?DefaultFont:String="system") {
		super();
		_zoom = Zoom;
		HxlState.bgColor = 0xff000000;
		HxlGraphics.setGameData(this, GameSizeX, GameSizeY, Zoom);
		HxlTimer.setGameData(this);
		defaultFont = DefaultFont;
		HxlGraphics.defaultFont = DefaultFont;
		_elapsed = 0;
		_total = 0;
		pause = new HxlPause();
		_state = null;
		_iState = InitialState;
		_zeroPoint = new Point();
		stateStack = new Array();

		useDefaultHotKeys = true;

		_frame = null;
		_gameXOffset = 0;
		_gameYOffset = 0;
		_paused = false;
		_autoPause = true;
		_created = false;
		addEventListener(Event.ENTER_FRAME, create);
	}

	/**
	 * Makes the little volume tray slide out.
	 * 
	 * @param	Silent	Whether or not it should beep.
	 */
	public function showSoundTray(?Silent:Bool=false):Void {
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
	public function switchState(State:HxlState, ?Push:Bool=false):Void { 
		//Basic reset stuff
		//HxlGraphics.panel.hide();
		HxlGraphics.unfollow();
		HxlGraphics.resetInput();
		HxlGraphics.destroySounds();
		HxlGraphics.flash.stop();
		HxlGraphics.fade.stop();
		HxlGraphics.quake.stop();
		_screen.x = 0;
		_screen.y = 0;
		//Swap the new state for the old one and dispose of it
		_screen.addChild(State);
		_state = State;
		if (_state != null) {
			if ( Push ) {
				State.stackId = stateStack.length;
				stateStack.push(State);
			} else {
				// If we aren't pushing a state to the stack, we should clear out any previously stacked states
				while ( stateStack.length > 0 ) {
					var i:HxlState = stateStack.pop();
					if ( i != null ) {
						i.destroy();
						_screen.removeChild(i);
					}
				}
				State.stackId = 0;
				stateStack.push(State);
				//_state.destroy(); //important that it is destroyed while still in the display list
				//_screen.swapChildren(State,_state);
				//_screen.removeChild(_state);
			}
		} else {
			State.stackId = 0;
			stateStack.push(State);
		}
		_state.scaleX = _state.scaleY = _zoom;
		//Finally, create the new state
		_state.create();

	}

	public function popState():Void {
		if ( stateStack.length <= 1 ) return;
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
		_state = State;
		//_state.scaleX = _state.scaleY = _zoom;
	}

	function onKeyUp(event:KeyboardEvent):Void {
		if ((event.keyCode == 192) || (event.keyCode == 220)) {//FOR ZE GERMANZ
			_console.toggle();
			return;
		}
		_console.log(""+event.keyCode);
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
	public function unpauseGame():Void {
		#if flash9
		//if(!HxlGraphics.panel.visible) flash.ui.Mouse.hide();
		#end
		HxlGraphics.resetInput();
		_paused = false;
		stage.frameRate = _framerate;
		Actuate.resumeAll();
	}
	
	/**
	 * Internal function to help with basic pause game functionality.
	 */
	public function pauseGame():Void {
		if ((x != 0) || (y != 0)) {
			x = 0;
			y = 0;
		}
		#if flash9
		//flash.ui.Mouse.show();
		#end
		_paused = true;
		stage.frameRate = _frameratePaused;
		Actuate.pauseAll();
	}

	/**
	 * Internal event handler for input and focus.
	 */
	function onFocus(?event:Event=null):Void {
		if ( _autoPause && HxlGraphics.pause) {
			HxlGraphics.pause = false;
		}
	}
	
	/**
	 * Internal event handler for input and focus.
	 */
	function onFocusLost(?event:Event=null):Void {
		if ( _autoPause ) {
			HxlGraphics.pause = true;
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
        stage.frameRate = _framerate;

		_screen = new Sprite();
		addChild(_screen);
		var tmp:Bitmap = new Bitmap(new BitmapData(HxlGraphics.width, HxlGraphics.height, true, HxlState.bgColor));
		tmp.x = 0;
		tmp.y = 0;
		tmp.scaleX = tmp.scaleY = _zoom;
		_screen.addChild(tmp);
		HxlGraphics.buffer = tmp.bitmapData;

		// Initialize console
		_console = new HxlConsole(0, 0, _zoom, defaultFont);
		_console.log("console created!");
		addChild(_console);

		// Initialize input event listeners
		stage.addEventListener(KeyboardEvent.KEY_DOWN, HxlGraphics.keys.handleKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, HxlGraphics.mouse.handleMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, HxlGraphics.mouse.handleMouseUp);
		stage.addEventListener(MouseEvent.MOUSE_OUT, HxlGraphics.mouse.handleMouseOut);
		stage.addEventListener(MouseEvent.MOUSE_OVER, HxlGraphics.mouse.handleMouseOver);

		//Sound Tray popup
		_soundTray = new Sprite();
		_soundTray.visible = false;
		_soundTray.scaleX = 2;
		_soundTray.scaleY = 2;
		tmp = new Bitmap(new BitmapData(80, 30, true, 0x7F000000));
		_soundTray.x = (_gameXOffset+HxlGraphics.width/2)*_zoom-(tmp.width/2)*_soundTray.scaleX;
		_soundTray.addChild(tmp);

		var text:TextField = new TextField();
		text.width = tmp.width;
		text.height = tmp.height;
		text.multiline = true;
		text.wordWrap = true;
		text.selectable = false;
		#if flash9
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
		for(i in 0...10)
		{
			tmp = new Bitmap(new BitmapData(4,i+1,false,0xffffff));
			tmp.x = bx;
			tmp.y = by;
			_soundTray.addChild(tmp);
			_soundTrayBars.push(tmp);
			bx += 6;
			by--;
		}
		addChild(_soundTray);

		//Initialize the pause screen
		stage.addEventListener(Event.DEACTIVATE, onFocusLost);
		stage.addEventListener(Event.ACTIVATE, onFocus);

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
		switchState(Type.createInstance(_iState, []));
		HxlState.screen.unsafeBind(HxlGraphics.buffer);
		removeEventListener(Event.ENTER_FRAME, create);
		addEventListener(Event.ENTER_FRAME, update);
	}

	public function update(event:Event) : Void {
		var i:Int;
		var soundPrefs:HxlSave;

		var mark:Int = Lib.getTimer();
		//Frame timing
		var ems:Int = mark - _total;
		_elapsed = ems/1000;
		_console.mtrTotal.add(ems);
		_total = mark;
		
		HxlGraphics.elapsed = _elapsed;
		if (HxlGraphics.elapsed > HxlGraphics.maxElapsed) {
			HxlGraphics.elapsed = HxlGraphics.maxElapsed;
		}
		HxlGraphics.elapsed *= HxlGraphics.timeScale;
		HxlTimer._total += HxlGraphics.elapsed;

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
		if ( _console.visible ) {
			_console.update();
		}

		// State updating
		HxlGraphics.numUpdates = 0;
		HxlObject._refreshBounds = false;
		HxlGraphics.updateInput();
		HxlGraphics.updateSounds();

		if ( _paused ) {
			pause.update();
		} else {
			// Update camera and game state
			HxlGraphics.doFollow();
			_state.update();

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
		_console.mtrUpdate.add(updateMark-mark);

		HxlGraphics.buffer.lock();
		_state.preProcess();

		// rough state stack rendering code, not currently working..
		
		if ( stateStack.length > 1 ) {
			var startState:Int = 0;
			for ( i in 0...stateStack.length ) {
				if ( stateStack[i].stackBlockRender ) startState = i;
			}
			if ( startState != _state.stackId ) {
				for ( i in startState...stateStack.length-1 ) {
					stateStack[i].render();
				}
			}
		}
		

		_state.render();
		
		if ( HxlGraphics.flash.exists ) {
			HxlGraphics.flash.render();
		}
		if ( HxlGraphics.fade.exists ) {
			HxlGraphics.fade.render();
		}

		_state.postProcess();
		if ( _paused ) {
			pause.render();
		}
		HxlGraphics.buffer.unlock();
		_console.mtrRender.add(Lib.getTimer()-updateMark);
	}

}
