/**
 * @author Joshua Granick
 * @version 1.2
 */


package com.eclecticdesignstudio.motion.actuators;


import com.eclecticdesignstudio.motion.easing.IEasing;
import com.eclecticdesignstudio.motion.Actuate;
import flash.events.Event;


class GenericActuator {
	
	
	private var duration:Float;
	private var id:String;
	private var properties:Dynamic;
	private var target:Dynamic;
	
	private var _autoVisible:Bool;
	private var _delay:Float;
	private var _ease:IEasing;
	private var _onUpdate:Dynamic -> Dynamic;
	private var _onUpdateParams:Dynamic;
	private var _onComplete:Dynamic;
	private var _onCompleteParams:Array <Dynamic>;
	private var _reflect:Bool;
	private var _repeat:Int;
	private var _reverse:Bool;
	private var _smartRotation:Bool;
	private var _snapping:Bool;
	private var special:Bool;
	
	
	public function new (target:Dynamic, duration:Float, properties:Dynamic) {
		
		_autoVisible = true;
		_delay = 0;
		_reflect = false;
		_repeat = 0;
		_reverse = false;
		_smartRotation = false;
		_snapping = false;
		special = false;
		
		this.target = target;
		this.properties = properties;
		this.duration = duration;
		
		_ease = Actuate.defaultEase;
		
	}
	
	
	private function apply ():Void {
		
		for (i in Reflect.fields (properties)) {
			
			Reflect.setField (target, i, Reflect.field (properties, i));
			
		}
		
	}
	
	
	/**
	 * Flash performs faster when objects are set to visible = false rather than only alpha = 0. autoVisible toggles automatically based on alpha values
	 * @param	value		Whether autoVisible should be enabled (Default is true)
	 * @return		The current actuator instance
	 */
	public function autoVisible (value:Bool = true):GenericActuator {
		
		_autoVisible = value;
		
		return this;
		
	}
	
	
	private function change ():Void {
		
		if (_onUpdate != null) {
			
			Reflect.callMethod (_onUpdate, _onUpdate, _onUpdateParams);
			
		}
		
	}
	
	
	private function complete (? sendEvent:Bool = true):Void {
		
		if (sendEvent) {
			
			change ();
			
			if (_onComplete != null) {
				
				Reflect.callMethod (_onComplete, _onComplete, _onCompleteParams);
				
			}
			
		}
		
		var internal:Actuate.ActuateInternal = Actuate;
		
		internal.unload (this);
		
	}
	
	
	/**
	 * Increases the delay before a tween is executed
	 * @param	duration		The amount of seconds to delay
	 * @return		The current actuator instance
	 */
	public function delay (duration:Float):GenericActuator {
		
		_delay = duration;
		
		return this;
		
	}
	
	
	/**
	 * Sets the easing which is used when running the tween
	 * @param	easing		An easing equation, like Elastic.easeIn or Quad.easeOut
	 * @return		The current actuator instance
	 */
	public function ease (easing:IEasing):GenericActuator {
		
		_ease = easing;
		
		return this;
		
	}
	
	
	private function move ():Void {
		
		
		
	}
	
	
	/**
	 * Defines a function which will be called when the tween updates
	 * @param	handler		The function you would like to be called
	 * @param	parameters		Parameters you would like to pass to the handler function when it is called
	 * @return		The current actuator instance
	 */
	public function onUpdate (handler:Dynamic, parameters:Array <Dynamic> = null):GenericActuator {
		
		_onUpdate = handler;
		_onUpdateParams = parameters;
		
		return this;
		
	}
	
	
	/**
	 * Defines a function which will be called when the tween finishes
	 * @param	handler		The function you would like to be called
	 * @param	parameters		Parameters you would like to pass to the handler function when it is called
	 * @return		The current actuator instance
	 */
	public function onComplete (handler:Dynamic, parameters:Array <Dynamic> = null):GenericActuator {
		
		_onComplete = handler;
		_onCompleteParams = parameters;
		
		if (duration == 0) {
			
			complete ();
			
		}
		
		return this;
		
	}
	
	
	private function pause ():Void {
		
		
		
	}
	
	
	/**
	 * Automatically changes the reverse value when the tween repeats. Repeat must be enabled for this to have any effect
	 * @param	value		Whether reflect should be enabled (Default is true)
	 * @return		The current actuator instance
	 */
	public function reflect (value:Bool = true):GenericActuator {
		
		_reflect = true;
		special = true;
		
		return this;
		
	}
	
	
	/**
	 * Repeats the tween after it finishes
	 * @param	times		The number of times you would like the tween to repeat, or -1 if you would like to repeat the tween indefinitely (Default is -1)
	 * @return		The current actuator instance
	 */
	public function repeat (times:Int = -1):GenericActuator {
		
		_repeat = times;
		
		return this;
		
	}
	
	
	private function resume ():Void {
		
		
		
	}
	
	
	/**
	 * Sets if the tween should be handled in reverse
	 * @param	value		Whether the tween should be reversed (Default is true)
	 * @return		The current actuator instance
	 */
	public function reverse (value:Bool = true):GenericActuator {
		
		_reverse = value;
		special = true;
		
		return this;
		
	}
	
	
	/**
	 * Enabling smartRotation can prevent undesired results when tweening rotation values
	 * @param	value		Whether smart rotation should be enabled (Default is true)
	 * @return		The current actuator instance
	 */
	public function smartRotation (value:Bool = true):GenericActuator {
		
		_smartRotation = value;
		special = true;
		
		return this;
		
	}
	
	
	/**
	 * Snapping causes tween values to be rounded automatically
	 * @param	value		Whether tween values should be rounded (Default is true)
	 * @return		The current actuator instance
	 */
	public function snapping (value:Bool = true):GenericActuator {
		
		_snapping = value;
		special = true;
		
		return this;
		
	}
	
	
	private function stop (properties:Dynamic, complete:Bool, sendEvent:Bool):Void {
		
		
		
	}
	
	
}


typedef MotionInternal =
{
	private var duration:Float;
	private var properties:Dynamic;
	private var target:Dynamic;
	private function apply ():Void;
	private function move ():Void;
	private function pause ():Void;
	private function resume ():Void;
	private function stop (properties:Dynamic, complete:Bool, sendEvent:Bool):Void;
}