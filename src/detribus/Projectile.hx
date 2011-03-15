import Resources;

import haxel.HxlSprite;
import haxel.HxlPoint;
import haxel.HxlGraphics;
import haxel.HxlUtil;
import com.eclecticdesignstudio.motion.Actuate;

class Projectile extends HxlSprite
{
	var world:World; 
	var moveSpeed:Float;
	var damage:Int;
	var shooter:Actor;
	
	public function new(world:World, shooter:Actor, x0:Float, y0:Float,x1:Float, y1:Float, damage:Int) {
		super(x0, y0);
		this.world = world;
		this.shooter = shooter;
		
		loadGraphic(SpritesSmall, true, false, 8, 8);
		addAnimation("shot", [243], 0);
		
		var self = this;
		var removeOnHit = function(name:String, frameNumber:Int, frameIndex:Int) {
			if(name=="hit" && frameNumber == 2)
				self.world.playState.remove(self);
		}
		
		addAnimation("hit", [242, 245, 243],10);
		addAnimationCallback(removeOnHit);
		
		play("shot");
		
		moveSpeed = 0.5;
		this.damage = damage;
		
		// Looks like x0/y0 and x1/y1 need to be tile coordinates, NOT pixel coordinates
		moveTo(x1, y1);
	}
	
	public function moveTo(X:Float, Y:Float):Void {
		var self = this;
		var src = new HxlPoint(x, y);
		var target = new HxlPoint(X, Y);
		var duration = HxlUtil.distance(src, target) * moveSpeed/500;
		
		var targetActor = world.currentLevel.getTile(X/Resources.tileSize, Y/Resources.tileSize).actor;
		//trace(targetActor);
		
		if (Std.is(targetActor, Mob)) {
			cast(targetActor, Mob).takeHit(shooter, damage);
		}
		
		Actuate.tween(this, duration, { x: X, y: Y } ).onComplete(moveStop,[targetActor]);
	}
	
	public function moveStop(target:Actor):Void {
		play("hit");
	}
}
