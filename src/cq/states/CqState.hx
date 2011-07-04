package cq.states;
import haxel.HxlState;
import cq.CqResources;

class CqState extends HxlState {
	public override function create() {
		if(CursorSprite.instance == null)
			CursorSprite.instance = new CursorSprite();
		cursor = CursorSprite.instance;
		cursor.setFrame(SpriteCursor.instance.getSpriteIndex("diagonal"));
		
		super.create();
	}
	
	function setDiagonalCursor() {
		cursor.angle = 0;
		var diagonal = SpriteCursor.instance.getSpriteIndex("diagonal");
		if(cursor.getFrame()!=diagonal) {
			cursor.setFrame(diagonal);
		}
	}
}