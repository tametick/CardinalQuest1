package cq.states;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Cubic;
import cq.CqGraphicKey;
import haxel.GraphicCache;

import cq.CqActor;
import cq.CqResources;

import data.Configuration;
import data.Resources;
import data.SoundEffectsManager;

import flash.display.BitmapData;
import flash.display.Shape;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;

import haxel.HxlButton;
import haxel.HxlGraphics;
import haxel.HxlSprite;
import haxel.HxlState;
import haxel.HxlText;

class CreateCharState extends CqState {
	var fadeTime:Float;
	var state:Int;
	var btnFighter:HxlButton;
	var btnThief:HxlButton;
	var btnWizard:HxlButton;
	var txtFighter:HxlText;
	var txtThief:HxlText;
	var txtWizard:HxlText;
	var txtDesc:HxlText;
	var selectBox:HxlSprite;
	var curClass:CqClass;

	public override function create() {
		super.create();
		
		CqMobFactory.initDescriptions();

		fadeTime = 0.5;
		state = 0;

		var titleText:HxlText = new HxlText(0, 0, 640, "Create Character");
		titleText.setFormat(null, 72, 0xffffff, "center");
		add(titleText);

		
		var btnStart:HxlButton = new HxlButton(Std.int((640 - 90) / 2), 430, 90, 28);
		var btnStartBg:HxlSprite = new HxlSprite(btnStart.x, btnStart.y);
		btnStartBg.loadGraphic(SpriteButtonBg, false, false, 90, 26);
		var btnStartHigh = new StartButtonSprite();
		btnStartHigh.setAlpha(0.6);
		btnStart.loadGraphic(new StartButtonSprite(),btnStartHigh);
		btnStart.loadText(new HxlText(0, -7, 90, "Start", true, null).setFormat(null, 32, 0xffffff, "center", 0x010101));

		add(btnStartBg);
		add(btnStart);
		var self = this;
		btnStart.setCallback(function() {
			self.gotoState(GameState);
		});

		var playerSprites = SpritePlayer.instance;
		var self = this;

		var sprFighter = new HxlSprite(0, 0);
		sprFighter.loadGraphic(SpritePlayer, true, false, Configuration.tileSize, Configuration.tileSize, false, 4.0, 4.0);
		sprFighter.setFrame(playerSprites.getSpriteIndex("fighter"));
		btnFighter = new HxlButton(138, 175);
		btnFighter.loadGraphic(sprFighter);
		add(btnFighter);
		btnFighter.setCallback(function() { self.changeSelection(FIGHTER); });
		txtFighter = new HxlText(95, 250, 150, "Fighter");
		txtFighter.setFormat(null, 32, 0xffffff, "center", 0x010101);
		add(txtFighter);

		var sprThief = new HxlSprite(0, 0);
		sprThief.loadGraphic(SpritePlayer, true, false, Configuration.tileSize, Configuration.tileSize, false, 4.0, 4.0);
		sprThief.setFrame(playerSprites.getSpriteIndex("thief"));
		btnThief = new HxlButton(288, 175);
		btnThief.loadGraphic(sprThief);
		add(btnThief);
		btnThief.setCallback(function() { self.changeSelection(THIEF); });
		txtThief = new HxlText(245, 250, 150, "Thief");
		txtThief.setFormat(null, 32, 0xffffff, "center", 0x010101);
		add(txtThief);

		var sprWizard = new HxlSprite(0, 0);
		sprWizard.loadGraphic(SpritePlayer, true, false, Configuration.tileSize, Configuration.tileSize, false, 4.0, 4.0);
		sprWizard.setFrame(playerSprites.getSpriteIndex("wizard"));
		btnWizard = new HxlButton(438, 175);
		btnWizard.loadGraphic(sprWizard);
		add(btnWizard);
		btnWizard.setCallback(function() { self.changeSelection(WIZARD); });
		txtWizard = new HxlText(395, 250, 150, "Wizard");
		txtWizard.setFormat(null, 32, 0xffffff, "center", 0x010101);
		add(txtWizard);

		selectBox = new HxlSprite(105, 160);
		if ( !GraphicCache.checkBitmapCache(CqGraphicKey.CharCreateSelector) ) {
			var target:Shape = new Shape();
			target.graphics.lineStyle(5, 0xffffff00);
			target.graphics.beginFill(0x00000000, 0.0);
			target.graphics.drawRoundRect(2.5, 2.5, 125, 125, 15.0, 15.0);
			target.graphics.endFill();
			var bmp:BitmapData = new BitmapData(130, 130, true, 0x0);
			bmp.draw(target);
			selectBox.width = selectBox.height = 130;
			selectBox.pixels = bmp;
		} else {
			selectBox.loadCachedGraphic(CqGraphicKey.CharCreateSelector);
		}
		add(selectBox);

		txtDesc = new HxlText(30, 325, HxlGraphics.width - 60);
		txtDesc.setFormat(FontAnonymousPro.instance.fontName, 16, 0xffffff, "center", 0x010101);
		add(txtDesc);
		txtDesc.text = Resources.descriptions.get("Fighter");

		curClass = FIGHTER;

		HxlGraphics.fade.start(false, 0xff000000, fadeTime, function() {
			self.state = 1;
		});
	}

	function changeSelection(Target:CqClass) {
		if ( Target == curClass ) 
			return;
		
		SoundEffectsManager.play(MenuItemMouseOver);
		
		curClass = Target;
		var targetX:Float = 0;
		if ( curClass == FIGHTER ) {
			targetX = 105;
			txtDesc.text = Resources.descriptions.get("Fighter");
		} else if ( curClass == THIEF ) {
			targetX = 255;
			txtDesc.text = Resources.descriptions.get("Thief");
		} else if ( curClass == WIZARD ) {
			targetX = 405;
			txtDesc.text = Resources.descriptions.get("Wizard");
		}
		Actuate.tween(selectBox, 0.25, { x: targetX }).ease(Cubic.easeOut);
	}

	public override function update() {
		super.update();
		setDiagonalCursor();
	}

	override function onKeyUp(event:KeyboardEvent) { 
		if ( HxlGraphics.keys.justReleased("ESCAPE") ) {
			gotoState(MainMenuState);
		} else if (HxlGraphics.keys.justReleased("LEFT")) {
			switch(curClass) {
				case FIGHTER:
					changeSelection(WIZARD);
				case THIEF:
					changeSelection(FIGHTER);
				case WIZARD:
					changeSelection(THIEF);
			}
		} else if (HxlGraphics.keys.justReleased("RIGHT")) {
			switch(curClass) {
				case FIGHTER:
					changeSelection(THIEF);
				case THIEF:
					changeSelection(WIZARD);
				case WIZARD:
					changeSelection(FIGHTER);
			}			
		} else if (HxlGraphics.keys.justReleased("ENTER")) {
			gotoState(GameState);
		}
	}

	function gotoState(TargetState:Class<HxlState>) {
		if ( state != 1 ) 
			return;
			
		SoundEffectsManager.play(MenuItemClick);
		state = 0;
		var self = this;
		HxlGraphics.fade.start(true, 0xff000000, fadeTime, function() {
			var newState = Type.createInstance(TargetState, []);
			HxlGraphics.state = newState;
			if ( TargetState == GameState ) 
				cast(newState, GameState).chosenClass = self.curClass;
		}, true);
	}
}
