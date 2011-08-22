package cq.ui.inventory;

import cq.ui.CqItemInfoDialog;
import cq.ui.CqPotionButton;
import cq.ui.CqPotionGrid;
import cq.ui.CqSpellButton;
import cq.ui.CqPopup;
import cq.CqActor;
import cq.CqItem;
import cq.CqResources;
import cq.CqSpell;
import cq.CqGraphicKey;
import data.Registery;
import cq.ui.CqSpellGrid;
import data.Resources;
import data.Configuration;
import data.SoundEffectsManager;
import haxel.GraphicCache;
import world.Tile;

import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.filters.GlowFilter;

import haxel.HxlDialog;
import haxel.HxlGradient;
import haxel.HxlGraphics;
import haxel.HxlObject;
import haxel.HxlObjectContainer;
import haxel.HxlPoint;
import haxel.HxlSlidingDialog;
import haxel.HxlSprite;
import haxel.HxlSpriteSheet;
import haxel.HxlText;
import haxel.HxlUtil;


class CqInventoryDialog extends HxlSlidingDialog {
	public var gameui:GameUI;
	public var dlgCharacter:HxlDialog;
	public var dlgInfo:CqItemInfoDialog;
	public var dlgInvGrid:CqInventoryGrid;
	public var dlgEqGrid:CqEquipmentGrid;
	public var dlgSpellGrid:CqSpellGrid;
	public var dlgPotionGrid:CqPotionGrid;

	static inline var DLG_OUTER_BORDER:Int 		= 10; 
	static inline var DLG_TOP_BORDER:Int 		= 0; 
	static inline var DLG_GAP:Int 				= 15; 
	static inline var DLG_DIVISOR_H_PERCENT:Int = 75;
	static inline var DLG_DIVISOR_V_PERCENT:Int = 55;
	
	public function new(_GameUI:GameUI, ?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?Direction:Int=0) {
		// Size: 472 x 480
		super(X, Y, Width, Height, Direction);
		
		gameui = _GameUI;
		
		var div_l:Float = (Width * (DLG_DIVISOR_V_PERCENT / 100)) - DLG_OUTER_BORDER*2;
		var div_r:Float = (Width * ((100-DLG_DIVISOR_V_PERCENT) / 100))-DLG_OUTER_BORDER*2;
		var div_u:Float  = (Height * (DLG_DIVISOR_H_PERCENT / 100))-DLG_TOP_BORDER*2;
		var div_b:Float  = (Height * ((100 - DLG_DIVISOR_H_PERCENT) / 100))-DLG_TOP_BORDER*2;
		
		//on the left
		dlgCharacter = new HxlDialog(DLG_OUTER_BORDER, DLG_TOP_BORDER, div_l-DLG_OUTER_BORDER, div_u-DLG_OUTER_BORDER);
		add(dlgCharacter);
		dlgCharacter.setBackgroundGraphic(UiInventoryBox);
		
		//in dlgCharacter
		dlgEqGrid = new CqEquipmentGrid(14, 10, dlgCharacter.width, dlgCharacter.height);
		dlgCharacter.add(dlgEqGrid);

		//on the right
		dlgInfo = new CqItemInfoDialog(div_l + DLG_GAP, DLG_TOP_BORDER, div_r, div_u - DLG_OUTER_BORDER);
		dlgInfo.zIndex = 3;
		add(dlgInfo);

		//on the bottom
		dlgInvGrid = new CqInventoryGrid(DLG_OUTER_BORDER + 5, div_u - 38, div_l + div_r, div_b);
		dlgInvGrid.zIndex = 2;
		add(dlgInvGrid);

		CqInventoryItem.backgroundKey = CqGraphicKey.ItemBG;
		CqInventoryItem.backgroundSelectedKey = CqGraphicKey.ItemSelectedBG;
	}

	public override function hide(?HideCallback:Dynamic=null) {
		super.hide(HideCallback);
		if ( CqInventoryItem.selectedItem != null ) {
			CqInventoryItem.selectedItem.setSelected(false);
			CqInventoryItem.selectedItem = null;
		}
		dlgInfo.clearInfo();
	}
}
