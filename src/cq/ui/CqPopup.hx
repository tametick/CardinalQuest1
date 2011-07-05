package cq.ui;
import haxel.HxlText;

/**
 * ...
 * @author joris
 */

class CqPopup extends HxlText
{
	public function new(Width:Int,Text:String) 
	{
		super(0, 0, Width, Text);
		setFormat("FontAnonymousPro", 15, 0xC2AC30, "left", 1);
	}
	
}