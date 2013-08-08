package 
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.system.LoaderContext;

	[Frame(factoryClass="Preloader")]
	public class Main extends Sprite 
	{

		[Embed(source = "../../bin/cq.swf", mimeType = "application/octet-stream")] var Game:Class;
		public function Main():void 
		{
			if (stage) 
				init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
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
	}

}