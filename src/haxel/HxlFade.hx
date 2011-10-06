//FIXME - a lot of unneeded objects ({}'s) are created here!

package haxel;

import haxel.HxlSprite;
import haxel.HxlGraphics;
import haxel.HxlUtil;

import flash.text.TextField;
import flash.text.TextFormat;

import com.eclecticdesignstudio.motion.Actuate;

class HxlFade extends HxlSprite {

	/**
	 * How long the effect should last.
	 */
	var _delay:Float;
	/**
	 * Callback for when the effect is finished.
	 */
	var _complete:Dynamic;

	/**
	 * If true, fade out. If false, fade in.
	 **/
	var _fadeOut:Bool;

	/**
	 * Constructor initializes the fade object
	 */
	public function new() {
		super();
		createGraphic(HxlGraphics.width,HxlGraphics.height,0,true);
		scrollFactor.x = 0;
		scrollFactor.y = 0;
		exists = false;
		solid = false;
		//fixed = true;
		_fadeOut = true;
	}
	
	/**
	 * Reset and trigger this special effect
	 * 
	 * @param	Color			The color you want to use
	 * @param	Duration		How long it should take to fade the screen out
	 * @param	FadeComplete	A function you want to run when the fade finishes
	 * @param	Force			Force the effect to reset
	 */
	public function start(?FadeOut:Bool=true, ?Color:Int=0xff000000, ?Duration:Float=1, ?FadeComplete:Dynamic=null, ?Force:Bool=false) {
		_fadeOut = FadeOut;

		if (!Force && exists) 
			return;
			
		fill(Color);
		_delay = Duration;
		_complete = FadeComplete;
		
		if ( _fadeOut ) {
			alpha = 0;
		} else {
			alpha = 1;
		}
		exists = true;
		
		for ( i in 0...HxlGraphics.state.numChildren ) {
			if ( Std.is(HxlGraphics.state.getChildAt(i), flash.text.TextField) ) {
				var obj:TextField = cast(HxlGraphics.state.getChildAt(i), TextField);
				var oldColor = HxlUtil.colorRGB(obj.textColor);
				var newColor = HxlUtil.colorRGB(Color);
				
				function fade(r:Dynamic, g:Dynamic, b:Dynamic) {
					fadeText(r,g,b,obj);
				}
				
				if ( !_fadeOut ) {
					Actuate.update(fade, Duration, [newColor[0], newColor[1], newColor[2]], [oldColor[0], oldColor[1], oldColor[2]]);
				} else {
					Actuate.update(fade, Duration, [oldColor[0], oldColor[1], oldColor[2]], [newColor[0], newColor[1], newColor[2]]);
				}
				
				obj = null;
			}
		}
	
	}
	
	public function fadeText(r:Dynamic, g:Dynamic, b:Dynamic,obj) {
		obj.textColor = HxlUtil.colorInt(Math.round(cast(r,Float)), Math.round(cast(g,Float)), Math.round(cast(b,Float)));
		obj.alpha = 1.0;
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
		if ( _fadeOut ) {
			alpha += HxlGraphics.elapsed/_delay;
			if (alpha >= 1) {
				alpha = 1;
				if (_complete != null) {
					_complete();
				}
				//trace(_complete);
			}
			//trace((alpha >= 1));
			//trace(alpha);
		} else {
			alpha -= HxlGraphics.elapsed/_delay;
			if (alpha <= 0) {
				alpha = 0;
				if (_complete != null) {
					_complete();
				}
			}
		}
	}
}
