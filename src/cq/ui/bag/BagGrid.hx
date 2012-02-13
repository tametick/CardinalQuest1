package cq.ui.bag;

import haxel.HxlDialog;
import haxel.HxlMouse;
import haxel.HxlPoint;
import haxel.HxlRect;
import haxel.HxlSprite;

import cq.states.GameState;
import cq.states.MainMenuState;
import cq.states.HelpState;

import cq.CqResources;
import cq.GameUI;
import cq.CqItem;
import cq.CqResources;
import cq.CqSpell;
import cq.CqActor;
import cq.CqGraphicKey;

import data.SoundEffectsManager;
import data.Configuration;
import data.Resources;
import data.Registery;

import flash.display.BitmapData;
import flash.display.Shape;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.ColorTransform;

import cq.ui.bag.BagDialog;
import cq.CqBag;

import cq.ui.CqPopup;
import haxel.HxlUtil;
import haxel.HxlSprite;
import haxel.HxlSpriteSheet;

import flash.display.Bitmap;
import flash.display.Graphics;

import flash.filters.GlowFilter;
import haxel.HxlText;

import haxel.GraphicCache;

import haxel.HxlButton;
import haxel.HxlGraphics;
import haxel.HxlObjectContainer;
import haxel.HxlLog;
import haxel.HxlSprite;





// wait -- the inventory proxy is ugly, but it was definitely rewritten.  (the comment claiming otherwise should have been cut)

class CqInventoryProxyBMPData extends BitmapData { }
class CqInventoryProxy extends HxlSprite {
	public var item(default, null):CqItem;
	
	var background:BitmapData;
	var icon:CqInventoryProxyBMPData;
	
	public var clearCharge:Bool;
	
	public static var backgroundKey:CqGraphicKey;
	public static var backgroundSelectedKey:CqGraphicKey;
	
	public static var theProxyBeingDragged:CqInventoryProxy; // a little messy, but in mobile mode this is the proxy that you clicked on to start a swap!

	var selected:Bool;
	var isGlowing:Bool;
	var glowSprite:CqInventoryProxyBMPData;
	var glowRect:Rectangle;
	
	var chargeArcSprite:HxlSprite;
	var chargeArcBitmap:CqInventoryProxyBMPData;
	
	var namePopup:CqPopup;
	
	public function new(Item:CqItem) {
		if (Item == null || Item.inventoryProxy != null) throw "Cannot make two proxies for one inventory item";
		
		super(2, 2);
		icon = null;
		item = null;
		setSelected(false);
		glowRect = new Rectangle(0, 0, 58, 58);
		isGlowing = false;
		
		toggleDrag(true);
		
		zIndex = 5;
		item = Item;
		
		if (Std.is(item, CqSpell)) {
			setIcon(CqSheets.getSpellPixels(item.spriteIndex));
		} else {
			setIcon(CqSheets.getItemPixels(item.spriteIndex));
		}
		
		//popup
		namePopup = new CqPopup(180, item.fullName, GameUI.instance.popups);
		setPopup(namePopup);
		GameUI.instance.popups.add(namePopup);
		namePopup.zIndex = 15;
		
		//make magical items glow
		if (item.isSuperb && !item.isMagical && !item.isWondrous) {
			customGlow(0x206CDF);
			setGlow(true);
		} else if (item.isMagical && !item.isSuperb) {
			customGlow(0x3CDA25);
			setGlow(true);
		} else if (item.isMagical && item.isSuperb)	{
			customGlow(0x1FE0D7);
			setGlow(true);
		} else if (item.isWondrous && item.isSuperb) {
			customGlow(0xE7A918);
			setGlow(true);
		}
		
		if (Std.is(Item, CqSpell)) {
			chargeArcSprite = new HxlSprite(x + 5, y + 5);
			chargeArcSprite.zIndex = 16;

			chargeArcSprite.createGraphic(54, 54, 0x00010101);
			GameUI.instance.doodads.add(chargeArcSprite);

			chargeArcBitmap = new CqInventoryProxyBMPData(94, 94, true, 0x0);
			
			updateCharge();
		}
	}
	
	override public function destroy() {
		super.destroy();
		if(icon!=null) {
			icon.dispose();
			icon = null;
		}
		if(glowSprite!=null) {
			glowSprite.dispose();
			glowSprite = null;
		}
		if(pixels!=null) {
			pixels.dispose();
			pixels = null;
		}
		
		if (namePopup != null) {
			if (GameUI.instance != null) {
				GameUI.instance.doodads.remove(namePopup);
			}
			namePopup = null;
		}
		
		if (chargeArcSprite != null) {
			if (GameUI.instance != null) {
				GameUI.instance.doodads.remove(chargeArcSprite);
			}
			chargeArcSprite = null;
		}
	}

