package cq.ui.bag;

import haxel.HxlDialog;
import haxel.HxlPoint;
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





// the inventory proxy is really ugly and not rewritten at all -- no, seriously, terrible.  fix it.
// this is certainly still necessary -- but it will take a little more work to refine it thoroughly

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
	}

	override private function dragStart() {
		// indicate that this is the item being dragged
		CqInventoryProxy.theProxyBeingDragged = this;
		zIndex = 15;
		
		item.itemSlot.cell.remove(this);
		GameUI.instance.doodads.add(this);
		GameUI.instance.popups.remove(namePopup);
		
		// setting the zIndex doesn't suffice -- we need to attach this to the stage, instead
	}
	
	override private function dragStop() {
		GameUI.instance.doodads.remove(this);
		GameUI.instance.popups.add(namePopup);
		
		if (CqInventoryCell.theCellBeingHoveredOver != null && CqInventoryCell.theCellBeingHoveredOver != item.itemSlot.cell) {
			// type checking is done before CqInventoryCell.theCellBeingHoveredOver is ever set to non-null
			// (if it were not, it would be possible to make items disappear)
			
			var myOldSlot = item.itemSlot;
			var myItem = myOldSlot.item;
			var itsItem = CqInventoryCell.theCellBeingHoveredOver.slot.item;
			
			CqInventoryCell.theCellBeingHoveredOver.slot.item = myItem;
			myOldSlot.item = itsItem;
		} else {
			item.itemSlot.cell.add(this);
			
			x = dragStartPoint.x;
			y = dragStartPoint.y;
		}
		
		zIndex = 5;
		
		CqInventoryProxy.theProxyBeingDragged = null;
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
		chargeArcBitmap.fillRect(clearChargeRect, 0x0);
		chargeArcBitmap.draw(chargeShape, null, ctrans);

		if (ctrans == null) {
			ctrans = new ColorTransform();
			ctrans.alphaMultiplier = 0.5;
		}

		chargeArcSprite.loadSuppliedGraphic(chargeArcBitmap);
		chargeArcSprite.visible = true;
	}	
	
	public function updateCharge() {
		var chargeBmp:Bitmap = new Bitmap(GraphicCache.getBitmap(CqGraphicKey.EquipmentCellBG));
		var chargeShape:Shape = new Shape();

		var statPoints = 0;
		var statPointsRequired = 1;
		
		var spell = cast(item, CqSpell);
		
		var start = -Math.PI / 2;
		var end = 2*Math.PI * (3/4 - spell.statPoints / spell.statPointsRequired);
			
		var G = chargeShape.graphics;
		G.clear();
		G.beginFill(0x55000000);
		drawChargeArc(G, 27, 27, start, end, 47, -1);
		G.endFill();
		G = null;

		chargeShape.mask = chargeBmp;
		
		updatechargeArcSprite(chargeShape);
		
		chargeBmp = null;
		chargeShape = null;
	}
	
	public override function update() {
		super.update();
		if (chargeArcSprite != null) {
			chargeArcSprite.x = x;
			chargeArcSprite.y = y;
		}
	}

	public static function drawChargeArc(G:Graphics, centerX:Float, centerY:Float, startAngle:Float, endAngle:Float, radius:Float, direction:Int) {
		var difference:Float = Math.abs(endAngle - startAngle);
		var divisions:Int = Math.floor(difference / (Math.PI / 4))+1;
		var span:Float = direction * difference / (2 * divisions);
		var controlRadius:Float = radius / Math.cos(span);
		//G.moveTo(centerX + (Math.cos(startAngle)*radius), centerY + Math.sin(startAngle)*radius);
		G.moveTo(centerX, centerY);
		G.lineTo(centerX + (Math.cos(startAngle)*radius), centerY + Math.sin(startAngle)*radius);
		var controlPoint:Point;
		var anchorPoint:Point;
		for ( i in 0...divisions ) {
			endAngle = startAngle + span;
			startAngle = endAngle + span;
			controlPoint = new Point(centerX+Math.cos(endAngle)*controlRadius, centerY+Math.sin(endAngle)*controlRadius);
			anchorPoint = new Point(centerX+Math.cos(startAngle)*radius, centerY+Math.sin(startAngle)*radius);
			G.curveTo( controlPoint.x, controlPoint.y, anchorPoint.x, anchorPoint.y );
			controlPoint = null;
			anchorPoint = null;
		}
		G.lineTo(centerX, centerY);
	}
}




