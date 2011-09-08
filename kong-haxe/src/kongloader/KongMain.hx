package kongloader;

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

extern class KongLogo extends Bitmap {}
extern class KongData extends ByteArray {}
extern class GameData extends ByteArray {}

class KongMain extends Sprite
{
	var kongData : ByteArray;
	var kongLoader : Loader;
	var kongMovie : MovieClip;
	var gameData : ByteArray;
	var gameLoader : Loader;
	var isGameLoaded : Bool;
	var isKongFinished : Bool;
	var kongSprite : Sprite;
	public function new()
	{
		super();
		isGameLoaded = false;
		isKongFinished = false;
		kongData = new KongData();
		kongLoader = new Loader();
		kongLoader.loadBytes(kongData, new LoaderContext(false, new ApplicationDomain()));
		kongLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, playKongSplash, false, 0, true);
	}
	function playKongSplash(e : Event) : Void
	{
		kongLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, playKongSplash);
		kongMovie = cast(cast(kongLoader.content,MovieClip).getChildAt(0), MovieClip);
		kongMovie.addEventListener(MouseEvent.CLICK, clickOnKong, false, 0, true);
		addChild(kongLoader);
		kongLoader.x = -1*kongMovie.getBounds(kongLoader).x;
		kongLoader.y = -1*kongMovie.getBounds(kongLoader).y;
		kongLoader.width = 640;
		kongLoader.height = 480;

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
		if(kongMovie.currentFrame == kongMovie.totalFrames && !isKongFinished) 
		{
			isKongFinished = true;
			kongMovie.stop();
			kongMovie.removeEventListener(MouseEvent.CLICK, clickOnKong);
			kongMovie = null;
			removeChild(kongLoader);
			kongData.clear();
			kongData = null;
			kongLoader.unloadAndStop();
			kongLoader = null;
		}
		if(isKongFinished && isGameLoaded) 
		{
			playgame(null);
		}
	}
	function clickOnKong(e : Event) : Void
	{
		var request : URLRequest = new URLRequest("http://kongregate.com/");
		Lib.getURL(request);
		request = null;
	}
	
	function checkOnLogo(e : Event) : Void
	{
		if (mouseX > kongSprite.x && mouseX < kongSprite.x+kongSprite.width && mouseY > kongSprite.y && mouseY < kongSprite.y+kongSprite.height)
			Mouse.show();
		else
			Mouse.hide();
	}
	
	function playgame(e : Event) : Void
	{
		removeEventListener(Event.ENTER_FRAME, checkFrame);
		
		addChild(gameLoader);

		kongSprite = new Sprite();
		kongSprite.buttonMode = true;
		kongSprite.mouseChildren = false;
		kongSprite.addEventListener(MouseEvent.CLICK, clickOnKong, false, 0, true);
		
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
		
		kongSprite.addChild(label);
		
		var logo = new KongLogo();
		logo.x = label.x+2;
		logo.y = label.y + label.height + 1;
		kongSprite.addChild(logo);
		
		addChild(kongSprite);
		addEventListener(Event.ENTER_FRAME, checkOnLogo, false, 0, true);
		
		kongSprite.x = 0;
		kongSprite.y = 480 - kongSprite.height -1;

		label = null;
		format = null;
		logo = null;
	}
}
