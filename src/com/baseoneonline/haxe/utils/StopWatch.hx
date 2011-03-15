/********************
Uses haxe.Timer instead of flash9.utils.timer
originally written by BaseOneOnline: http://blog.baseoneonline.com/?p=87
modified by theRemix for use with haXe: http://remixtechnology.com/view/AStar-haXe
********************/
package com.baseoneonline.haxe.utils;

import flash.display.Sprite;
import haxe.Timer;
import flash.events.TimerEvent;
class StopWatch extends Sprite
{
	
	var startTime:Int;
	var tf:ShadowedTextField;
	var preText:String;
	var timer:Timer;
	var lastStamp:Float;
	
	public function new(preText:String='')
	{
		this.preText = preText;
		lastStamp = 0;
		tf = new ShadowedTextField();
		addChild(tf);
		
		super();
	}

	/**
	 *	Set the starttime (Start counting) 
	 */
	public function start():Void
	{
		timer = new Timer(1);
		timer.run();
	}
	
	/**
	 * 	Read the elapsed time,
	 * 	and display it in the textfield.
	 */
	public function display():Void
	{
		timer.stop();
		var t:Float = getStamp();
		tf.setText(preText+" "+t+" ms.");
	}
	public function reset():Void{
		tf.setText("No Solution Found");
		timer = null;
	}
	function getStamp():Float{
		var s:Float = Timer.stamp() - lastStamp;
		lastStamp = Timer.stamp();
		return s;
	}
	
	
}