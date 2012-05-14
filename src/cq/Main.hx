package cq;

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
import flash.ui.Mouse;
import haxel.HxlGame;
import haxel.HxlGraphics;
import haxel.HxlState;
import haxel.HxlText;
import data.Configuration;
import data.MusicManager;
import data.Registery;
import data.SoundEffectsManager;

import flash.Lib;

import playtomic.Playtomic;

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

class Main extends HxlGame {
#if newgrounds
	var m_newgroundsSprite : Sprite;
#end
	
	public static function main() {
		Lib.current.addChild(new Main());
	}

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
		HxlGame.disableEsc();
		
		#if flashmobile
			Configuration.app_width = Lib.current.stage.stageWidth; //not 640
			Configuration.app_height = Lib.current.stage.stageHeight; //not 480		
		#else
			Configuration.app_width = 640;
			Configuration.app_height = 480;
		#end
		
		// Initialise sound/music.
		HxlState.musicOn = Configuration.startWithMusic;
		if ( !HxlState.musicOn )
		{
			MusicManager.pause();
		}
		
		HxlState.sfxOn = Configuration.startWithSound;
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
		Configuration.zoom = Lib.current.stage.stageHeight < 400 ? 2.0 : 2.0;
		HxlState.bgColor = 0xFF000000;
		
		//Initialize Kongregate score API
		Registery.getKong();
		
		Playtomic.create();
		
		if (Configuration.debug)
			super(Configuration.app_width, Configuration.app_height, GameState, 1, FontDungeon.instance.fontName);
			//super(Configuration.app_width, Configuration.app_height, GameOverState, 1, FontDungeon.instance.fontName);
		else
			super(Configuration.app_width,Configuration.app_height, MainMenuState, 1, FontDungeon.instance.fontName);
		
		pause = new CqPause();
		useDefaultHotKeys = false;
		
		if (!Configuration.standAlone) {
			addEventListener(Event.ENTER_FRAME, checkOnLogoOrAd, false, 0, true);
		}
		
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
}