	override private function dragStart() {
		GameUI.instance.bagDialog.slidingPart.itemInfoDialog.setItem( this.item );
		
		// indicate that this is the item being dragged
		CqInventoryProxy.theProxyBeingDragged = this;
		zIndex = 15;
		
		item.itemSlot.cell.remove(this);
		GameUI.instance.doodads.add(this);
		GameUI.instance.popups.remove(namePopup);
		
		// setting the zIndex doesn't suffice -- we need to attach this to the stage, instead
	}
	
	public function triggerUserInvokedSwap() {
		if (CqInventoryCell.theCellBeingHoveredOver != null && CqInventoryCell.theCellBeingHoveredOver != item.itemSlot.cell) {
			// type checking is done before CqInventoryCell.theCellBeingHoveredOver is ever set to non-null
			// (if it were not, it would be possible to make items disappear)
			
			if (CqInventoryCell.theCellBeingHoveredOver.isTrashCell) {
				var bag = item.itemSlot.bag;
				item.itemSlot.item = null;
				// GameUI.instance.popups.remove(namePopup);
				bag.giveMoney(item);
				destroy();
				SoundEffectsManager.play(Pickup);	
			} else {
				var myOldSlot = item.itemSlot;
				var myItem = myOldSlot.item;
				var itsItem = CqInventoryCell.theCellBeingHoveredOver.slot.item;
				
				CqInventoryCell.theCellBeingHoveredOver.slot.item = myItem;
				myOldSlot.item = itsItem;
			}
			
			Registery.player.updateSprite();
		} else {
			// Return to the slot we started in.
			item.itemSlot.cell.add(this);
			
			x = dragStartPoint.x;
			y = dragStartPoint.y;
		}
		
		CqInventoryProxy.theProxyBeingDragged = null;
	}
	
	override private function dragStop() {
		GameUI.instance.doodads.remove(this);
		GameUI.instance.popups.add(namePopup);
		
		triggerUserInvokedSwap();
		
		zIndex = 5;
	}
	
	public function updatePopupText() {
		// Set popup text.
		if ( item.itemSlot.cell.popupHint != -1 ) {
			namePopup.setText( item.fullName + "\n" + Resources.getString( "POPUP_" + item.itemSlot.cell.popupHint ) );
		} else {
			namePopup.setText( item.fullName );
		}
	}
	
	// here on out is just transferred, uncorrected:
	public function setSelected(Toggle:Bool) {
		selected = Toggle;
		if ( selected ) {
			loadCachedGraphic(backgroundSelectedKey);
			background = GraphicCache.getBitmap(backgroundSelectedKey);
			if ( icon != null ) setIcon(icon);
			//_dlg.dlgInfo.setItem(item);
		} else {
			loadCachedGraphic(backgroundKey);
			background = GraphicCache.getBitmap(backgroundKey);
			if ( icon != null ) setIcon(icon);
		}
	}
	
	public function setIcon(?Icon:BitmapData = null) {
		// this is largely unchanged, mind, so actually read it
		Icon = if (Icon == null) icon else Icon;
		
		icon = new CqInventoryProxyBMPData(Icon.width, Icon.height, true, 0x0);
		icon.copyPixels(Icon, new Rectangle(0, 0, Icon.width, Icon.height), new Point(0,0), null, null, true);
		var X:Int = Std.int((width / 2) - (icon.width / 2));
		var Y:Int = Std.int((height / 2) - (icon.height / 2));
		var temp:CqInventoryProxyBMPData = new CqInventoryProxyBMPData(background.width, background.height, true, 0x0);
		temp.copyPixels(background, new Rectangle(0, 0, background.width, background.height), new Point(0, 0), null, null, true);
		temp.copyPixels(icon, new Rectangle(0, 0, icon.width, icon.height), new Point(X, Y), null, null, true);
		if ( item.stackSize > 1 ) {
			var txt:HxlText = new HxlText(0, 0, Std.int(width), ""+item.stackSize);
			txt.setProperties(false, false, false);
			txt.setFormat(null, 18, 0xffffff, "right", 0x010101);
			temp.copyPixels(txt.pixels, new Rectangle(0, 0, txt.width, txt.height), new Point(0, (height-2-txt.height)), null, null, true);
		}
		pixels = temp;
		
		if (isGlowing) {
			renderGlow();
		}
	}	
	
