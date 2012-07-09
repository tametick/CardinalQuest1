package 
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.utils.getDefinitionByName;
	
	public class Preloader extends MovieClip 
	{
		[Embed(source = "loading.jpg")] var bg:Class;
		
		private var background:Bitmap;
		private var outline:Sprite;
		private var progressBar:Sprite;
		
		public function Preloader() 
		{
			if (stage) {
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
			}
			addEventListener(Event.ENTER_FRAME, checkFrame);
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
			loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioError);
			
			
			background = new bg();
			addChild(background);
			
			var color = 0xc4ab55;
			var x = 30;
			var height = 20;
			var y = 410;
			var width = getWidth() - x * 2;
			
			var padding = 3;
			
			outline = new Sprite ();
			outline.graphics.lineStyle (1, color, 0.15, true);
			outline.graphics.drawRoundRect (0, 0, width, height, padding * 2, padding * 2);
			outline.x = x;
			outline.y = y;
			addChild (outline);
			
			progressBar = new Sprite ();
			progressBar.graphics.beginFill (color, 0.35);
			progressBar.graphics.drawRect (0, 0, width - padding * 2, height - padding * 2);
			progressBar.x = x + padding;
			progressBar.y = y + padding;
			progressBar.scaleX = 0;
			addChild (progressBar);
			
		}
		
		private function getHeight():int
		{
			return 480;
		}
		private function getWidth():int
		{
			return 640;
		}
		
		private function ioError(e:IOErrorEvent):void 
		{
			trace(e.text);
		}
		
		private function progress(e:ProgressEvent):void 
		{
			var percentLoaded = e.bytesLoaded / e.bytesTotal;
		
			if (percentLoaded > 1)
			{
				percentLoaded == 1;
			}
			
			progressBar.scaleX = percentLoaded;
		}
		
		private function checkFrame(e:Event):void 
		{
			if (currentFrame == totalFrames) 
			{
				stop();
				loadingFinished();
			}
		}
		
		private function loadingFinished():void 
		{
			removeEventListener(Event.ENTER_FRAME, checkFrame);
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
			
			// TODO hide loader
			
			startup();
		}
		
		private function startup():void 
		{
			var mainClass:Class = getDefinitionByName("Main") as Class;
			addChild(new mainClass() as DisplayObject);
		}
		
	}
	
}