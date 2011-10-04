package com.eclecticdesignstudio.motion.actuators;


/**
 * @author Joshua Granick
 * @version 1.2
 */
class MethodActuator extends SimpleActuator {
	
	
	private var tweenProperties:Dynamic;
	
	
	public function new (target:Dynamic, duration:Float, properties:Dynamic) {
		
		tweenProperties = { };
		
		super (target, duration, properties);
		
		if (!properties.start) {
			
			properties.start = new Array <Dynamic> ();
			
		}
		
		if (!properties.end) {
			
			properties.end = properties.start;
			
		}
		
	}
	
	
	public override function apply ():Void {
		
		Reflect.callMethod (null, target, properties.end);
		
	}
	
	
	private override function initialize ():Void {
		
		var details:PropertyDetails;
		var propertyName:String;
		var start:Dynamic;
		
		for (i in 0...properties.start.length) {
			
			propertyName = "param" + i;
			start = properties.start[i];
			
			Reflect.setField (tweenProperties, propertyName, start);
			
			if (Std.is (start, Float) || Std.is (start, Int)) {
				
				details = new PropertyDetails (tweenProperties, propertyName, start, properties.end[i] - start);
				propertyDetails.push (details);
				
			}
			
		}
		
		detailsLength = propertyDetails.length;
		initialized = true;
		
	}
	
	
	private override function update (currentTime:Float):Void {
		
		super.update (currentTime);
		
		var parameters:Array <Dynamic> = new Array <Dynamic> ();
		
		for (i in 0...properties.start.length) {
			
			parameters.push (Reflect.field (tweenProperties, "param" + i));
			
		}
		
		Reflect.callMethod (null, target, parameters);
		
	}
	
	
}