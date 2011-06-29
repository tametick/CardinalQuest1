package haxel;

import haxel.HxlGraphics;
import haxel.HxlSprite;

/**
 * This is a special effects utility class to help HxlGame do the 'flash' effect
 */
class HxlFlash extends HxlSprite {

	/**
	 * How long the effect should last.
	 */
	var _delay:Float;
	/**
	 * Callback for when the effect is finished.
	 */
	var _complete:Dynamic;

	/**
	 * Constructor for this special effect
	 */
	public function new() {
		super();
		createGraphic(HxlGraphics.width,HxlGraphics.height,0,true);
		scrollFactor.x = 0;
		scrollFactor.y = 0;
		exists = false;
		solid = false;
		//fixed = true;
	}

	/**
	 * Reset and trigger this special effect
	 * 
	 * @param	Color			The color you want to use
	 * @param	Duration		How long it takes for the flash to fade
	 * @param	FlashComplete	A function you want to run when the flash finishes
	 * @param	Force			Force the effect to reset
	 */
	public function start(?Color:Int=0xffffffff, ?Duration:Float=1, ?FlashComplete:Dynamic=null, ?Force:Bool=false) {
		if (!Force && exists) return;
		fill(Color);
		_delay = Duration;
		_complete = FlashComplete;
		color = Color;
		alpha = 1;
		exists = true;
	}

	/**
	 * Stops and hides this screen effect.
	 */
	public function stop() {
		exists = false;
	}

	/**
	 * Updates and/or animates this special effect
	 */
	public override function update() {
		alpha -= HxlGraphics.elapsed/_delay;
		if(alpha <= 0)
		{
			exists = false;
			if(_complete != null)
				_complete();
		}
	}

}
