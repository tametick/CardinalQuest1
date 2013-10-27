package cq;


import flash.display.Loader;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import cq.states.WinState;
import cq.states.GameOverState;
import cq.states.GameState;
import cq.states.MainMenuState;
import cq.CqResources;
import cq.ui.CqPause;
import data.Resources;
import data.StatsFile;
import data.StatsFileEmbed;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.external.ExternalInterface;
import flash.ui.Mouse;
import haxel.HxlGame;
import haxel.HxlGraphics;
import haxel.HxlState;
import haxel.HxlText;
import data.Configuration;
import data.MusicManager;
import data.Registery;
import data.SoundEffectsManager;
import data.SaveSystem;

import flash.Lib;
import flash.display.StageOrientation;
import flash.events.StageOrientationEvent;

import playtomic.Playtomic;

#if !web
import flash.desktop.NativeApplication;
#end

#if flash
	import flash.system.Capabilities;
	import flash.ui.ContextMenu;
#end

// For newgrounds...
#if newgrounds
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.text.TextFieldAutoSize;

class MoreNewgrounds extends Bitmap { public function new() { super(); } }
#end

#if oopla
import flash.net.URLRequest;
#end

class Main extends HxlGame {
#if newgrounds
	var m_newgroundsSprite : Sprite;
#end
	
	public static function main() {
#if flashmobile		
		// ios orientation stuff
		var stage = Lib.current.stage;
		var startOrientation = stage.orientation;
		if (startOrientation == StageOrientation.DEFAULT || startOrientation == StageOrientation.UPSIDE_DOWN){
			stage.setOrientation(StageOrientation.ROTATED_RIGHT);
		}
		else{
			stage.setOrientation(startOrientation);
		}
		stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGING, orientationChangeListener, false, 0, true);
		//
#end		
		Lib.current.stage.addChild(new Main());
	}
#if flashmobile		
	static function orientationChangeListener(e:StageOrientationEvent) {
		if (e.afterOrientation == StageOrientation.DEFAULT || e.afterOrientation ==  StageOrientation.UPSIDE_DOWN) {
			e.preventDefault();
		}
	}
#end
	
	static var kongWidth = 88;
	static var kongHeight = 31;
	static var kongX = 0;
	static var kongY = 480 - kongHeight - 1;
	
	function checkOnLogoOrAd(e : Event) {
		if ( Configuration.isAndKonAd )
		{
			kongWidth = 60;
			kongHeight = 56;
			kongX = 14;
			kongY = 480 - kongHeight;
		}
		
		if (mouseX > kongX && mouseX < kongX+kongWidth && mouseY > kongY && mouseY < kongY+kongHeight)
			Mouse.show();
		else
			Mouse.hide();
			
		if (HxlGraphics.state != null && Std.is(HxlGraphics.state, GameOverState)) {
			var ad = cast(HxlGraphics.state, GameOverState).kongAd;
			if (ad != null) {
				if (mouseX > ad.x && mouseX < ad.x+ad.width && mouseY > ad.y && mouseY < ad.y+ad.height)
					Mouse.show();
			}
			ad = null;
		}
		
	}
	
	public function new() {
		var _mochiads_game_id:String = "f7594e4c18588dca";
		
		// Initialise fullscreen.
		Configuration.fullscreen = Configuration.startFullscreen; 
		HxlGame.disableEsc();
		
		#if flashmobile
			Configuration.app_width = Lib.current.stage.stageWidth; //not 640
			Configuration.app_height = Lib.current.stage.stageHeight; //not 480		
		#else
			Configuration.app_width = 640;
			Configuration.app_height = 480;
		#end
		
		if ( Configuration.mobile ) {
			Lib.current.stage.addEventListener(Event.DEACTIVATE, deactivate);			
		} else {
			#if (!web)
			Lib.current.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, nothing);
			#end
		}
		
		// Initialise sound/music.
		
		var settingStore = SaveSystem.getLoadIO();
		
		HxlState.musicOn = settingStore.getSetting("musicOn", Configuration.startWithMusic, Bool);
		if ( !HxlState.musicOn ) {
			MusicManager.pause();
		}
		
		
		HxlState.sfxOn = settingStore.getSetting("sfxOn", Configuration.startWithSound, Bool);
		if ( !HxlState.sfxOn )
		{
			SoundEffectsManager.enabled = false;
		}
		
		// Load data files (if applicable).
		StatsFileEmbed.loadEmbeddedFiles();
		
		if( !Configuration.mobile && Configuration.standAlone ) {
			StatsFile.loadFile( "classes.txt" );
			StatsFile.loadFile( "classStats.txt" );
			StatsFile.loadFile( "descriptions.txt" );
			StatsFile.loadFile( "items.txt" );
			StatsFile.loadFile( "mobs.txt" );
			StatsFile.loadFile( "potions.txt" );
			StatsFile.loadFile( "spells.txt" );
			StatsFile.loadFile( "spellDamage.txt" );
			StatsFile.loadFile( "strings.txt" );
		}
		
		Configuration.tileSize = 16;
		Configuration.zoom = Lib.current.stage.stageHeight < 400 ? 2.0 : 4.0;
		
		var physical_display_width:Float = Capabilities.screenResolutionX / Capabilities.screenDPI;
		var physical_display_height:Float = Capabilities.screenResolutionY / Capabilities.screenDPI;
		Configuration.inchesPerTile = Math.min(
			(Configuration.zoomedTileSize() / Configuration.app_width) * physical_display_width,
			(Configuration.zoomedTileSize() / Configuration.app_height) * physical_display_height
		);
		
		if (Capabilities.os.toLowerCase().indexOf("ipad") >= 0) {
			// yes, this is a hack.  it's a bloody wicked hack, and there's nothing we can do about that for now
			//var blackBar:Float = .5 * ((Capabilities.screenResolutionY / Capabilities.screenResolutionX) * Configuration.app_width - Configuration.app_height);
			
			//if (blackBar > 0) {
				//HxlGraphics.blackBarHeight = Math.floor(blackBar);
			//}
			
			HxlGraphics.blackBarHeight = 20; // this is the correct figure -- don't know why Capabilities ends up reporting figures wrong
		}
		
		HxlState.bgColor = 0xFF000000;
		
		//Initialize Kongregate score API
		Registery.getKong();
		
		Playtomic.create();
		
		if (Configuration.debug)
			super(Configuration.app_width, Configuration.app_height, WinState, 1, FontDungeon.instance.fontName);
			//super(Configuration.app_width, Configuration.app_height, GameOverState, 1, FontDungeon.instance.fontName);
		else
			super(Configuration.app_width,Configuration.app_height, MainMenuState, 1, FontDungeon.instance.fontName);
		
		pause = new CqPause();
		useDefaultHotKeys = false;
		
		if (!Configuration.standAlone) {
			addEventListener(Event.ENTER_FRAME, checkOnLogoOrAd, false, 0, true);
		}
		