class CqInventoryCell extends HxlDialog {
	public var proxy (getProxy, setProxy):CqInventoryProxy;
	public var slot (default, default):CqItemSlot; // this is managed by CqBag and is only set when the cell (which is a ui element) is associated with a slot (which is a logical location in the player's bag)
	
	public var associatedButton(default, null):HxlButton;  // temporary ?
	public var equipType(default, null):CqEquipSlot;
	
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
		icon.x += 13;
		icon.y += 3;
			
		var droptext:HxlText = new HxlText(-5, 35, Std.int(width), "Destroy");
		droptext.setFormat(FontAnonymousPro.instance.fontName, 12, 0xffffff, "center", 0x010101);
		droptext.zIndex = 10;
		droptext.setAlpha(0.3);
		add(droptext);
	}
	
	public override function update() {
		super.update();
		
		if (_proxy != null && CqInventoryProxy.theProxyBeingDragged != _proxy) {
			// this is a workaround for a strange absolute/relative positioning bug in haxel
			_proxy.x = x + 9;
			_proxy.y = y + 7;
		}
		
		if (isDraggedItemAcceptable() && isDraggedItemHoveringHere()) {
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
			var myX = x + origin.x;
			var myY = y + origin.y;
			var objX = HxlGraphics.mouse.dragSprite.x;
			var objY = HxlGraphics.mouse.dragSprite.y;
			var objW = HxlGraphics.mouse.dragSprite.width;
			var objH = HxlGraphics.mouse.dragSprite.height;
			
			if ((myX <= objX) || (myX >= objX + objW) || (myY <= objY) || (myY >= objY + objH) ) {
				return false;
			} else {			
				theCellBeingHoveredOver = this;
				return true;
			}
		} else {
			return false;
		}
	}

	public function setGlow(glow:Bool) {
		bgGlow.visible = glow;
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
		
		return _proxy;
	}

	private function getProxy():CqInventoryProxy {
		return _proxy;
	}
}

class CqTriggerButton extends HxlDialog {
	public var cell(default, null):CqInventoryCell;

	var handlersAdded:Bool;

	public function new(itemType:CqEquipSlot, X:Int, Y:Int, ?Width:Int = 100, ?Height:Int = 20) {
		super(0, 0, Width, Height);
		
		var btnSprite = new ButtonSprite();
		this.setBackgroundSprite(btnSprite);

		handlersAdded = false;

		cell = new CqInventoryCell(itemType, X, Y, 54, 54);
		cell.setGraphicKeys(CqGraphicKey.EquipmentCellBG,CqGraphicKey.EqCellBGHighlight,CqGraphicKey.CellGlow);
		
		this.zIndex = 5;
		cell.zIndex = 1;
		
		cell.add(this);
	}

	public override function update() {
		if (!handlersAdded) {
			if (HxlGraphics.stage != null) {
				addEventListener(MouseEvent.MOUSE_DOWN, clickMouseDown, true, 6,true);
				addEventListener(MouseEvent.MOUSE_UP, clickMouseUp, true, 6,true);
				handlersAdded = true;
			}
		}

		super.update();
	}

	override public function overlapsPoint(X:Float,Y:Float,?PerPixel:Bool = false):Bool {

		//This is totally messed up, but it works..
		//I suspect this is for the same reason that I cannot trust
		//HxlGraphics.mouse.x/y to have the right value
		if( !Configuration.mobile ) {
			X += HxlUtil.floor(HxlGraphics.scroll.x);
			Y += HxlUtil.floor(HxlGraphics.scroll.y);
		}

		getScreenXY(_point);
		if ((X <= _point.x) || (X >= _point.x+width) || (Y <= _point.y) || (Y >= _point.y+height)) {
			return false;
		}
		return true;
	}

