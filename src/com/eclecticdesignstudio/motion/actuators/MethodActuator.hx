package com.eclecticdesignstudio.motion.actuators;

import com.eclecticdesignstudio.motion.easing.IEasing;
import com.eclecticdesignstudio.motion.Actuate;
import flash.events.Event;

class MethodActuator extends SimpleActuator {

	public var tweenProperties:Dynamic;

	public function new(target:Dynamic, duration:Float, properties:Dynamic) {
		super(target, duration, properties);

		if ( !properties.start ) {
			properties.start = new Array();
		}

		if ( !properties.end ) {
			properties.end = properties.start;
		}

	}

	private override function apply():Void {

	}

	private override function initialize():Void {
		var details:PropertyDetails;
		var propertyName:String;
		var start:Dynamic;
		var fields:Array<String> = Reflect.fields(properties.start);
		for ( i in 0...fields.length ) {
			start = Reflect.field(properties.start, fields[i]);
			details = new PropertyDetails(target, fields[i], start, Reflect.field(properties.end, fields[i]) - start); 
			propertyDetails.push(details);
		}

		detailsLength = propertyDetails.length;
		initialized = true;
	}

	private override function update(currentTime:Float):Void {
		//super.update(currentTime);
		if (!paused) {	
			var details:PropertyDetails;
			var easing:Float;
			var i:Int;
			var tweenPosition:Float = (currentTime - timeOffset) / duration;
			if (tweenPosition > 1) {
				tweenPosition = 1;
			}
			
			if (!initialized) {	
				initialize ();				
			}
			
			if (!special) {
				easing = _ease.calculate (tweenPosition);				
				var parameters:Dynamic = {};
				for (i in 0...detailsLength) {					
					details = propertyDetails[i];
					Reflect.setField(parameters, details.propertyName, details.start + (details.change * easing));
				}
				details = propertyDetails[0];
				Reflect.callMethod(details.target, details.target, [parameters]);
			} else {
				if (!_reverse) {	
					easing = _ease.calculate (tweenPosition);
				} else {
					easing = _ease.calculate (1 - tweenPosition);
				}
				
				var endValue:Float;
				var parameters:Dynamic = {};

				for (i in 0...detailsLength) {
					details = propertyDetails[i];					
					if (_smartRotation && (details.propertyName == "rotation" || details.propertyName == "rotationX" || details.propertyName == "rotationY" || details.propertyName == "rotationZ")) {						
						var rotation:Float = details.change % 360;						
						if (rotation > 180) {							
							rotation -= 360;							
						} else if (rotation < -180) {							
							rotation += 360;							
						}						
						endValue = details.start + rotation * easing;						
					} else {						
						endValue = details.start + (details.change * easing);						
					}					
					if (!_snapping) {						
						Reflect.setField(parameters, details.propertyName, endValue);
					} else {						
						Reflect.setField(parameters, details.propertyName, Math.round(endValue));
					}					
				}		
				details = propertyDetails[0];
				Reflect.callMethod(details.target, details.target, [parameters]);
			}
			
			if (tweenPosition == 1) {				
				if (_repeat == 0) {					
					active = false;					
					if (toggleVisible && target.alpha == 0) {						
						target.visible = false;						
					}					
					complete (true);
					return;					
				} else {					
					if (_reflect) {						
						_reverse = !_reverse;						
					}
					
					startTime = currentTime;
					timeOffset = startTime + _delay;
					
					if (_repeat > 0) {						
						_repeat --;						
					}					
				}				
			}
			
			if (sendChange) {				
				change ();				
			}			
		}
	}

}
