package cq.states;

import data.Resources;
import flash.net.URLRequest;
import haxel.HxlText;

import flash.Lib;

class DemoOverState extends GameOverState{
	public override function create() {
		super.create();
		
		scroller.setSplash(BlankScreen);
		scroller.setTitle(Resources.getString( "DEMO_OVER" ));		
		var link:HxlText = new HxlText(0, 160, 640, Resources.getString( "DEMO_OVER_MORE" ) + "\nwww.cardinalquest.com", true, null, 50, 0xFFFFFF, "center");
		add(link);
	}
	
	
	override public function nextScreen() {
		Lib.getURL(new URLRequest("http://www.cardinalquest.com"));
	}
}