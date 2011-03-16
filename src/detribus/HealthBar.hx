package detribus;

import haxel.HxlGraphics;
import haxel.HxlGroup;
import haxel.HxlSprite;

import com.eclecticdesignstudio.motion.Actuate;

class HealthBar extends HxlGroup {

	private var bar:HxlSprite;
	private var barMaxW:Int;
	private var barW:Int;
	private var barTween:Dynamic;

	public function new() {
		super();

		var outer:HxlSprite = new HxlSprite(0, 0);
		outer.createGraphic(64, 10, 0xffffffff);
		add(outer);
		outer.scrollFactor.x = outer.scrollFactor.y = 0;

		var inner:HxlSprite = new HxlSprite(1, 1);
		inner.createGraphic(62, 8, 0xff000000);
		add(inner);
		inner.scrollFactor.x = inner.scrollFactor.y = 0;

		bar = new HxlSprite(2, 2);
		bar.createGraphic(60, 6, 0xffffffff);
		add(bar);
		bar.scrollFactor.x = bar.scrollFactor.y = 0;

		barMaxW = barW  = 60;

		scrollFactor.x = scrollFactor.y = 0;

	}

	public function setWidth(Percent:Float):Void {
		Actuate.stop(bar, {}, true);
		var _bar = bar;
		var newWidth:Int = Std.int(60 * Percent);
		barTween = Actuate.update(function(params:Dynamic) {
				_bar.createGraphic(params.Width>=1?params.Width:1, 6, 0xffffffff);
			}, 0.1, {Width: barW}, {Width: newWidth});
		barW = newWidth;
	}

}
