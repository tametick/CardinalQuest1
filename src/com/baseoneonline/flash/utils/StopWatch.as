package com.baseoneonline.flash.utils
{
	import flash.display.Sprite;
	import flash.utils.getTimer;

	public class StopWatch extends Sprite
	{
		
		private var startTime:int;
		private var tf:ShadowedTextField;
		private var preText:String;
		
		public function StopWatch(preText:String='')
		{
			this.preText = preText;
			
			tf = new ShadowedTextField();
			addChild(tf);
		}
		
		/**
		 *	Set the starttime (Start counting) 
		 */
		public function start():void
		{
			startTime = getTimer();
		}
		
		/**
		 * 	Return the elapsed time since <code>start()</code> was called.
		 */
		public function read():int
		{
			return getTimer()-startTime;
		}
		
		/**
		 * 	Read the elapsed time,
		 * 	and display it in the textfield.
		 */
		public function display():void
		{
			var t:int = read();
			tf.setText(preText+" "+t+" ms.");
		}
		
		
		
	}
}