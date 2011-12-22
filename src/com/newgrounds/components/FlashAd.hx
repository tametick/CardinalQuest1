package com.newgrounds.components;

extern class FlashAd extends FlashAdBase, implements Dynamic {
	var adContainer : flash.display.MovieClip;
	var newgroundsButton : flash.display.SimpleButton;
	var playButton : flash.display.MovieClip;
	function new() : Void;
	function frame1() : Dynamic;
	function frame30() : Dynamic;
	function onPlayClick(p1 : flash.events.MouseEvent) : Void;
}