	function clickMouseDown(event:MouseEvent) {
		if (!exists || !visible || !active || !Std.is(HxlGraphics.state,GameState) ) {
			return;
		}

		if (Configuration.mobile) {
			HxlGraphics.mouse.x = Std.int(event.localX);
			HxlGraphics.mouse.y = Std.int(event.localY);
		}		
		
		if (!Std.is(GameUI.instance.panels.currentPanel, SlidingBagDialog)) {
			if (overlapsPoint(HxlGraphics.mouse.x, HxlGraphics.mouse.y)) {
				event.stopPropagation();
				activateItem();
			}
		} else {
			// we are in the inventory screen
			if (Configuration.mobile) {
				// instead of drag-n-drop, tap two cells to switch their contents
			}
		}
	}
	
	public function activateItem() {
		if (cell.proxy != null) {
			var item:CqItem = cell.proxy.item;
			
			if (item.isReadyToActivate) {
				HxlLog.append("Using an item");
				item.tryToActivate();
			}
		}
	}

	function clickMouseUp(event:MouseEvent) {
		if (!exists || !visible || !active || Std.is(GameUI.instance.panels.currentPanel, BagDialog) )
			return;
		
		if (overlapsPoint(HxlGraphics.mouse.x,HxlGraphics.mouse.y)) {
			//if ( _callback != null ) _callback();
			//if ( clickSound != null ) clickSound.play();
			//if ( eventStopPropagate ) event.stopPropagation();
			// event.stopPropagation();
		}
	}
}


class CqInventoryGrid extends HxlDialog {
	public var cells:Array<CqInventoryCell>;
	
	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super(X, Y, Width, Height);
		
