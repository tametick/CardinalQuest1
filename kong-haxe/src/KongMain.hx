import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import flash.Lib;

class KongMain extends Sprite
{
	var kongContent : Class<Dynamic>;
	var kongData : ByteArray;
	var kongLoader : Loader;
	var kongMovie : MovieClip;
	var gameContent : Class<Dynamic>;
	var gameData : ByteArray;
	var gameLoader : Loader;
	var isGameLoaded : Bool;
	var isKongFinished : Bool;
	public function new()
	{
		super();
		isGameLoaded = false;
		isKongFinished = false;
		kongData = Type.createInstance(kongContent, []);
		kongLoader = new Loader();
		kongLoader.loadBytes(kongData, new LoaderContext(false, new ApplicationDomain()));
		kongLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, playKongSplash);
	}
	function playKongSplash(e : Event) : Void
	{
		kongLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, playKongSplash);
		kongMovie = cast(cast(kongLoader.content,MovieClip).getChildAt(0) ,MovieClip);
		kongMovie.addEventListener(MouseEvent.CLICK, clickOnKong);
		addChild(kongLoader);
		kongLoader.height = 480;
		kongLoader.width = 640;
		addEventListener(Event.ENTER_FRAME, checkFrame);
		gameData = Type.createInstance(gameContent,[]);
		gameLoader = new Loader();
		gameLoader.loadBytes(gameData, new LoaderContext(false, new ApplicationDomain()));
		gameLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, finishedLoadingGame);
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
;
		if(isKongFinished && isGameLoaded) 
		{
			playgame(null);
		}
;
	}
	function clickOnKong(e : Event) : Void
	{
		var request : URLRequest = new URLRequest("http://kongregate.com/");
		Lib.getURL(request);
		request = null;
	}
	function playgame(e : Event) : Void
	{
		removeEventListener(Event.ENTER_FRAME, checkFrame);
		addChild(gameLoader);
	}
}
