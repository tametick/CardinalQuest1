package cq;

import flash.Lib;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.StageAlign;
import flash.display.StageScaleMode;

import flash.events.Event;

import flash.external.ExternalInterface;

import flash.text.TextField;
import flash.text.TextFormat;

import flash.Lib;

import com.newgrounds.API;
import com.newgrounds.components.FlashAd;

#if flash
	import flash.system.Capabilities;
	import flash.ui.ContextMenu;
#end

/**
 * ...
 * @author randomnine
 */

class NewgroundsPreloader extends MovieClip
{
	var m_progress:Float;
	var m_progressBarBG : Shape;
	var m_progressBar : Shape;
	
	var m_newgroundsAd : FlashAd;
	
	public static function main() {
		Lib.current.addChild( new NewgroundsPreloader() );
	}

	public function new() 
	{
		super();
		
		com.newgrounds.API.connect(Lib.current.root, "20129:WvEkS4bH", "QUv5MaqA2vPnAUTMchXzvon9GqmQt8hG");		
		com.newgrounds.API.debugMode = com.newgrounds.API.RELEASE_MODE;
		
		Lib.current.stage.scaleMode = StageScaleMode.SHOW_ALL;
		Lib.current.stage.align = StageAlign.TOP;

		// Site lock.
		var sitelock:Bool = true;
		if ( ExternalInterface.available ) {
			// Site lock check.
			var browserurl:String = Lib.current.root.loaderInfo.url;
			
			var firstSplit = browserurl.split("://");
			var domain = (firstSplit[1] != null) ? firstSplit[1] : firstSplit[0];

			var domain2:String = domain.split("/")[0];
			
			if ( domain2 == "newgrounds.com" || domain2.substr( domain2.length - 15 ) == ".newgrounds.com"
			  || domain2 == "ungrounded.net" || domain2.substr( domain2.length - 15 ) == ".ungrounded.net"
			  || domain2 == "wootfu.com" || domain2.substr( domain2.length - 11 ) == ".wootfu.com" )
			{
				sitelock = false;
			}
		}

		if ( sitelock ) {
			var text = new TextField();
			var format1 = new TextFormat();
			var format2 = new TextFormat();
			var length:Int;
			
			format1.bold = false;
			format1.color = 0xffffff;
			format1.size = 16;

			format2.bold = true;
			format2.color = 0xffff00;
			format2.size = 16;
			
			text.x = 10;
			text.y = 10;
			text.width = 620;
			text.height = 460;
			text.textColor = 0xffffff;
			text.wordWrap = true;
			text.appendText( "This version of the game is site locked to Newgrounds.com.\n\nPlease visit " );
			length = text.length;
			text.setTextFormat( format1 );
			text.appendText( "http://Newgrounds.com/" );
			text.setTextFormat( format2, length, text.length );
			length = text.length;
			text.appendText( " or " );
			text.setTextFormat( format1, length, text.length );
			length = text.length;
			text.appendText( "http://CardinalQuest.com/" );
			text.setTextFormat( format2, length, text.length );
			length = text.length;
			text.appendText( " to play Cardinal Quest." );
			text.setTextFormat( format1, length, text.length );
			length = text.length;
			addChild( text );
		} else {		
			Lib.current.addEventListener(Event.ENTER_FRAME, checkFrame, false, 0, false);
			
			m_progress = 0;
			
			m_progressBarBG = new Shape();
			var g : Graphics = m_progressBarBG.graphics;
			g.lineStyle(2.0, 0xFFFFFF);
			g.drawRect(0, 0, 400, 20);
			addChild(m_progressBarBG);
			g = null;
			m_progressBarBG.x = (640 - 400) / 2;
			m_progressBarBG.y = 400;
			m_progressBar = new Shape();
			g = m_progressBar.graphics;
			g.beginFill(0x800000);
			g.drawRect(1, 1, 400 - 2, 20 - 2);
			g = null;
			addChild(m_progressBar);
			m_progressBar.x = m_progressBarBG.x;
			m_progressBar.y = m_progressBarBG.y;
			m_progressBar.scaleX = 0;			
			
			m_newgroundsAd = new FlashAd();
			m_newgroundsAd.x = 320 - 0.5 * m_newgroundsAd.width;
			m_newgroundsAd.y = 70;
			addChild(m_newgroundsAd);
		}
	}
	
	public function checkFrame( e:Event ) : Void
	{
		m_progress = Math.min( Lib.current.root.loaderInfo.bytesLoaded / Lib.current.root.loaderInfo.bytesTotal,
							   m_progress + 0.01 );
							   
		m_progressBar.scaleX = m_progress;
		
		var timeLine = cast(this.parent, MovieClip);
		if ( m_progress > 0.999
		  && Lib.current.root.loaderInfo.bytesLoaded >= Lib.current.root.loaderInfo.bytesTotal
		  && timeLine.currentFrame == timeLine.totalFrames )
		{
			removeChild( m_progressBarBG );
			removeChild( m_progressBar );
			
			Lib.current.gotoAndStop( 2 );
			Lib.current.removeEventListener( Event.ENTER_FRAME, checkFrame, false );

			m_newgroundsAd.removeAd();
			removeChild( m_newgroundsAd );
			m_newgroundsAd = null;
			
			Main.main();
		}
	}
}