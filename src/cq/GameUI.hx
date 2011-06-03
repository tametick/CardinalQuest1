package cq;

import cq.CqActor;
import cq.CqEffectChest;
import cq.CqEffectInjure;
import cq.CqFloatText;
import cq.CqInventoryDialog;
import cq.CqItem;
import cq.CqPotionButton;
import cq.CqSpell;
import cq.CqSpellButton;
import cq.CqWorld;
import cq.CqVitalBar;

import data.Configuration;
import data.Registery;

import world.Player;
import world.Tile;
import world.World;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Shape;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import haxel.HxlButton;
import haxel.HxlButtonContainer;
import haxel.HxlDialog;
import haxel.HxlGradient;
import haxel.HxlGraphics;
import haxel.HxlObjectContainer;
import haxel.HxlPoint;
import haxel.HxlSlidingDialog;
import haxel.HxlSprite;
import haxel.HxlText;
import haxel.HxlTextContainer;
import haxel.HxlUIBar;

class GameUI extends HxlDialog {

	// Main UI containers
	var leftButtons:HxlButtonContainer;
	var dlgSpellGrid:CqSpellGrid;
	var dlgPotionGrid:CqPotionGrid;

	// View state panels
	var panelMap:CqMapDialog;
	var panelInventory:CqInventoryDialog;
	var panelCharacter:CqCharacterDialog;
	var panelLog:CqMessageDialog;

	// Left side button panel
	var btnMainView:HxlButton;
	var btnMapView:HxlButton;
	var btnInventoryView:HxlButton;
	var btnCharacterView:HxlButton;
	var btnLogView:HxlButton;

	// Misc UI elements
	var xpBar:CqXpBar;
	var targetSprite:HxlSprite;
	var targetText:HxlText;

	// State & helper vars
	public static var currentPanel:HxlSlidingDialog = null;
	public static var isTargeting:Bool = false;
	public static var targetString:String = "";
	public static var targetSpell:CqSpellButton = null;
	var targetLastPos:HxlPoint;
	public static var instance:GameUI = null;
	
