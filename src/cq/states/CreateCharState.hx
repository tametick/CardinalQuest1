package cq.states;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Cubic;
import cq.CqGraphicKey;
import cq.ui.CqTextScroller;
import data.StatsFile;
import flash.events.Event;
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
class CreateCharStateBMPData extends BitmapData {}
class CreateCharState extends CqState {
	
	static var class_buttons_y:Int = 135;
	static var shownIntro:Bool = false;
	var fadeTime:Float;
	var state:Int;
	var txtDesc:HxlText;
	var selectBox:HxlSprite;
	var curClass:String;
	var storyScreen:Bool;
	var portrait:HxlSprite;
	var playerSprites:HxlSpriteSheet;
	
	var recenter:Int;
	var shiftup:Int;
	var paperShiftup:Int;
	
	var scroller:CqTextScroller;
	
	public override function create() {
		super.create();
		
		fadeTime = 0.5;
		state = 0;
		storyScreen = true;
		HxlGraphics.fade.start(false, 0xff000000, fadeTime, fadeCallBack);
		
		recenter = Math.floor((Configuration.app_width - 640) / 2); // the adjustment needed for the three sprites to be centered no matter the screen size
		shiftup = HxlGraphics.smallScreen ? -68 : 0;
		paperShiftup = HxlGraphics.smallScreen ? -90 : 0;
	}
	
	function fadeCallBack():Void {
		state = 1;
	}
	
	override public function destroy(){
		super.destroy();

		#if !scouts
		txtDesc.destroy();
		portrait.destroy();
		#end
		
		selectBox.destroy();
		if ( playerSprites.bitmapData != null ) {
			playerSprites.bitmapData.dispose();
		}

		txtDesc = null;
		selectBox = null;
		portrait = null;
		playerSprites = null;
	}
	
	function pickFighter() {
		changeSelection("FIGHTER");
	}
	function pickThief() {
		changeSelection("THIEF");
	}
	function pickWizard() {
		changeSelection("WIZARD");
	}
	
	function createChoice(className:String, spriteName:String, btnX:Int, textX:Int, cb:Void->Void) {
		var sprite = new HxlSprite(0, 0);
		sprite.loadGraphic(SpritePlayer, true, false, Configuration.tileSize, Configuration.tileSize, false, 4.0, 4.0);
		sprite.setFrame(playerSprites.getSpriteIndex(spriteName));
		
		sprite.x = btnX + recenter;
		sprite.y = class_buttons_y + shiftup ;
		add(sprite);
		
		var button = new HxlButton(btnX - 30 + recenter, class_buttons_y - 20 + shiftup , Std.int(selectBox.width), Std.int(selectBox.height), cb, 0.0, 0.0);
		add(button);

		var textY:Float = class_buttons_y + sprite.height + shiftup;
#if japanese
		textY += 8;
#end
		var text = new HxlText(textX + recenter, textY , 150, className);
		text.setFormat(null, 32, 0xffffff, "center", 0x010101); 
		add(text);
	}
	
	#if scouts
	var warriorBg:HxlSprite;
	var wizardBg:HxlSprite;
	var rogueBg:HxlSprite;
	#end
	
