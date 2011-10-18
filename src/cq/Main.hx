package cq;

import cq.states.GameOverState;
import cq.states.GameState;
import cq.states.MainMenuState;
import cq.CqResources;
import cq.ui.CqPause;
import data.Resources;
import data.StatsFile;
import data.StatsFileEmbed;
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

import com.remixtechnology.SWFProfiler;
import playtomic.Playtomic;

#if flash
	import flash.system.Capabilities;
	import flash.ui.ContextMenu;
#end

class Main extends HxlGame {
	public static function main() {
		Lib.current.addChild(new Main());
	}

	static var kongWidth = 88;
	static var kongHeight = 31;
	static var kongX = 0;
	static var kongY = 480 -kongHeight -1;
	function checkOnLogoOrAd(e : Event) {
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
		
		Configuration.app_width = 640;//Lib.current.stage.stageWidth;
		Configuration.app_height = 480;//Lib.current.stage.stageHeight;
		
		//This is so cool
		//The very good news is that changing level does not change much
		//Just opening doors seems to add 1 or 2 megs..
		if (Configuration.debug) {
			SWFProfiler.init( this );
		}

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
		StatsFile.loadFile( "classes.txt" );
		StatsFile.loadFile( "descriptions.txt" );
		StatsFile.loadFile( "items.txt" );
		StatsFile.loadFile( "mobs.txt" );
		StatsFile.loadFile( "potions.txt" );
		StatsFile.loadFile( "spells.txt" );
		StatsFile.loadFile( "spellDamage.txt" );
		
		Configuration.tileSize = 16;
		Configuration.zoom = 2.0;
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
	}
}
