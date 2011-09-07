package cq.states;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Cubic;
import cq.CqGraphicKey;
import cq.ui.CqTextScroller;
import haxel.GraphicCache;
import haxel.HxlSpriteSheet;

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
	
	static var class_buttons_y:Int = 135;
	static var shownIntro:Bool = false;
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
	var storyScreen:Bool;
	var portrait:HxlSprite;
	var playerSprites:HxlSpriteSheet;
	
	var scroller:CqTextScroller;
	
	public override function create() {
		super.create();
		
		CqMobFactory.initDescriptions();
		fadeTime = 0.5;
		state = 0;
		storyScreen = true;
		var self = this;
		HxlGraphics.fade.start(false, 0xff000000, fadeTime, fadeCallBack);
	}
	
	function fadeCallBack():Void 
	{
		state = 1;
		//self = null;
	}
	
	override public function destroy(){
		super.destroy();

		btnFighter.destroy();
		btnThief.destroy();
		btnWizard.destroy();
		txtFighter.destroy();
		txtThief.destroy();
		txtWizard.destroy();
		txtDesc.destroy();
		selectBox.destroy();
		portrait.destroy();
		playerSprites.bitmapData.dispose();
		
		btnFighter = null;
		btnThief = null;
		btnWizard = null;
		txtFighter = null;
		txtThief = null;
		txtWizard = null;
		txtDesc = null;
		selectBox = null;
		portrait = null;
		playerSprites = null;
	}
	
	function realInit() {
		cursor.visible	= true;
		if (scroller != null)
			remove(scroller);
		storyScreen = false;
		
		//paper bg
		var bg:HxlSprite = new HxlSprite(40, 250, SpriteCharPaper);
		add(bg);
		var titleText:HxlText = new HxlText(0, 0, Configuration.app_width, "Create Character");
		titleText.setFormat(null, 72, 0xffffff, "center");
		add(titleText);
		
		var btnStart:HxlButton = new HxlButton(490, 390, 90, 28);
		btnStart.setEventUseCapture(true);
		var btnStartBg:HxlSprite = new HxlSprite(btnStart.x, btnStart.y);
		btnStartBg.loadGraphic(SpriteButtonBg, false, false, 90, 26);
		var btnStartHigh = new StartButtonSprite();
		btnStartHigh.setAlpha(0.6);
		btnStart.loadGraphic(new StartButtonSprite(),btnStartHigh);
		btnStart.loadText(new HxlText(0, -7, 90, "Start", true, null).setFormat(null, 32, 0xffffff, "center", 0x010101));

		var self = this;
		btnStart.setCallback(function() {
			self.gotoState(GameState);
			self = null;
		});

		playerSprites= SpritePlayer.instance;

		var sprFighter = new HxlSprite(0, 0);
		sprFighter.loadGraphic(SpritePlayer, true, false, Configuration.tileSize, Configuration.tileSize, false, 4.0, 4.0);
		sprFighter.setFrame(playerSprites.getSpriteIndex("fighter"));
		btnFighter = new HxlButton(138, class_buttons_y);
		btnFighter.loadGraphic(sprFighter);
		add(btnFighter);
		btnFighter.setCallback(function() { self.changeSelection(FIGHTER); });
		txtFighter = new HxlText(95, class_buttons_y+sprFighter.height, 150, "Fighter");
		txtFighter.setFormat(null, 32, 0xffffff, "center", 0x010101);
		add(txtFighter);

		var sprThief = new HxlSprite(0, 0);
		sprThief.loadGraphic(SpritePlayer, true, false, Configuration.tileSize, Configuration.tileSize, false, 4.0, 4.0);
		sprThief.setFrame(playerSprites.getSpriteIndex("thief"));
		btnThief = new HxlButton(288, class_buttons_y);
		btnThief.loadGraphic(sprThief);
		add(btnThief);
		btnThief.setCallback(function() { self.changeSelection(THIEF); });
		txtThief = new HxlText(245, class_buttons_y+sprThief.height, 150, "Thief");
		txtThief.setFormat(null, 32, 0xffffff, "center", 0x010101);
		add(txtThief);

		var sprWizard = new HxlSprite(0, 0);
		sprWizard.loadGraphic(SpritePlayer, true, false, Configuration.tileSize, Configuration.tileSize, false, 4.0, 4.0);
		sprWizard.setFrame(playerSprites.getSpriteIndex("wizard"));
		btnWizard = new HxlButton(438, class_buttons_y);
		btnWizard.loadGraphic(sprWizard);
		add(btnWizard);
		btnWizard.setCallback(function() { self.changeSelection(WIZARD); });
		txtWizard = new HxlText(395, class_buttons_y+sprWizard.height, 150, "Wizard");
		txtWizard.setFormat(null, 32, 0xffffff, "center", 0x010101);
		add(txtWizard);

		selectBox = new HxlSprite(105, class_buttons_y-20);
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
			
			bmp = null;
			target = null;
		} else {
			selectBox.loadCachedGraphic(CqGraphicKey.CharCreateSelector);
		}
		add(selectBox);

		txtDesc = new HxlText(160, 280, HxlGraphics.width - 220);
		txtDesc.setFormat(FontAnonymousPro.instance.fontName, 16, 0x000000, "left", 0);
		add(txtDesc);
		txtDesc.text = Resources.descriptions.get("Fighter");

		portrait = SpritePortraitPaper.getIcon(FIGHTER, 100 , 1.0);
		portrait.x = 60;
		portrait.y = 290;
		add(portrait);
		
		add(btnStartBg);
		add(btnStart);
		
		curClass = FIGHTER;
		
		
		sprWizard = null;
		sprThief = null;
		sprFighter = null;
		btnStartHigh = null;
		btnStartBg = null;
		btnStart = null;
		titleText = null;
		bg = null;
	}
	/*
	function removeScrollerAndFade() {
		if (scroller != null) {
			remove(scroller);
			scroller = null;
			HxlGraphics.fade.start( false, 0xff000000, fadeTime, realInit, true );
		}
	}*/
	
	override function init() {
		if (!shownIntro) {
			cursor.visible	= false;
			scroller = new CqTextScroller(IntroScreen, 1);
			var introText:String = " The evil minotaur Asterion has terrorized the peaceful land of Hallemot for countless years.\n\n In his underground den, he and his minions enjoy the spoils of their wicked deeds.\n\n Determined to end his reign of plunder and pillage, a single hero comes forth...";
			scroller.addColumn(80, 480, introText, false, FontAnonymousPro.instance.fontName,30,0x000000,0x804040);
			add(scroller);
			scroller.startScroll();
			//scroller.onComplete(removeScrollerAndFade);
			scroller.onComplete(realInit);
			shownIntro = true;
			
			introText = null;
		}else {
			realInit();
		}
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
			portrait.setFrame(1);
		} else if ( curClass == THIEF ) {
			targetX = 255;
			txtDesc.text = Resources.descriptions.get("Thief");
			portrait.setFrame(0);
		} else if ( curClass == WIZARD ) {
			targetX = 405;
			txtDesc.text = Resources.descriptions.get("Wizard");
			portrait.setFrame(2);
		}
		Actuate.tween(selectBox, 0.25, { x: targetX }).ease(Cubic.easeOut);
	}

	public override function update() {
		super.update();
		setDiagonalCursor();
	}

	override function onKeyUp(event:KeyboardEvent) { 
		if ( storyScreen) return;
		if ( HxlGraphics.keys.justReleased("ESCAPE") ) {
			gotoState(MainMenuState);
		} else if (HxlGraphics.keys.justReleased("LEFT") || HxlGraphics.keys.justReleased("A")) {
			if (curClass == null) return;
			switch(curClass) {
				case FIGHTER:
					changeSelection(WIZARD);
				case THIEF:
					changeSelection(FIGHTER);
				case WIZARD:
					changeSelection(THIEF);
			}
		} else if (HxlGraphics.keys.justReleased("RIGHT") || HxlGraphics.keys.justReleased("D")) {
			if (curClass == null) return;
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
		var cls = this.curClass;
		HxlGraphics.fade.start(true, 0xff000000, fadeTime, function() {
			var newState = Type.createInstance(TargetState, []);
			HxlGraphics.state = newState;
			if ( TargetState == GameState ) {
				cast(newState, GameState).chosenClass = cls;
				cls = null;
				newState = null;
			}
		}, true);
	}
}
