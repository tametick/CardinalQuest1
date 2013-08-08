package
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.utils.getDefinitionByName;
	import flash.system.Security;
	import flash.utils.setTimeout;
	
	public class Preloader extends MovieClip
	{
		public function Preloader()
		{
			Security.allowDomain("*");
			addEventListener(Event.ENTER_FRAME, updateProgress);
			
			if (ExternalInterface.available)
				ExternalInterface.addCallback("startGame", startGame);
		}
		
		private function updateProgress(e:Event):void
		{
			// update percents loaded
			var total:Number = stage.loaderInfo.bytesTotal;
			var loaded:Number = stage.loaderInfo.bytesLoaded;
			var pct:int = loaded / total * 100;
			
			// Report to the Oopla preloader about the game file load progress
			if (ExternalInterface.available)
			{
				ExternalInterface.call("setPreloaderProgress", pct);
			}
			else
			{
				// No external interface is available (stand-alone mode?), so we need to launch
				// the game ourselves
				if (pct == 100)
					setTimeout(startGame, 1000);
			}
			
			// Everything is loaded, we can stop running this event
			if (pct == 100)
				removeEventListener(Event.ENTER_FRAME, updateProgress);
		
		}
		
		private function startGame():void
		{
			// hide loader
			var mainClass:Class = getDefinitionByName("Main") as Class;
			addChildAt(new mainClass() as DisplayObject, 0);
		}
	
	}
}
