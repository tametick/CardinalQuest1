package cq.states;

import cq.CqActor;
import cq.CqConfiguration;
import cq.CqRegistery;
import cq.CqResources;
import cq.ui.CqTextScroller;
import data.Registery;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import haxel.HxlGraphics;
import haxel.HxlPoint;
import haxel.HxlSprite;
import haxel.HxlState;
import haxel.HxlText;
import haxel.HxlTimer;
import haxel.HxlUtil;

class WinState extends CqState {

	private var fadeTime:Float;
	private var bg:HxlSprite;
	private var lights:HxlSprite;
	private var figure:HxlSprite;
	private var Figurescale:HxlPoint;
	private var scroller:CqTextScroller;
	public override function create() {
		super.create();

		fadeTime = 3;
		
		stackRender = true;
		
		scroller = new CqTextScroller(null, 5);
		scroller.addColumn(80, 480, "The evil minotaur has escaped, but you can still catch him, next time...", false, FontDungeon.instance.fontName, 30, 0x0C11F1);
		Figurescale = new HxlPoint(2.0, 2.0);
		figure = new HxlSprite(85, 40, VortexFigure, Figurescale.x, Figurescale.y);
		bg = new HxlSprite(50, 50, VortexScreen);
		lights = new HxlSprite(0, 0, VortexLightsScreen);
		add(figure);
		figure.zIndex = 10;
		scroller.zIndex = 11;
		add(lights);
		add(bg);
		add(scroller);
		defaultGroup.sortMembersByZIndex();
		scroller.setMinimumTime(2);
		scroller.onComplete(nextScreen);
		scroller.startScroll(100,16);
		
	}

	public override function update() {
		super.update();	
		setDiagonalCursor();
		HxlGraphics.doFollow();
		bg.angle++;
		lights.angle += 0.7;
		
		figure.angle-= 0.4;
		Figurescale.y = Figurescale.x *= 0.993;
		figure.scale = Figurescale;
		
	}

	function nextScreen() {
		HxlGraphics.fade.start(true, 0xff000000, fadeTime, function() {
			var newState = MainMenuState.instance;
			HxlGraphics.state = newState;
		}, true);
	}
	
}