	public override function new() {
		super(0, 0, HxlGraphics.width, HxlGraphics.height);

		isTargeting = false;
		targetLastPos = null;
		targetString = "";
		targetSpell = null;
		currentPanel = null;
		targetSprite = null;
		targetText = null;
		GameUI.instance = this;
		var self = this;

		/**
		 * Create and cache graphics for use by UI widgets
		 **/
		initUIGraphics();

		/**
		 * Create and init main containers
		 **/
		leftButtons = new HxlButtonContainer(0, 30, 84, 380, HxlButtonContainer.VERTICAL, HxlButtonContainer.TOP_TO_BOTTOM, 10, 10);
		//leftButtons.setBackgroundColor(0x99555555, 10);
		leftButtons.scrollFactor.x = leftButtons.scrollFactor.y = 0;
		add(leftButtons);

		dlgSpellGrid = new CqSpellGrid(HxlGraphics.width-84, 30, 84, 380);
		add(dlgSpellGrid);

		dlgPotionGrid = new CqPotionGrid(130, HxlGraphics.height-84, 380, 84);
		add(dlgPotionGrid);

		/**
		 * View state panels
		 **/
		panelMap = new CqMapDialog(84, 0, 472, 480);
		panelMap.setBackgroundColor(0xff9A9DBC);
		panelMap.zIndex = 2;
		add(panelMap);

		// -62 472x480
		panelInventory = new CqInventoryDialog(this, 84, 0, 472, 400);
		panelInventory.setBackgroundColor(0xffBC9A9A);
		panelInventory.zIndex = 2;
		add(panelInventory);

		panelCharacter = new CqCharacterDialog(84, 0, 472, 480);
		panelCharacter.setBackgroundColor(0xffa5a5a5);
		panelCharacter.zIndex = 2;
		add(panelCharacter);

		panelLog = new CqMessageDialog(84, 0, 472, 480);
		panelLog.setBackgroundColor(0xffBCB59A);
		panelLog.zIndex = 2;
		add(panelLog);

		/**
		 * Left side panel buttons
		 **/
		btnMainView = new HxlButton(0, 0, 64, 64);
		btnMainView.setBackgroundColor(0xff999999, 0xffcccccc);
		btnMainView.loadText(new HxlText(0, 23, 64, "Main", true, null).setFormat(null, 18, 0xffffff, "center", 0x010101));
		btnMainView.setCallback(function() {
			self.showPanel(null, self.btnMainView);
		});
		btnMainView.configEvent(5, true, true);
		btnMainView.setActive(true);
		leftButtons.addButton(btnMainView);
		//
		btnMainView.visible = false;
		//

		btnMapView = new HxlButton(0, 0, 64, 64);
		btnMapView.setBackgroundColor(0xff999999, 0xffcccccc);
		btnMapView.loadText(new HxlText(0, 23, 64, "Map", true, null).setFormat(null, 18, 0xffffff, "center", 0x010101));
		btnMapView.setCallback(function() {
			self.showPanel(self.panelMap, self.btnMapView);
		});
		btnMapView.configEvent(5, true, true);
		leftButtons.addButton(btnMapView);

		btnInventoryView = new HxlButton(0, 0, 64, 64);
		btnInventoryView.setBackgroundColor(0xff999999, 0xffcccccc);
		btnInventoryView.loadText(new HxlText(0, 23, 64, "Inv", true, null).setFormat(null, 18, 0xffffff, "center", 0x010101));
		btnInventoryView.setCallback(function() {
			self.showPanel(self.panelInventory, self.btnInventoryView);
		});
		btnInventoryView.configEvent(5, true, true);
		leftButtons.addButton(btnInventoryView);

		btnCharacterView = new HxlButton(0, 0, 64, 64);
		btnCharacterView.setBackgroundColor(0xff999999, 0xffcccccc);
		btnCharacterView.loadText(new HxlText(0, 23, 64, "Char", true, null).setFormat(null, 18, 0xffffff, "center", 0x010101));
		btnCharacterView.setCallback(function() {
			self.showPanel(self.panelCharacter, self.btnCharacterView);
		});
		btnCharacterView.configEvent(5, true, true);
		leftButtons.addButton(btnCharacterView);

		btnLogView = new HxlButton(0, 0, 64, 64);
		btnLogView.setBackgroundColor(0xff999999, 0xffcccccc);
		btnLogView.loadText(new HxlText(0, 23, 64, "Log", true, null).setFormat(null, 18, 0xffffff, "center", 0x010101));
		btnLogView.setCallback(function() {
			self.showPanel(self.panelLog, self.btnLogView);
		});
		btnLogView.configEvent(5, true, true);
		leftButtons.addButton(btnLogView);
		//
		btnLogView.visible = false;
		//

		panelInventory.dlgSpellGrid = dlgSpellGrid;
		panelInventory.dlgPotionGrid = dlgPotionGrid;
	}

	public override function update() {
		super.update();
		updateCharges();
	}

	public function updateCharges() {
		var player = cast(Registery.player, CqPlayer);
		for ( btn in dlgSpellGrid.buttons ){
			if (btn.getSpell() != null) {				
				updateCharge(btn);
			}
		}
	}
	
	var chrageBmp:Bitmap;
	var chrageShape:Shape;
	public function updateCharge(btn:CqSpellButton, ?forcedValue:Int=-1) {
		var spiritPoints = forcedValue;
		var spiritPointsRequired = 360;
		if (btn.getSpell() != null){
			spiritPoints = btn.getSpell().spiritPoints;
			spiritPointsRequired = btn.getSpell().spiritPointsRequired;
		}

		var end:Float = (((Math.PI / 2) * 3) - (-(Math.PI/2))) * (spiritPoints / spiritPointsRequired);
		end = ((Math.PI / 2) * 3) - end;
		
		if(chrageShape==null)
			chrageShape = new Shape();
			
		var G = chrageShape.graphics;
		
		G.clear();
		
		G.beginFill(0x88ff0000);
		GameUI.drawChargeArc(G, 27, 27, -(Math.PI/2), end, 47, -1);
		G.endFill();
		if(chrageBmp == null)
			chrageBmp = new Bitmap(HxlGraphics.getBitmap("EquipmentCellBG"));
		chrageShape.mask = chrageBmp;
		
		//var bmpdata:BitmapData = new BitmapData(94, 94, true, 0x0);
		btn.chrageBmpData.fillRect(CqSpellButton.clearChargeRect, 0x0);
		
		
		var ctrans:ColorTransform = new ColorTransform();
		ctrans.alphaMultiplier = 0.5;
		btn.chrageBmpData.draw(chrageShape, null, ctrans);
		HxlGraphics.addBitmapData(btn.chrageBmpData, "chargeRadial", true);

		btn.updateChargeSprite("chargeRadial");
	}