	function realInit() {
		add(cursor);
		cursor.visible	= true;
		if (scroller != null)
			remove(scroller);
		storyScreen = false;
		
		
		#if scouts
		warriorBg = new HxlSprite(0, 0, ScoutsWarrior);
		warriorBg.zIndex = -10;
		wizardBg = new HxlSprite(0, 0, ScoutsWizard);
		wizardBg.zIndex = -10;
		rogueBg = new HxlSprite(0, 0, ScoutsRogue);
		rogueBg.zIndex = -10;
		add(warriorBg);
		add(wizardBg);
		add(rogueBg);	
		wizardBg.visible = false;
		rogueBg.visible = false;
		#else
		//paper bg
		var bg:HxlSprite = new HxlSprite(HxlGraphics.smallScreen ? -25 : 40, 250 + paperShiftup + (HxlGraphics.smallScreen ? 10 : 0), SpriteCharPaper);
		add(bg);
		#end
		
		
#if japanese
		var titleText:HxlText = new HxlText(0, HxlGraphics.smallScreen ? 0 : 8, Configuration.app_width, Resources.getString( "MENU_CREATECHARACTER" ), true, "FontAnonymousPro" );
#else
		var titleText:HxlText = new HxlText(0, HxlGraphics.smallScreen ? -3 : 0, Configuration.app_width, Resources.getString( "MENU_CREATECHARACTER" ));
#end

#if !scouts
		titleText.setFormat(null, HxlGraphics.smallScreen ? 56 : 72, 0xffffff, "center");
		add(titleText);
#end

		#if scouts
		var btnStart:HxlButton = new HxlButton(500, 420, 90, 45);
		#else
		var btnStart:HxlButton = new HxlButton(500, 420 + paperShiftup - (HxlGraphics.smallScreen ? 10 : 0), 90, 28);
		#end
		btnStart.setEventUseCapture(true);
		var btnStartBg:HxlSprite = new HxlSprite(btnStart.x, btnStart.y);
		btnStartBg.loadGraphic(SpriteButtonBg, false, false, 90, 26);
		
		#if scouts
		btnStart.loadGraphic(new ScoutsStartButtonSprite());
		#else
		var btnStartHigh = new StartButtonSprite();
		btnStartHigh.setAlpha(0.6);
		btnStart.loadGraphic(new StartButtonSprite(), btnStartHigh);
		#end
		
#if japanese
		btnStart.loadText(new HxlText(0, 4, 90, Resources.getString( "MENU_START" ), true, null).setFormat(null, 26, 0xffffff, "center", 0x010101));
#elseif !scouts
		btnStart.loadText(new HxlText(0, -2, 90, Resources.getString( "MENU_START" ), true, null).setFormat(null, 32, 0xffffff, "center", 0x010101));
#end
    if (HxlGraphics.smallScreen) btnStart.x = 200;

		btnStart.setCallback(function() {
			gotoState(GameState);
			//self = null;
		});

		
		selectBox = new HxlSprite(105 + recenter, class_buttons_y-20 + shiftup);
		if ( !GraphicCache.checkBitmapCache(CqGraphicKey.CharCreateSelector) ) {
			var target:Shape = new Shape();
			target.graphics.lineStyle(5, 0xffffff00);
			target.graphics.beginFill(0x00000000, 0.0);
			target.graphics.drawRoundRect(2.5, 2.5, 125, 125, 15.0, 15.0);
			target.graphics.endFill();
			var bmp:CreateCharStateBMPData = new CreateCharStateBMPData(130, 130, true, 0x0);
			bmp.draw(target);
			selectBox.width = selectBox.height = 130;
			selectBox.pixels = bmp;
			
			bmp = null;
			target = null;
		} else {
			selectBox.loadCachedGraphic(CqGraphicKey.CharCreateSelector);
		}
		add(selectBox);		
		
		
		playerSprites = SpritePlayer.instance;

		createChoice(Resources.getString( "FIGHTER" ), "fighter", 138, 95, pickFighter);
		createChoice(Resources.getString( "THIEF" ), "thief", 288, 245, pickThief);
		createChoice(Resources.getString( "WIZARD" ), "wizard", 438, 395, pickWizard);
		
		#if !scouts
		txtDesc = new HxlText(HxlGraphics.smallScreen ? 110 : 160, 280 + paperShiftup, HxlGraphics.smallScreen ? HxlGraphics.width - 120 : HxlGraphics.width - 220);
		txtDesc.setFormat(FontAnonymousPro.instance.fontName, 16, 0x000000, "left", 0);
		add(txtDesc);

		// Initialise text.
		txtDesc.text = Resources.getString( "FIGHTER", true );

		portrait = SpritePortraitPaper.getIcon("FIGHTER", 100 , 1.0);
		portrait.x = HxlGraphics.smallScreen ? 20 : 60 ;
		portrait.y = 290 + paperShiftup;
		add(portrait);
		#end
		
		add(btnStartBg);
		add(btnStart);
		
		pickFighter();
		
/*		// todo: remove later 
		var sponsored= new HxlText(10, 10, 135, "Sponsored by",true,FontAnonymousPro.instance.fontName,18);
		add(sponsored);
		var kongLogo = KongLogoSprite.instance;
		kongLogo.x = 25;
		kongLogo.y = sponsored.y + sponsored.height+5;
		add(kongLogo);
*/		
		
		btnStartBg = null;
		btnStart = null;
		titleText = null;
		#if scouts
		/*warriorBg=null;
		wizardBg=null;
		rogueBg=null;*/
		#else
		bg = null;
		btnStartHigh = null;
		#end
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
			var introText:String = Resources.getString( "AsterionIntro", true );
//			scroller.addColumn(80, 480, introText, false, FontAnonymousPro.instance.fontName,28,0xFFCD55,0x2E170F);
#if japanese
//			scroller.addColumn(50, 540, introText, true, FontAnonymousPro.instance.fontName, 26, 0xFFCD55, 0x2E170F);
			scroller.addColumn(50, 540, introText, true, FontTheatre16.instance.fontName, 26, 0xFFCD55, 0x2E170F);
#else
			scroller.addColumn(50, 540, introText, true, FontDungeon.instance.fontName, 30, 0xFFCD55, 0x2E170F);
#end
			add(scroller);
			scroller.startScroll(8);
			//scroller.onComplete(removeScrollerAndFade);
			scroller.onComplete(realInit);
			shownIntro = true;
			cursor.visible = false;
			remove(cursor);
			
			introText = null;
		}else {
			realInit();
		}
	}

	function changeSelection(TargetClass:String) {
		//If this class was already selected, then we assume the player
		//wants to just play
		if ( TargetClass == curClass ) 
			gotoState(GameState);
		
		SoundEffectsManager.play(MenuItemMouseOver);

		var classes:StatsFile = Resources.statsFiles.get( "classes.txt" );
		var classEntry:StatsFileEntry = classes.getEntry( "ID", TargetClass );
		
		curClass = TargetClass;
		
		var targetX:Float = 0;
		warriorBg.visible = false;
		rogueBg.visible = false;
		wizardBg.visible = false;
		if ( curClass == "FIGHTER" ) {
			targetX = 105 + recenter;
			warriorBg.visible = true;
		} else if ( curClass == "THIEF" ) {
			targetX = 255 + recenter;
			rogueBg.visible = true;
		} else if ( curClass == "WIZARD" ) {
			targetX = 405 + recenter;
			wizardBg.visible = true;
		}
		
		#if !scouts
		portrait.setFrame( classEntry.getField( "Portrait" ) );
		txtDesc.text = Resources.getString( curClass, true );
		#end
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
				case "FIGHTER":
					changeSelection("WIZARD");
				case "THIEF":
					changeSelection("FIGHTER");
				case "WIZARD":
					changeSelection("THIEF");
			}
		} else if (HxlGraphics.keys.justReleased("RIGHT") || HxlGraphics.keys.justReleased("D")) {
			if (curClass == null) return;
			switch(curClass) {
				case "FIGHTER":
					changeSelection("THIEF");
				case "THIEF":
					changeSelection("WIZARD");
				case "WIZARD":
					changeSelection("FIGHTER");
			}			
		} else if (HxlGraphics.keys.justReleased("ENTER")) {
			gotoState(GameState);
		}
	}

	function gotoState(TargetState:Class<HxlState>) {
		if ( state != 1 ) 
			return;
			
		GameState.loadingGame = false;
			
		SoundEffectsManager.play(MenuItemClick);
		state = 0;
		var cls = this.curClass;
		HxlGraphics.fade.start(true, 0xff000000, fadeTime, function() {
			var newState = Type.createInstance(TargetState, new Array());
			HxlGraphics.state = newState;
			if ( TargetState == GameState ) {
				cast(newState, GameState).chosenClass = cls;
			}
			cls = null;
			newState = null;
		}, true);
	}
}
