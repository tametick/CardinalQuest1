package cq;

import cq.states.GameState;
import cq.states.MainMenuState;
import cq.states.SplashState;
import cq.CqResources;
import cq.ui.CqPause;
import haxel.HxlPreloader;
import haxel.HxlGame;
import haxel.HxlGraphics;
import haxel.HxlState;
import haxel.HxlText;
import data.Configuration;

import flash.Lib;
import flash.system.Capabilities;
import flash.filesystem.File;
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.desktop.NativeApplication;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.NativeProcessExitEvent;
import flash.events.Event;

import haxe.Timer;

import playtomic.Playtomic;

class Main {
	static var currentGame:Game;
	public static function main() {
		#if flash9
		haxe.Log.setColor(0xffffff);
		new Main();
		#elseif iphone
		new Main();
		#elseif cpp
		Lib.create(function(){new Main();},Configuration.app_width,Configuration.app_height,60,0xffffff,(1*Lib.HARDWARE) | Lib.RESIZABLE);
		#end
	}

	public function new() {	
		currentGame = new Game();
		Lib.current.addChild(currentGame);
	}	
}

class Game extends HxlGame {
	public static var jadeDS:Dynamic;
	static var jadeDSStartupInfo:Dynamic;
	
	function onExit(arg:Dynamic) {
		#if jadeds	
		Game.jadeDS.exit(true); 
		#end
	}
	
	function onStdinError(arg:Dynamic) {
		MainMenuState.message = "LittleIndie client not available:\nnetwork functionality disabled.";
		if (Std.is(HxlGraphics.state, MainMenuState))
			HxlGraphics.state.add(new HxlText(0, 0, 500, MainMenuState.message, true, FontAnonymousProB.instance.fontName, 18));
	}
	
	function onStdoutData(arg:Dynamic) {
		//trace(arg);
	}
	
	function jadeExitHandler(arg:Dynamic) {
		onStdinError(arg);
	}
	
	public function startJadeDs() {
		var path = File.applicationDirectory.nativePath + "\\jadeds\\";
		var JADEDS_FILE = new File(path + "JadeDSWrapper.exe");
	
		jadeDSStartupInfo = new NativeProcessStartupInfo();
		jadeDSStartupInfo.executable = JADEDS_FILE;
		jadeDSStartupInfo.workingDirectory = new File(path);
		
		jadeDS = new NativeProcess();	
		jadeDS.addEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, onStdinError);
		jadeDS.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onStdoutData);
		jadeDS.addEventListener(NativeProcessExitEvent.EXIT, jadeExitHandler);
		jadeDS.start(jadeDSStartupInfo);
		
		
		NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExit);
	}
	
	public function new() {
		#if jadeds
			startJadeDs();
		#end

		Configuration.tileSize = 16;
		Configuration.zoom = 2.0;
		HxlState.bgColor = 0xFF000000;
		Playtomic.create();
		
		if (Configuration.debug)
			super(640, 480, GameState, 1, FontDungeon.instance.fontName);
		else
			super(640, 480, SplashState, 1, FontDungeon.instance.fontName);		
		
		pause = new CqPause();
		useDefaultHotKeys = false;
	}
}
