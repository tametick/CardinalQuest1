package 
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;

	[Frame(factoryClass = "Preloader")]
	
	public class KongMain extends Sprite 
	{
		[Embed(source = '../lib/Kongregateintro.swf', mimeType = 'application/octet-stream')]
		private var kongContent:Class;
		private var kongData:ByteArray;
		private var kongLoader:Loader;
		private var kongMovie:MovieClip;
		
		[Embed(source='../../bin/cq.swf',mimeType='application/octet-stream')]
		private var gameContent:Class;
		private var gameData:ByteArray;
		private var gameLoader:Loader;

		
		private var isGameLoaded:Boolean;
		private var isKongFinished:Boolean;
		
		public function KongMain():void 
		{
			isGameLoaded = false;
			isKongFinished = false;
			
			kongData = new kongContent();
			kongLoader = new Loader();
			kongLoader.loadBytes(kongData, new LoaderContext(false, new ApplicationDomain()));
			kongLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, playKongSplash);
		}

		private function playKongSplash(e:Event = null):void 
		{
			kongLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, playKongSplash);
			
			kongMovie = MovieClip(kongLoader.content).getChildAt(0) as MovieClip;
			kongMovie.addEventListener(MouseEvent.CLICK, clickOnKong);
			
			addChild(kongLoader);
			kongLoader.height = 480;
			kongLoader.width = 640;
			addEventListener(Event.ENTER_FRAME, checkFrame);
			
			gameData = new gameContent();
			gameLoader = new Loader();
			gameLoader.loadBytes(gameData, new LoaderContext(false, new ApplicationDomain()));
			gameLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, finishedLoadingGame);
		}
		
		private function finishedLoadingGame(e:Event = null):void {
			gameLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, finishedLoadingGame);
			isGameLoaded = true;
		}
		
		private function checkFrame(e:Event):void
		{
			if (kongMovie.currentFrame == kongMovie.totalFrames && !isKongFinished)
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
			
			if (isKongFinished && isGameLoaded)
			{
				playgame();
			}
		}
		
		private function clickOnKong(e:Event):void
		{
			var request:URLRequest = new URLRequest("http://kongregate.com/");
			navigateToURL(request);
			request = null;
		}

		
		private function playgame(e:Event = null):void 
		{
			removeEventListener(Event.ENTER_FRAME, checkFrame);
			
			addChild(gameLoader);
		}
	}
}