	public function customGlow(color:Int) {
		var tmp:CqInventoryProxyBMPData = new CqInventoryProxyBMPData(48, 48, true, 0x0);
		tmp.copyPixels(getFramePixels(), new Rectangle(0, 0, 48, 48), new Point(0, 0), null, null, true);
		var glow:GlowFilter = new GlowFilter(color, 0.9, 16.0, 16.0, 1.6, 1, false, false);
		tmp.applyFilter(tmp, glowRect, new Point(0, 0), glow);
		glowSprite = tmp;
	}
	
	public function setGlow(Toggle:Bool) {
		isGlowing = Toggle;
		if (isGlowing)
			renderGlow();
	}
	
	
	// transferred from the old system directly -- pretty weak
	
	function renderGlow() {
		getScreenXY(_point);
		_flashPoint.x = _point.x - 8;
		_flashPoint.y = _point.y - 8;
		_pixels.copyPixels(glowSprite, glowRect, _flashPoint, null, null, true);
		setPixels(glowSprite);
	}

	static var ctrans:ColorTransform;
	private static var clearChargeRect = new Rectangle(0, 0, 94, 94);
	public function updatechargeArcSprite(chargeShape:Shape) {
		if (chargeArcSprite != null) {
			chargeArcSprite.x = x;
			chargeArcSprite.y = y;
		}
		
		chargeArcBitmap.fillRect(clearChargeRect, 0x0);
		chargeArcBitmap.draw(chargeShape, null, ctrans);

		if (ctrans == null) {
			ctrans = new ColorTransform();
			ctrans.alphaMultiplier = 0.5;
		}

		chargeArcSprite.loadSuppliedGraphic(chargeArcBitmap);
//		chargeArcSprite.visible = true;
	}	

	public function updateCharge() {
		var chargeBmp:Bitmap = new Bitmap(GraphicCache.getBitmap(CqGraphicKey.EquipmentCellBG));
		var chargeShape:Shape = new Shape();

		var statPoints = 0;
		var statPointsRequired = 1;
		
		var spell = cast(item, CqSpell);
		
		var start = -Math.PI / 2;
		var end = start + 2 * Math.PI * (spell.statPoints / spell.statPointsRequired);

		var G = chargeShape.graphics;
		G.clear();
		G.beginFill(0x000000, 1.0);
		drawChargeArc(G, 27, 27, end, start + 2 * Math.PI, 47, 1);
		G.endFill();
		G = null;
/*
		// Alternative drawing code below - experimenting with things like showing the section
		// that'll be cleared in the next turn.
		var nextTurnBonus:Float = 0;
		switch ( spell.stat ) {
			case "spirit": nextTurnBonus = Math.max( Registery.player.spirit + Registery.player.getBuff("spirit"), 0 );
			case "speed": nextTurnBonus = Math.max( Registery.player.speed + Registery.player.getBuff("speed"), 1 );
			case "attack": nextTurnBonus = Math.max( Registery.player.attack + Registery.player.getBuff("attack"), 0 );
			case "defense": nextTurnBonus = Math.max( Registery.player.defense + Registery.player.getBuff("defense"), 0 );
			case "life": nextTurnBonus = Math.max( Registery.player.maxHp + Registery.player.getBuff("life"), 0 );
		}
		
		nextTurnBonus *= 60 / Math.max( Registery.player.speed + Registery.player.getBuff("speed"), 1 );
		
		var nextTurnPoints = Math.min( spell.statPoints + nextTurnBonus, spell.statPointsRequired);

		var endNext = start + 2 * Math.PI * (nextTurnPoints / spell.statPointsRequired);
			
		var G = chargeShape.graphics;
		G.clear();
		
		var midAngle = Math.min( end + 0.35 * (endNext - end), start + 2 * Math.PI );
		
		G.beginFill(0x000000, 1.0);
		drawChargeArc(G, 27, 27, endNext, start + 2 * Math.PI, 47, 1);
		G.endFill();
		G.beginFill(0x000000, 1.0);
		drawChargeArc(G, 27, 27, end, midAngle, 47, 1);
		G.endFill();
		G.beginFill(0x000000, 0.5);
		drawChargeArc(G, 27, 27, midAngle, endNext, 47, 1);
		G.endFill();
		G = null;
*/
		chargeShape.mask = chargeBmp;
		
		updatechargeArcSprite(chargeShape);
		
		chargeBmp = null;
		chargeShape = null;
	}

	public function setChargeArcVisible( _visible:Bool ) {
		if ( chargeArcSprite != null ) {
			chargeArcSprite.visible = _visible;
		}
	}
	