#if oopla
		loadOoplaLogo();
#end
		
#if newgrounds
		m_newgroundsSprite = new Sprite();
		m_newgroundsSprite.buttonMode = true;
		m_newgroundsSprite.mouseChildren = false;
		m_newgroundsSprite.addEventListener(MouseEvent.CLICK, clickOnNewgrounds, false, 0, true);
		
		var label = new TextField();
		var format = new TextFormat();
		
		format.font = "Georgia";
		format.color = 0xFFFFFF;
		format.size = 15;
		label.defaultTextFormat = format;
		label.selectable = false;
		
		label.autoSize = TextFieldAutoSize.LEFT;
		label.text = "more games:";
		
		label.textColor = 0xFFFFFF;

		m_newgroundsSprite.addChild(label);		
		
		var logo = new MoreNewgrounds();
//			logo.x = label.x+2;
		logo.y = label.y + label.height + 1;
//			logo.width -= 2;
		m_newgroundsSprite.addChild(logo);
		
		addChild(m_newgroundsSprite);
		
		m_newgroundsSprite.x = 0;
		m_newgroundsSprite.y = 480 - m_newgroundsSprite.height -1;

		label = null;
		format = null;
		logo = null;
#end
	}

#if newgrounds
	function clickOnNewgrounds(e : Event) : Void
	{
		var request : URLRequest = new URLRequest("http://newgrounds.com/");
		Lib.getURL(request);
		request = null;
	}
	
	public override function update(event:Event) : Void {
		super.update(event);
		
		removeChild(m_newgroundsSprite);
		addChild(m_newgroundsSprite);
	}
#end	

	private function deactivate(e:Event) : Void {
		// Save if we're currently in a game.
		for ( s in this.stateStack ) {
			if ( Std.is( s, GameState ) && cast(s, GameState).started ) {				
				SaveSystem.save();
				break;
			}
		}
		
		// auto-close
		#if !web
		NativeApplication.nativeApplication.exit();
		#end
	}
	
	private function nothing(e:Event) : Void {
		
	}
	
#if oopla
	// code from oopla
	function loadOoplaLogo() {
		var mLoader:Loader = new Loader();
		var logoUrl:String;
		
		if (ExternalInterface.available) {
			logoUrl = ExternalInterface.call("getLogoUrl");
			if (logoUrl == null) {
				logoUrl = "http://oopla.com/assets/ooplaLogo.swf";
			}
		} else {
			logoUrl = "http://oopla.com/assets/ooplaLogo.swf";
		}
		
		var mRequest:URLRequest = new URLRequest(logoUrl);
		mLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandlerOopla);
		mLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
		mLoader.load(mRequest);
	
	}
	
	function onCompleteHandlerOopla(loadEvent:Event) {
		var oopla = loadEvent.currentTarget.content;
		addChild(oopla);
		oopla.width *= 1 / 3;
		oopla.height *= 1 / 3;
		oopla.x = 0;
		oopla.y = 420;
	}
	
	function onError(errEvent:Event) {
		// Custom error handling code goes here, if needed
	}
#end
	
	
}
