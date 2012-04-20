package kanoloader;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import flash.ui.Mouse;
import flash.utils.ByteArray;
import flash.Lib;

extern class GameData extends ByteArray {}

class KongMain extends Sprite
{
	var gameData : ByteArray;
	
	var gameLoader : Loader;
	var isGameLoaded : Bool;

	public function new()
	{
		super();
		isGameLoaded = false;

		
		addEventListener(Event.ENTER_FRAME, checkFrame, false, 0, true);
		gameData = new GameData();
		gameLoader = new Loader();
		gameLoader.loadBytes(gameData, new LoaderContext(false, new ApplicationDomain()));
		gameLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, finishedLoadingGame, false, 0, true);
	}
	
	function finishedLoadingGame(e : Event) : Void
	{
		gameLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, finishedLoadingGame);
		isGameLoaded = true;
	}
	
	function checkFrame(e : Event) : Void
	{
		if (isGameLoaded) {
			playgame(null);
		}
	}
	
	function playgame(e : Event) : Void
	{
		removeEventListener(Event.ENTER_FRAME, checkFrame);
		addChild(gameLoader);
	}
}