	public override function update() {
		super.update();
		if (chargeArcSprite != null) {
			chargeArcSprite.x = x;
			chargeArcSprite.y = y;
		}
		
		if ( CqInventoryProxy.theProxyBeingDragged == null ) {
			var m:HxlMouse = HxlGraphics.mouse;
			if ( visible && overlapsPoint(m.x, m.y, true) )	{
				GameUI.instance.bagDialog.slidingPart.itemInfoDialog.setItem( this.item );
			}
		}
	}

	static var s_controlPoint:Point = new Point();
	static var s_anchorPoint:Point = new Point();
	
	public static function drawChargeArc(G:Graphics, centerX:Float, centerY:Float, startAngle:Float, endAngle:Float, radius:Float, direction:Int) {
		var difference:Float = Math.abs(endAngle - startAngle);
		var divisions:Int = Math.floor(difference / (Math.PI / 4))+1;
		var span:Float = direction * difference / divisions;
		var controlRadius:Float = radius / Math.cos(span);
		//G.moveTo(centerX + (Math.cos(startAngle)*radius), centerY + Math.sin(startAngle)*radius);
		G.moveTo(centerX, centerY);
		G.lineTo(centerX + (Math.cos(startAngle) * radius), centerY + Math.sin(startAngle) * radius);
		
		var controlAngle:Float;
		var anchorAngle:Float;
		for ( i in 0...divisions ) {
			controlAngle = startAngle + (i+0.5) * span;
			anchorAngle = startAngle + (i + 1) * span;
			
			s_controlPoint.x = centerX + Math.cos(controlAngle) * controlRadius;
			s_controlPoint.y = centerY + Math.sin(controlAngle) * controlRadius;
			s_anchorPoint.x = centerX + Math.cos(anchorAngle) * radius;
			s_anchorPoint.y = centerY + Math.sin(anchorAngle) * radius;
			
			G.curveTo( s_controlPoint.x, s_controlPoint.y, s_anchorPoint.x, s_anchorPoint.y );
		}
		G.lineTo(centerX, centerY);
	}
}




class CqInventoryCell extends HxlDialog {
	public var proxy (getProxy, setProxy):CqInventoryProxy;
	public var slot (default, default):CqItemSlot; // this is managed by CqBag and is only set when the cell (which is a ui element) is associated with a slot (which is a logical location in the player's bag)
	
	public var equipType(default, null):CqEquipSlot;
	public var popupHint:Int;
	
	public static var theCellBeingHoveredOver:CqInventoryCell;
	
	var bgHighlight:HxlSprite;
	var bgGlow:HxlSprite;
	var isHighlighted:Bool;
	
	public var isTrashCell:Bool;
	public var icon:HxlSprite;
	
	public function new(?EquipType:CqEquipSlot = null, ?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super(X, Y, Width, Height);
		bgHighlight = null;
		bgGlow = null;
		_proxy = null;
		isHighlighted = false;
		isTrashCell = false;
		
		equipType = EquipType;
		popupHint = -1;
		
		if (HxlGraphics.stage != null) {
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, true, 6, true);
		}
		
