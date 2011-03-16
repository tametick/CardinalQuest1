package detribus;

import haxel.HxlSprite;
import haxel.HxlPoint;
import haxel.HxlGraphics;
import haxel.HxlSound;
import detribus.Resources;

import com.eclecticdesignstudio.motion.Actuate;

class Actor extends GameObject
{	
	public var visionRadius:Float;
	public var moveSpeed:Float;	
	public var name:String;
	
	public var armor:Int;
	public var dodge:Int;
	public var damage:Int;
	
	public function new(world:World, X:Float, Y:Float, Armor:Int, Dodge:Int, Damage:Int) 
	{
		super(world, X, Y);

		visionRadius = 6.2;
		moveSpeed = 0.25;
		armor = Armor;
		dodge = Dodge;
		damage = Damage;
		zIndex = 2;
	}
	
	public function moveTo(X:Float, Y:Float):Void {
		var self = this;
		Actuate.tween(this, this.moveSpeed, { x: X, y: Y } ).onComplete(moveStop);
	}
	
	public function moveStop():Void {
	}
	
	public override function toString():String {
		return Type.typeof(this) +" at "+super.toString();
	}
	
	public function gainXP(xp:Int) {
	}
	
	
	public function takeHit(src:Actor, damage:Int) {
		
		if (Math.random() <  dodge / 10.0) {
			trace(this + " dodged attack");
			var sfx = new HxlSound();
			sfx.loadEmbedded(Dodge, false);
			sfx.play();
			return;
		}
		
		_hp -= Math.floor(damage * (1 - armor / 10.0));
		if (_hp <= 0) {
			die(src);
		}
	}
	
	public function die(killer:Actor) {	}
	
}