		cells = [];
	}
	
	override public function kill():Void {
		for (cell in cells) {
			if (cell.proxy != null) cell.proxy.destroy();
			cell.kill();
		}
		cells = null;
		
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
	
		var paddingX:Int = 3;
		var paddingY:Int = 10;
		var cellSize:Int = 64;
		var offsetX:Int = 0;

		var rows:Int = 2;
		var cols:Int = Math.floor((numberOfCells + 1) / 2);
		var btn:ButtonSprite;
		for ( row in 0...rows ) {
			for ( col in 0...cols ) {
				var idx:Int = cells.length;
				var _x:Int = offsetX + ((col) * paddingX) + (col * cellSize);
				var _y:Int = ((row) * paddingY) + (row * cellSize);
				
				var cell:CqInventoryCell = new CqInventoryCell(null, _x, _y, cellSize, cellSize);
				btn = new ButtonSprite();
				
				cell.add(btn);
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
	
	static var cell_positions = [
		[8, 183], [8, 100],
		[8, 12], [159, 183],
		[159, 100], [159, 12]
	];
	
	static var cellSize:Int = 54;
	static var padding:Int = 8;	
	
	
	public function getEquipmentTypeInfo(typeName:String) {
		for (slot in slotNames) {
			if (slot.icon == typeName) {
				return slot;
			}
		}
		
		return null;
	}
	
	public function getIcon(typeName:String):HxlSprite {
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
		
		var btn:ButtonSprite;
		for (idx in 0...equipSlots.length)	{
			cell = new CqInventoryCell(getEquipmentTypeInfo(equipSlots[idx]).type, cell_positions[idx][0] - 5, cell_positions[idx][1] - 5, cellSize, cellSize);
			btn = new ButtonSprite();
			cell.add(btn);
			cell.setGraphicKeys(cellBgKey, cellBgHighlightKey, cellGlowKey);
			
			var icon = getIcon(equipSlots[idx]);
			cell.add(icon);
			cell.icon = icon;
			add(cell);
			cells.push(cell);
			
			icon = null;
			btn = null;
			cell = null;
		}
	}
	
	public function setGlowForSlot(equipType:CqEquipSlot, value:Bool) {
		for (cell in cells) {
			if ( equipType == cell.equipType ) {
				cell.setGlow(value);
			}
		}
	}
}


class CqPotionGrid extends CqInventoryGrid {
	var belt:HxlSprite;
	
	public function new(numberOfCells:Int, ?X:Float = 0, ?Y:Float = 0, ?Width:Float = 100, ?Height:Float = 100) {
		super(X, Y, Width, Height);
		
		belt = new HxlSprite(0, 0);
		belt.zIndex = -1;
		belt.loadGraphic(UiBeltHorizontal, false, false, 460, 71);
		
		add(belt);

		var cellBgKey:CqGraphicKey = CqGraphicKey.EquipmentCellBG;
		var cellBgHighlightKey:CqGraphicKey = CqGraphicKey.EqCellBGHighlight;

		var offsetX:Int = 50;
		var offsetY:Int = 2;
		var btnSize:Int = 64;
		var padding:Int = 18;		
		
		for ( i in 0...numberOfCells ) {
			var btnCell:CqTriggerButton = new CqTriggerButton(POTION, offsetX + (i * (btnSize+10)), offsetY, btnSize, btnSize);
			add(btnCell.cell);
			cells.push(btnCell.cell);
			
			//var cell:CqInventoryCell = new CqInventoryCell(POTION, offsetX + (i * (btnSize + 10)), offsetY, btnSize, btnSize);
			//add(cell);
			//cells.push(cell);
		}
		
		initButtons();
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
		
		helpButton.loadText(new HxlText(15, 32, btnSize, "Help", true).setFormat(FontDungeon.instance.fontName, 23, 0xffffff, "center", 0x010101));
		helpButton.getText().angle = 90;
		
		menuButton.loadText(new HxlText(-14, 32, btnSize, "Menu", true).setFormat(FontDungeon.instance.fontName, 23, 0xffffff, "center", 0x010101));
		menuButton.getText().angle = -90;
		
		var pop:CqPopup;
		pop = new CqPopup(150,"[hotkey ESC]", GameUI.instance.popups);
		pop.zIndex = 15;
		menuButton.setPopup(pop);
		GameUI.instance.popups.add(pop);
		pop = new CqPopup(150,"[hotkey F1]", GameUI.instance.popups);
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
	public var buttons:Array<CqTriggerButton>;	
	var belt:HxlSprite;

	public function clearCharge(cellNumber :Int) {
		var button:CqTriggerButton = buttons[cellNumber];
		if(button.cell.proxy != null && Std.is(button.cell.proxy.item, CqSpell)) {
			cast(button.cell.proxy.item, CqSpell).statPoints = 0;
			// button.updatechargeArcSprite
		}
		// GameUI.instance.updateCharge(buttons[Cell]);
	}
	
	public function new(numberOfCells:Int, ?X:Int=0, ?Y:Int=0, ?Width:Int=100, ?Height:Int=100) {
		super(X, Y, Width, Height);

		var cellBgKey:CqGraphicKey = CqGraphicKey.EquipmentCellBG;
		var cellBgHighlightKey:CqGraphicKey = CqGraphicKey.EqCellBGHighlight;

		var btnSize:Int = 64;
		var padding:Int = 8;
		buttons = [];
		
		belt = new HxlSprite(6, -13);
		belt.zIndex = 0;
		belt.loadGraphic(UiBeltVertical, true, false, 71, 406, false);
		belt.setFrame(0);
		
		add(belt);
		
		for ( i in 0...numberOfCells ) {
			var btnCell:CqTriggerButton = new CqTriggerButton(SPELL, 10, 10 + ((i * btnSize) + (i * 10)), btnSize, btnSize);
			
			btnCell.zIndex = 1;
			
			add(btnCell.cell);
			cells.push(btnCell.cell);
			buttons.push(btnCell);
		}
	}
}