		if (Width >= 58 || !HxlGraphics.smallScreen) {
			add(new ButtonSprite());
		} else {
			add(new ButtonSprite_48());
		}
	}
	
	public function setPopupHint( Hint:Int ) {
		popupHint = Hint;
	}
	
	override public function destroy() {
		if(bgGlow !=null) {
			bgGlow.destroy();
			bgGlow = null;
		}
			
		if(bgHighlight!=null){
			bgHighlight.destroy();
			bgHighlight = null;
		}
		
		super.destroy();
	}

	public function setGraphicKeys(Normal:CqGraphicKey, ?Highlight:CqGraphicKey = null, ?Glow:CqGraphicKey = null) {
		if ( bgHighlight == null ) {
			bgHighlight = new HxlSprite(5, 5);
			bgHighlight.zIndex = 1;
			add(bgHighlight);
			bgHighlight.visible = false;
		}
		
		if (bgGlow == null) {
			bgGlow = new HxlSprite(-12, -12);
			bgGlow.zIndex = -3;
			add(bgGlow);
			bgGlow.visible = false;
		}
		
		setBackgroundKey(Normal);
		
		if ( Highlight == null ) 
			Highlight = Normal;
			
		bgHighlight.loadCachedGraphic(Highlight);
		
		if ( Glow == null ) 
			Glow = Normal;
			
		bgGlow.loadCachedGraphic(Glow);
		origin.x = Std.int(background.width / 2);
		origin.y = Std.int(background.height / 2);
		
		if (isTrashCell) {
			becomeTrashCell();
		}
	}
	
	function becomeTrashCell()	{
		var icon = SpriteEquipmentIcons.getIcon("destroy", 16, 2.0);
		icon.setAlpha(0.3);
		add(icon);
		icon.x += 19;
		icon.y += 8;
			
		// this needs to be added to resources!
		var droptext:HxlText = new HxlText(0, 37, Std.int(width), Resources.getString( "UI_DESTROY" ) );
		droptext.setFormat(FontAnonymousPro.instance.fontName, 12, 0xffffff, "center", 0x010101);
		droptext.zIndex = 10;
		droptext.setAlpha(0.3);
		add(droptext);
	}
	
	public override function update() {
		super.update();
		
		if (_proxy != null && CqInventoryProxy.theProxyBeingDragged != _proxy) {
			// this is a workaround for a strange absolute/relative positioning bug in haxel
			_proxy.x = x + 8;
			_proxy.y = y + 7;
		}
		
		var isAcceptable = isDraggedItemAcceptable();
		
		if (isAcceptable && isDraggedItemHoveringHere()) {
			background.visible = false;
			bgHighlight.visible = true;
		
			CqInventoryCell.theCellBeingHoveredOver = this;
		} else {
			background.visible = true;
			bgHighlight.visible = false;
			
			if (CqInventoryCell.theCellBeingHoveredOver == this) {
				CqInventoryCell.theCellBeingHoveredOver = null;
			}
		}
		
		if (Configuration.mobile && this.proxy != null && this.proxy == CqInventoryProxy.theProxyBeingDragged) {
			background.visible = false;
			bgHighlight.visible = true;
		}
		
		bgGlow.visible = isAcceptable && slot != null && slot.equipmentType != null;
	}
	
	function isDraggedItemAcceptable():Bool {
		// check whether this cell can accept the item that's being dragged
		return
			// we've got to be dragging something:
			CqInventoryProxy.theProxyBeingDragged != null
			
			// and it's got to be able to come into this cell:
			&& (slot == null || slot.couldTakeItem(CqInventoryProxy.theProxyBeingDragged.item))
			
			// and whatever is in this cell now has got to be able to go where it's coming from:
			&& (slot == null || CqInventoryProxy.theProxyBeingDragged == null || CqInventoryProxy.theProxyBeingDragged.item.itemSlot.couldTakeItem(slot.item));
	}

	function isDraggedItemHoveringHere():Bool {
		if (visible && HxlGraphics.mouse.dragSprite != null) {
			var objX = HxlGraphics.mouse.dragSprite.x;
			var objY = HxlGraphics.mouse.dragSprite.y;
			var objW = HxlGraphics.mouse.dragSprite.width;
			var objH = HxlGraphics.mouse.dragSprite.height;
			
			//if ((x + width <= objX) || (x >= objX + objW) || (y + height <= objY) || (y >= objY + objH) ) {
			if ((x + width <= objX + .5 * objW) || (x >= objX + .5 * objW) || (y + height <= objY + .5 * objH) || (y >= objY + .5 * objH) ) {
				return false;
			} else {			
				theCellBeingHoveredOver = this;
				return true;
			}
		} else {
			return false;
		}
	}

	private function onMouseDown(event:MouseEvent) {
		if (!exists || !visible || !active || !Std.is(HxlGraphics.state, GameState) ) {
			return;
		}
		
		if (Configuration.mobile) {
			HxlGraphics.updateInput();
		}
		
		if (GameUI.instance.panels.currentPanel != GameUI.instance.panels.panelInventory) {
			if (overlapsPoint(HxlGraphics.mouse.x, HxlGraphics.mouse.y) && (equipType == SPELL || equipType == POTION)) {
				event.stopPropagation();
				activateItem();
			}
		} else {
			// we are in the inventory screen
			if (Configuration.mobile) {
				if (overlapsPoint(HxlGraphics.mouse.x, HxlGraphics.mouse.y)) {
					// instead of drag-n-drop, tap two cells to switch their contents
					if (CqInventoryProxy.theProxyBeingDragged != null) {
						if (isDraggedItemAcceptable() && proxy != CqInventoryProxy.theProxyBeingDragged) {
							CqInventoryCell.theCellBeingHoveredOver = this;
							CqInventoryProxy.theProxyBeingDragged.triggerUserInvokedSwap();
							CqInventoryCell.theCellBeingHoveredOver = null;
						} else {
							CqInventoryProxy.theProxyBeingDragged = null;
						}
					} else {
						CqInventoryProxy.theProxyBeingDragged = this.proxy;
					}
					event.stopPropagation();
				}
			}
		}
	}	

	private function activateItem() {
		if (proxy != null) {
			var item:CqItem = proxy.item;
			
			if (item.isReadyToActivate) {
				HxlLog.append("Using an item");
				item.tryToActivate();
			}
		}
	}

	var _proxy:CqInventoryProxy; // the proxy of the item in this cell's slot

	private function setProxy(newProxy:CqInventoryProxy) {
		if (_proxy != null) {
			remove(_proxy);
		}
		
		_proxy = newProxy;
		
		if (_proxy != null) {
			add(_proxy);
			update();
		}
		
		if (icon != null) icon.visible = _proxy == null;
		
		return _proxy;
	}

	private function getProxy():CqInventoryProxy {
		return _proxy;
	}
}

