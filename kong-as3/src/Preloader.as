package
{
	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
	import flash.utils.*;
	
	public class Preloader extends MovieClip
	{		
		private var progressBarBG:Shape;
		private var progressBar:Shape;
		
		public function Preloader()
		{
			if (stage)
			{
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
			}
						
			addEventListener(Event.ENTER_FRAME, checkFrame);
		
			// show loader
			progressBarBG = new Shape();
			var g:Graphics = progressBarBG.graphics;
			g.lineStyle(2.0, 0xFFFFFF);
			g.drawRect(0, 0, 400, 20);
			addChild(progressBarBG);
			g = null;
			progressBarBG.x = (640 - 400)/2;
			progressBarBG.y = 400;

			progressBar = new Shape();
			g = progressBar.graphics;
			g.beginFill(0x800000);
			g.drawRect(1, 1, 400-2, 20-2);
			g = null;
			addChild(progressBar);
			progressBar.x = progressBarBG.x;
			progressBar.y = progressBarBG.y;
			progressBar.scaleX = 0;
		}
		
		private function checkFrame(e:Event):void
		{
			progressBar.scaleX = (root.loaderInfo.bytesLoaded / root.loaderInfo.bytesTotal);
			
			if (currentFrame == totalFrames)
			{
				stop();
				loadingFinished();
			}
		}
		
		private function loadingFinished():void
		{
			removeEventListener(Event.ENTER_FRAME, checkFrame);
			
			// hide loader			
			removeChild(progressBar);
			removeChild(progressBarBG);
			
			startup();
		}
		
		private function startup():void
		{
			var mainClass:Class = getDefinitionByName("KongMain") as Class;
			addChild(new mainClass() as DisplayObject);
			mainClass = null;
		}
	
	}

}