package
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	import flash.system.LoaderContext;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	[Frame(factoryClass="Preloader")]
	
	public class Main extends Sprite
	{
		
		[Embed(source="../../bin/cq.swf",mimeType="application/octet-stream")]
		var Game:Class;
		
		public function Main():void
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			// entry point		
			var mLoader:Loader = new Loader();
			var ctx:LoaderContext = new LoaderContext();
			ctx.allowCodeImport = true;
			mLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
			mLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgressHandler);
			mLoader.loadBytes(new Game(), ctx);
		}
		
		private function onCompleteHandler(loadEvent:Event):void
		{
			var cnt:DisplayObject = loadEvent.currentTarget.content;
			addChild(cnt);
		}
		
		private function onProgressHandler(mProgress:ProgressEvent):void
		{
			// might need this?
			var percent:Number = mProgress.bytesLoaded / mProgress.bytesTotal;
		}
		
		// code from oopla
		function loadOoplaLogo()
		{
			var mLoader:Loader = new Loader();
			var logoUrl:String;
			
			if (ExternalInterface.available)
				logoUrl = ExternalInterface.call("getLogoUrl") || "http://oopla.com/assets/ooplaLogo.swf";
			else
				logoUrl = "http://oopla.com/assets/ooplaLogo.swf";
			
			var mRequest:URLRequest = new URLRequest(logoUrl);
			mLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandlerOopla);
			mLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			mLoader.load(mRequest);
		
		}
		
		function onCompleteHandlerOopla(loadEvent:Event)
		{
			addChild(loadEvent.currentTarget.content);
		}
		
		function onError(errEvent:Event)
		{
			// Custom error handling code goes here, if needed
		}
	
	}

}