class CqInventoryGrid extends HxlDialog {
	public var cells:Array<CqInventoryCell>;
	
	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super(X, Y, Width, Height);
		
		cells = [];
	}
	
	override public function kill():Void {
		if (cells != null) {
			for (cell in cells) {
				if (cell.proxy != null) cell.proxy.destroy();
				cell.kill();
			}
			cells = null;
		}
		
		super.destroy();
		super.kill();
	}
	
	public function respondToHotkeys(correspondingHotkeys:Array<String>):Bool {
		for (i in 0 ... cells.length) {
			var hotkey = correspondingHotkeys[i];
			if (hotkey != null && HxlGraphics.keys.justPressed(hotkey)) {
				if (cells[i].proxy != null) {
					if (cells[i].proxy.item.tryToActivate(true)) {
						return true;
					}
				}
			}
		}
		return false;
	}
}


class CqBackpackGrid extends CqInventoryGrid {
	public function new(numberOfCells:Int, ?X:Int=0, ?Y:Int=0, ?Width:Float=100, ?Height:Float=100) {
		super(X, Y, Width, Height);
	
		var paddingX:Int = HxlGraphics.smallScreen ? 1 : 3;
		var paddingY:Int = HxlGraphics.smallScreen ? -6 : 10;
		var cellSize:Int = 64;
		var offsetX:Int = 0;
		var offsetY:Int = HxlGraphics.smallScreen ? -3 : -5;

		var rows:Int = 2;
		var cols:Int = Math.floor((numberOfCells + 1) / 2);
		
		for ( row in 0...rows ) {
			for ( col in 0...cols ) {
				var idx:Int = cells.length;
				var _x:Int = offsetX + ((col) * paddingX) + (col * cellSize);
				var _y:Int = offsetY + ((row) * paddingY) + (row * cellSize);
				
				var cell:CqInventoryCell = new CqInventoryCell(null, _x, _y, cellSize, cellSize);
				
				cell.setGraphicKeys(CqGraphicKey.EquipmentCellBG, CqGraphicKey.EqCellBGHighlight, CqGraphicKey.CellGlow);
				add(cell);
				cells.push(cell);
			}
		}
		
		var trashCell = cells[cells.length - 1];
		trashCell.isTrashCell = true;
		trashCell.setGraphicKeys(CqGraphicKey.EquipmentCellBG,CqGraphicKey.DropCellBGHighlight,CqGraphicKey.CellGlow);
	}
}


class CqClothingGrid extends CqInventoryGrid {
	static var slotNames = [
		{ icon: "shoes", type: SHOES },
		{ icon: "gloves", type: GLOVES },
		{ icon: "armor", type: ARMOR },
		{ icon: "jewelry", type: JEWELRY },
		{ icon: "weapon", type: WEAPON },
		{ icon: "hat", type: HAT }
	];
	
	static var cell_positions = [[
		[0, 108], [0, 55], [0, 2],
		[67, 108], [67, 55], [67, 2]
	], [
		[4, 176], [4, 94], [4, 7],
		[155, 176], [155, 94], [155, 7]
	]];
	
	static var padding:Int = 8;	
	
	
	public function getEquipmentTypeInfo(typeName:String) {
		for (slot in slotNames) {
			if (slot.icon == typeName) {
				return slot;
			}
		}
		
		return null;
	}
	
	private function getCellSize():Int {
		return HxlGraphics.smallScreen ? 40 : 54;
	}
	
	public function getIcon(typeName:String):HxlSprite {
		var cellSize:Int = getCellSize();
		
		var icons_size:Int = 16;
		var icons_x:Int = Std.int((cellSize / 2) - (icons_size / 2)) - 3;
		var icons_y:Int = icons_x;

		var slot = getEquipmentTypeInfo(typeName);
		var icon = SpriteEquipmentIcons.getIcon(slot.icon, icons_size, 2.0);
		icon.x = icons_x;
		icon.y = icons_y;
		icon.setAlpha(0.3);
		return icon;
		
		return null;
	}
		
