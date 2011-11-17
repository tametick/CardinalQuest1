package cq.states;

import cq.CqActor;
import data.Configuration;
import data.Registery;
import cq.CqResources;
import cq.ui.CqTextScroller;
import data.Registery;
import data.Resources;
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
		cursor.visible = true;
		stackRender = true;
			
		cursor.visible = false;
		scroller = new CqTextScroller(null, 5);
//		scroller.addColumn(80, 480, Resources.getString( "AsterionDefeated", true ), false, FontDungeon.instance.fontName, 28);
		scroller.addColumn(60, 520, Resources.getString( "AsterionDefeated", true ), true, FontDungeon.instance.fontName, 32);
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
		scroller.startScroll(12);
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
		cursor.visible = true;
		HxlGraphics.fade.start(true, 0xff000000, fadeTime, function() {
			HxlGraphics.setState(new MainMenuState());
		}, true);
	}
	
}