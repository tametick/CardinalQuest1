/**
 * @author Joshua Granick
 */


package com.eclecticdesignstudio.motion.actuators;


class PropertyDetails {
	
	
	public var target:Dynamic;
	public var propertyName:String;
	public var start:Float;
	public var change:Float;
	//public var current:Float;	
	
	public function new (target:Dynamic, propertyName:String, start:Float, change:Float) {
		
		this.target = target;
		this.propertyName = propertyName;
		this.start = start;
		//this.current = start;
		this.change = change;
		
	}
	
	
}
