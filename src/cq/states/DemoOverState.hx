package cq.states;

import cq.CqResources;
import flash.net.URLRequest;
import haxel.HxlText;

import flash.Lib;

class DemoOverState extends GameOverState{
	public override function create() {
		super.create();
		
		scroller.setSplash(BlankScreen);
		scroller.setTitle("Demo Over!");		
		var link:HxlText = new HxlText(0, 160, 640, "Want more?\nwww.cardinalquest.com", true, null, 50, 0xFFFFFF, "center");
		add(link);
	}
	
	
	override public function nextScreen() {
		Lib.getURL(new URLRequest("http://www.cardinalquest.com"));
	}
}