	public function new(equipSlots:Array<String>, ?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super(X, Y, Width, Height);

		var cellBgKey:CqGraphicKey = CqGraphicKey.EquipmentCellBG;
		var cellBgHighlightKey:CqGraphicKey = CqGraphicKey.EqCellBGHighlight;
		var cellGlowKey:CqGraphicKey = CqGraphicKey.CellGlow;

		var cell:CqInventoryCell;
		
		var cellSize:Int = getCellSize();
		
		for (idx in 0...equipSlots.length)	{
			cell = new CqInventoryCell(getEquipmentTypeInfo(equipSlots[idx]).type, cell_positions[HxlGraphics.smallScreen ? 0 : 1][idx][0] - 5, cell_positions[HxlGraphics.smallScreen ? 0 : 1][idx][1] - 5, cellSize, cellSize);

			cell.setGraphicKeys(cellBgKey, cellBgHighlightKey, cellGlowKey);
			
			var icon = getIcon(equipSlots[idx]);
			cell.add(icon);
			cell.icon = icon;
			add(cell);
			cells.push(cell);
			
			icon = null;
			cell = null;
		}
	}
}


class CqPotionGrid extends CqInventoryGrid {
	var belt:HxlSprite;
	
	public function new(numberOfCells:Int, ?X:Float = 0, ?Y:Float = 0, ?Width:Float = 100, ?Height:Float = 100) {
		super(X, Y, Width, Height);
		
		belt = new HxlSprite(0, 0);
		belt.zIndex = -1;
		
		if (HxlGraphics.smallScreen) {
			belt.loadGraphic(MobileUiBeltHorizontal, false, false, 340, 37);
		} else {
			belt.loadGraphic(UiBeltHorizontal, false, false, 460, 71);
		}
		
		add(belt);

		var cellBgKey:CqGraphicKey = CqGraphicKey.EquipmentCellBG;
		var cellBgHighlightKey:CqGraphicKey = CqGraphicKey.EqCellBGHighlight;

		var offsetX:Int = HxlGraphics.smallScreen ? 0 : 50;
		var offsetY:Int = 2;
		var btnSize:Int = 64;
		var halfPadding:Int = HxlGraphics.smallScreen ? 1 : 5;
		
		for ( i in 0...numberOfCells ) {
			var cell:CqInventoryCell = new CqInventoryCell(POTION, offsetX + (i * (btnSize + 2 * halfPadding)), offsetY, btnSize, btnSize);
			cell.extendOverlap = new HxlRect( -halfPadding, -9, halfPadding, 100); // the 100 is arbitrary -- it just means "to the bottom edge"
			
			add(cell);
			cell.setGraphicKeys(CqGraphicKey.EquipmentCellBG, CqGraphicKey.EqCellBGHighlight, CqGraphicKey.CellGlow);
			cell.setPopupHint( (6+i)%10 );
			cells.push(cell);
		}
		
		if (!HxlGraphics.smallScreen) {
			initButtons();
		}
		
		extendOverlap = new HxlRect( 0, 0, 0, 100);
	}
	
