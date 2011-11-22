package cq.ui;
import cq.CqResources;
import haxel.HxlGroup;
import cq.ui.CqFloatText;
import haxel.HxlPoint;

/**
 * ...
 * @author joris
 */

class CqTextNotification extends HxlGroup
{
	private static var _instance:CqTextNotification;
	var notifications:Array<CqFloatText>;
	
	var Xpos:Int;
	var Ypos:Int;
	
	static inline var textSize:Int = 18;
	//static inline var messageDuration:Int = 100;
	
	public function new(?X:Int=0, ?Y:Int=0) 
	{
		Xpos = X;
		Ypos = Y;
		super();
		notifications = new Array();
		scrollFactor = new HxlPoint(0,0);
		CqTextNotification._instance = this;
	}
	public function notify(message:String, ?color:Int = 0xDE913A)
	{
		if (message == null || message == "")
			return;
		var txt:CqFloatText = new CqFloatText(null, Xpos, Ypos , message, color,FontAnonymousPro.instance.fontName, textSize, false);
		notifications.unshift(txt);
		txt.InitSemiCustomTween(1.5,{},onTween);
		txt.scrollFactor = scrollFactor;
		updatePositions();
		add(txt);
		
	}
	
	public function clear()
	{
		for ( n in notifications ) {
			remove(n);
			n.destroy();
		}
	}
	
	function updatePositions()
	{
		for ( i in 0...notifications.length)
		{
			var notif:CqFloatText = notifications[i];
			notif.y = Ypos + (textSize * i);
		}
	}
	function onTween() {
		notifications.pop();
		updatePositions();
	}
	static public function getInstance():CqTextNotification 
	{
		return _instance;
	}
}