	public static function drawChargeArc(G:Graphics, centerX:Float, centerY:Float, startAngle:Float, endAngle:Float, radius:Float, direction:Int):Void {
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
		}
		G.lineTo(centerX, centerY);
	}


	function showPanel(Panel:HxlSlidingDialog, ?Button:HxlButton=null):Void {
		if ( HxlGraphics.mouse.dragSprite != null ) return;
		// If user was in targeting mode, cancel it
		if ( GameUI.isTargeting ) GameUI.setTargeting(false);

		if ( Button != null ) {
			btnMainView.setActive(false);
			btnMapView.setActive(false);
			btnInventoryView.setActive(false);
			btnCharacterView.setActive(false);
			btnLogView.setActive(false);
			Button.setActive(true);
		}
		if ( Panel == null ) {
			if ( currentPanel != null ) {
				currentPanel.hide(function() { GameUI.currentPanel = null; });
			}
		} else {
			if ( currentPanel == null ) {
				currentPanel = Panel;
				Panel.show();
			} else {
				if ( currentPanel != Panel ) {
					// A view state other than main is already active.. Hide that one first before showing the selected one
					currentPanel.hide(function() {
						GameUI.currentPanel = Panel;
						GameUI.currentPanel.show();
					});
				} else {
					// User clicked on a view state button which is already active, switch back to main view state
					if ( currentPanel != null ) {
						currentPanel.hide(function() { GameUI.currentPanel = null; });
						btnMainView.setActive(true);
						btnMapView.setActive(false);
						btnInventoryView.setActive(false);
						btnCharacterView.setActive(false);
						btnLogView.setActive(false);
					}
				}
			}
		}
	}

	public function initUIGraphics():Void {
		var cellBgKey:String = "InventoryCellBG";
		if ( !HxlGraphics.checkBitmapCache(cellBgKey) ) {
			HxlGraphics.addBitmapData(HxlGradient.RectData(54, 54, [0x333333, 0x555555], null, Math.PI/2, 5.0), cellBgKey);
		}
		
		var cellBgKey:String = "DropCellBG";
		if ( !HxlGraphics.checkBitmapCache(cellBgKey) ) {
			HxlGraphics.addBitmapData(HxlGradient.RectData(54, 54, [0x883333, 0xcc5555], null, Math.PI/2, 5.0), cellBgKey);
		}

		var cellBgHighlightKey:String = "CellBGHighlight";
		if ( !HxlGraphics.checkBitmapCache(cellBgHighlightKey) ) {
			HxlGraphics.addBitmapData(HxlGradient.RectData(54, 54, [0x686835, 0xADAB6B], null, Math.PI/2, 5.0), cellBgHighlightKey);
		}
		
		var cellBgHighlightKey:String = "DropCellBGHighlight";
		if ( !HxlGraphics.checkBitmapCache(cellBgHighlightKey) ) {
			HxlGraphics.addBitmapData(HxlGradient.RectData(54, 54, [0x996835, 0xFDAB6B], null, Math.PI/2, 5.0), cellBgHighlightKey);
		}

		var itemBgKey:String = "ItemBG";
		if ( !HxlGraphics.checkBitmapCache(itemBgKey) ) {
			//HxlGraphics.addBitmapData(HxlGradient.RectData(50, 50, [0xc1c1c1, 0x9e9e9e], null, [0.0, 0.0], Math.PI / 2, 8.0), itemBgKey);
			HxlGraphics.addBitmapData(HxlGradient.CircleData(25, [0xc1c1c1, 0x9e9e9e],null,[0.5,0.0]),itemBgKey);
		}

		var itemSelectedBgKey:String = "ItemSelectedBG";
		if ( !HxlGraphics.checkBitmapCache(itemSelectedBgKey) ) {
			//HxlGraphics.addBitmapData(HxlGradient.RectData(50, 50, [0xEFEDBC, 0xB9B99A], null, [0.0, 0.0], Math.PI / 2, 8.0), itemSelectedBgKey);
			HxlGraphics.addBitmapData(HxlGradient.CircleData(25, [0xc1c1c1, 0x9e9e9e],null,[0.5,0.0]),itemSelectedBgKey);
		}

		var cellBgKey:String = "EquipmentCellBG";
		if ( !HxlGraphics.checkBitmapCache(cellBgKey) ) {
			HxlGraphics.addBitmapData(HxlGradient.RectData(54, 54, [0x333333, 0x555555], null, [0.0,0.0], Math.PI/2, 5.0), cellBgKey);
		}

		var cellBgHighlightKey:String = "EqCellBGHighlight";
		if ( !HxlGraphics.checkBitmapCache(cellBgHighlightKey) ) {
			HxlGraphics.addBitmapData(HxlGradient.RectData(54, 54, [0xFFCC00, 0xFFFF99], null, [0.5,0.5],Math.PI/2, 5.0), cellBgHighlightKey);
		}

		var tmp:BitmapData = new BitmapData(79, 79, true, 0x0);
		tmp.copyPixels(HxlGraphics.getBitmap("InventoryCellBG"), new Rectangle(0, 0, 54, 54), new Point(19, 19), null, null, true);
		var glow:GlowFilter = new GlowFilter(0x00ff00, 0.9, 15.0, 15.0, 1.6, 1, false, true);
		tmp.applyFilter(tmp, new Rectangle(0, 0, 79, 79), new Point(0, 0), glow);
		HxlGraphics.addBitmapData(tmp, "CellGlow");
	}

	public function checkTileItems(Player:CqPlayer):Void {
		var curPos:HxlPoint = Player.getTilePos();
		var curTile = cast(Registery.level.getTile(Std.int(curPos.x), Std.int(curPos.y)), Tile);
		if ( curTile.loots.length > 0 ) {
			if (panelInventory.getEmptyCell() == null) {
				// todo - show visual/audio feedback that inv is full
				// todo - move this check to player.pickup
				return;
			}
			
			var item = cast(curTile.loots[curTile.loots.length - 1], CqItem);
			Player.pickup(HxlGraphics.state, item);
		}
	}
	
	public function itemPickup(Item:CqItem):Void {
		if(panelInventory.itemPickup(Item))
			btnInventoryView.doFlash();
	}

	public function initChests():Void {
		for ( Item in Registery.level.loots ) {
			if ( Std.is(Item, CqChest) ) {
				cast(Item, CqChest).addOnBust(function(Target:CqChest) {
					var eff:CqEffectChest = new CqEffectChest(Target.x + Target.origin.x, Target.y + Target.origin.y);
					eff.zIndex = 6;
					HxlGraphics.state.add(eff);
					eff.start(true, 1.0, 10);
				});
			}
		}
	}
	
	public function initHealthBars():Void {
		for ( actor in Registery.level.mobs ) {
			addHealthBar(cast(actor, CqActor));
		}
	}

	public function addHealthBar(Actor:CqActor):Void {
		var bar:CqHealthBar = new CqHealthBar(Actor, Actor.x, Actor.y + Actor.height + 2, 32, 4);
		HxlGraphics.state.add(bar);
		var self = this;
		Actor.addOnInjure(function(?dmgTotal:Int=0) { 
			self.showDamageText(Actor, dmgTotal);
			self.doInjureEffect(Actor);
		});
		Actor.addOnAttackMiss(doAttackMiss);
	}

	public function addXpBar(Actor:CqPlayer):Void {
		xpBar = new CqXpBar(Actor, Actor.x, Actor.y + Actor.height + 5, 32, 4);
		HxlGraphics.state.add(xpBar);
		var self = this;

		/*Actor.addOnInjure(function(?dmgTotal:Int=0) { 
			self.showDamageText(Actor, dmgTotal);
			self.doInjureEffect(Actor);
		});*/
	}
	
	public function doAttackMiss(?Attacker:CqActor, ?Defender:CqActor):Void {
		var attPos:HxlPoint = Attacker.tilePos;
		var defPos:HxlPoint = Defender.tilePos;
		if ( attPos.x > defPos.x ) Defender.runDodge(1); 
		else if ( attPos.x < defPos.x ) Defender.runDodge(3); 
		else if ( attPos.y < defPos.y ) Defender.runDodge(0); 
		else if ( attPos.y > defPos.y ) Defender.runDodge(2);
	}

	public function doPlayerInjureEffect(?dmgTotal:Int):Void {
		var player = cast(Registery.player, CqActor);
		if ( (player.hp / player.maxHp) <= 0.2 ) {
			HxlGraphics.flash.start(0xffff0000, 0.2, null, true);
		}
	}

	public function doInjureEffect(Target:CqActor):Void {
		var eff:CqEffectInjure = new CqEffectInjure(Target.x + Target.origin.x, Target.y + Target.origin.y);
		eff.zIndex = 6;
		HxlGraphics.state.add(eff);
		eff.start(true, 1.0, 10);
	}

	public function showDamageText(Actor:CqActor, Damage:Int):Void {
		showEffectText(Actor, ""+Damage, 0xff2222);
	}
	
	public static function showEffectText(actor:CqActor, text:String, color:Int) {
		var txt:CqFloatText = new CqFloatText(actor.x + (actor.width/2), actor.y - 16, text, color, 24);
		txt.zIndex = 4;
		HxlGraphics.state.add(txt);
	}
	
	public function doPlayerGainXP(?xpTotal:Int=0):Void {
		xpBar.updateValue(xpTotal);
	}

	public static function setTargeting(Toggle:Bool, ?TargetText:String=null):Void {
		isTargeting = Toggle;
		if ( TargetText != null ) {
			targetString = TargetText + ": Select A Target";
		}
		if ( !Toggle ) {
			if ( instance.targetSprite != null ) instance.targetSprite.visible = false;
			if ( instance.targetText != null ) instance.targetText.visible = false;
			if ( targetSpell != null ) targetSpell = null;
		}
	}

	public static function setTargetingSpell(Spell:CqSpellButton):Void {
		targetSpell = Spell;
	}

	public function updateTargeting():Void {
		if ( targetSprite == null ) {
			targetSprite = new HxlSprite(0, 0);
			targetSprite.createGraphic(Configuration.zoomedTileSize(), Configuration.zoomedTileSize(), 0x88ffffff, false, "targetSprite");
			targetSprite.zIndex = 1;
			targetSprite.color = 0x00ff00;
			HxlGraphics.state.add(targetSprite);
			targetLastPos = null;
		} else if ( targetSprite.visible == false ) targetSprite.visible = true;
		if ( targetText == null && GameUI.targetString != "" ) {
			targetText = new HxlText( 80, HxlGraphics.height - 130, HxlGraphics.width - 160, GameUI.targetString );
			targetText.setFormat(null, 24, 0xffffff, "center", 0x010101);
			targetText.zIndex = -1;
			add(targetText);
		} else if ( targetText.visible == false ) {
			targetText.visible = true;
			targetText.setText(GameUI.targetString);
		}
		var targetX = Math.floor(HxlGraphics.mouse.x / Configuration.zoomedTileSize());
		var targetY = Math.floor(HxlGraphics.mouse.y / Configuration.zoomedTileSize());

		if ( targetLastPos == null || targetLastPos.x != targetX || targetLastPos.y != targetY ) {
			var worldPos:HxlPoint = Registery.level.getTilePos(Std.int(targetX), Std.int(targetY));
			targetSprite.x = worldPos.x;
			targetSprite.y = worldPos.y;

			var tile:CqTile = cast(Registery.level.getTile(Std.int(targetX), Std.int(targetY)), CqTile);
			//tile.color = 0xbbffbb;
			if ( tile == null || tile.actors.length <= 0 ) {
				targetSprite.color = 0xff0000;
			} else {
				if ( cast(tile.actors[0], CqActor).faction != 0 ) {
					targetSprite.color = 0x00ff00;
				} else {
					targetSprite.color = 0xff0000;
				}
			}

			if ( targetLastPos == null ) 
				targetLastPos = new HxlPoint();
			
			targetLastPos.x = targetX;
			targetLastPos.y = targetY;
		}
	}

	public function targetingMouseDown():Void {
		if ( targetSpell == null ) {
			GameUI.setTargeting(false);
		}
		var targetX = Math.floor(HxlGraphics.mouse.x / Configuration.zoomedTileSize());
		var targetY = Math.floor(HxlGraphics.mouse.y / Configuration.zoomedTileSize());
		var tile:CqTile = cast(Registery.level.getTile(Std.int(targetX), Std.int(targetY)), CqTile);
		if ( tile == null || tile.actors.length <= 0 ) {
			GameUI.setTargeting(false);
		} else {
			if ( cast(tile.actors[0], CqActor).faction != 0 ) {
				var player = cast(Registery.player, CqPlayer);
				player.use(targetSpell.getSpell(), cast(tile.actors[0], CqActor));
				targetSpell.getSpell().spiritPoints = 0;
				GameUI.instance.updateCharge(targetSpell);
				GameUI.setTargeting(false);
			} else {
				GameUI.setTargeting(false);
			}
		}

	}
}