	private function initButtons():Void  {
		//menu/help
		var MenuSprite = new ButtonSprite();
		var MenuSpriteH = new ButtonSprite();
		var HelpSprite = new ButtonSprite();
		var HelpSpriteH = new ButtonSprite();
		_point.x = 0.44;
		_point.y = 1;
		
		MenuSpriteH.setAlpha(0.6);
		HelpSpriteH.setAlpha(0.6);
		
		MenuSprite.scale = MenuSpriteH.scale = _point.clone();
		HelpSprite.scale = HelpSpriteH.scale = _point.clone();
		
		var btnSize:Int = 64;
		var menuButton:HxlButton = new HxlButton(4, 2, Std.int(_point.x * btnSize), Std.int(_point.y * btnSize), pressMenu);
		var helpButton:HxlButton = new HxlButton(Std.int(width-66), 2, Std.int(_point.x * btnSize), Std.int(_point.y * btnSize),pressHelp);
		helpButton.loadGraphic(HelpSprite,HelpSpriteH);
		menuButton.loadGraphic(MenuSprite,MenuSpriteH);
		helpButton.configEvent(5, true, true);
		menuButton.configEvent(5, true, true);
		
#if japanese		
		helpButton.loadText(new HxlText( 8, 32, btnSize, Resources.getString( "MENU_HELP" ), true).setFormat(FontDungeon.instance.fontName, 23, 0xffffff, "center", 0x010101));
		menuButton.loadText(new HxlText( -8, 32, btnSize, Resources.getString( "MENU_MENU" ), true).setFormat(FontDungeon.instance.fontName, 23, 0xffffff, "center", 0x010101));
#else
		helpButton.loadText(new HxlText(15, 32, btnSize, Resources.getString( "MENU_HELP" ), true).setFormat(FontDungeon.instance.fontName, 23, 0xffffff, "center", 0x010101));
		menuButton.loadText(new HxlText( -14, 32, btnSize, Resources.getString( "MENU_MENU" ), true).setFormat(FontDungeon.instance.fontName, 23, 0xffffff, "center", 0x010101));
#end
		helpButton.getText().angle = 90;
		menuButton.getText().angle = -90;
		
		var pop:CqPopup;
		pop = new CqPopup(150, Resources.getString("POPUP_ESC"), GameUI.instance.popups);
		pop.zIndex = 15;
		menuButton.setPopup(pop);
		GameUI.instance.popups.add(pop);
		pop = new CqPopup(150, Resources.getString("POPUP_F1"), GameUI.instance.popups);
		pop.zIndex = 15;
		helpButton.setPopup(pop);
		GameUI.instance.popups.add(pop);
		
		menuButton.extendOverlap.x = -16;
		menuButton.extendOverlap.width = 4;
		
		helpButton.extendOverlap.x = -4;
		helpButton.extendOverlap.width = 16;
		
		add(helpButton);
		add(menuButton);
	}
	
	public function pressHelp(?playSound:Bool = true):Void {
		GameUI.showInvHelp = false;
		if (Std.is(HxlGraphics.getState(), GameState))
		{
			GameUI.instance.setActive();
			if (GameUI.instance.panels.currentPanel == GameUI.instance.panels.panelInventory) {
				if (playSound)
					SoundEffectsManager.play(MenuItemClick);
				GameUI.showInvHelp = true;
			}
			else if(GameUI.instance.panels.currentPanel != null){
				if (playSound)
					SoundEffectsManager.play(MenuItemClick);
				GameUI.instance.panels.hideCurrentPanel(pressHelp);
				return;
			}
			HxlGraphics.pushState(HelpState.instance);
		}
	}
	
	public function pressMenu(?playSound:Bool = false):Void	{
		if (Std.is(HxlGraphics.getState(), GameState)) {
			if (playSound)
				SoundEffectsManager.play(MenuItemClick);
			
			if (GameUI.instance.panels.currentPanel != null) {
				GameUI.instance.panels.hideCurrentPanel(pressMenu);
			} else {
				GameUI.instance.setActive(false);
				HxlGraphics.pushState(new MainMenuState());
			}
		}
	}
}


class CqSpellGrid extends CqInventoryGrid {
	var belt:HxlSprite;

	public function new(numberOfCells:Int, ?X:Int=0, ?Y:Int=0, ?Width:Int=100, ?Height:Int=100) {
		super(X, Y, Width, Height);

		var cellBgKey:CqGraphicKey = CqGraphicKey.EquipmentCellBG;
		var cellBgHighlightKey:CqGraphicKey = CqGraphicKey.EqCellBGHighlight;

		var btnSize:Int = 64;
		var halfPadding:Int = HxlGraphics.smallScreen ? -3 : 5;
		
		if (HxlGraphics.smallScreen) {
			belt = new HxlSprite(6, -10);
			belt.zIndex = 0;
			belt.loadGraphic(MobileUiBeltVertical, true, false, 71, 320, false);
		} else {
			belt = new HxlSprite(6, -13);
			belt.zIndex = 0;
			belt.loadGraphic(UiBeltVertical, true, false, 71, 406, false);
		}
		belt.setFrame(0);
		
		add(belt);
		
		for ( i in 0...numberOfCells ) {
			var cell:CqInventoryCell = new CqInventoryCell(SPELL, 10, 10 + i * (btnSize + 2 * halfPadding), btnSize, btnSize);
			cell.extendOverlap = new HxlRect( -9, -halfPadding, 100, halfPadding); // the 100 is arbitrary -- it just means "to the right edge"
			
			cell.zIndex = 1;
			
			add(cell);
			cell.setGraphicKeys(CqGraphicKey.EquipmentCellBG, CqGraphicKey.EqCellBGHighlight, CqGraphicKey.CellGlow);
			cell.setPopupHint( 1+i );
			cells.push(cell);
		}
		
		extendOverlap = new HxlRect( 0, 0, 100, 0);
	}
}
