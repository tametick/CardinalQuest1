package data.io;

import Reflect;

import flash.net.SharedObject;

import data.Configuration;

/**
 * ...
 * @author randomnine
 */

class FlashSharedObjectIO implements SaveGameIO
{
	private static var s_sharedObject:SharedObject = null;

	private var m_intSeek:Int;
	private var m_stringSeek:Int;
	
	public function new() 
	{
		if ( s_sharedObject == null ) {
			try
			{	  
				s_sharedObject = SharedObject.getLocal( "cardinalQuest" );
			}
			catch( msg:Dynamic )
			{
				if ( Configuration.debug ) {
					trace( "Could not access local shared object: " + Std.string(msg));
				}
			}
		}
		
		m_intSeek = 0;
		m_stringSeek = 0;
	}
	
	public function hasSave() : Bool {
		if ( s_sharedObject != null && Reflect.hasField( s_sharedObject.data, "version" )  ) {
			if ( s_sharedObject.data.version == Configuration.saveVersion ) {
				return true;
			}
		}
		
		return false;
	}
	
	public function clearSave() {
		startWrite();
		s_sharedObject.data.version = 0;
		completeWrite();
	}
	
	// loading---
	public function startLoad() {
		m_intSeek = 0;
		m_stringSeek = 0;
	}
	
	public function seekToBlock( _name:String, ?_prev:Int = -1 ) : Int {
		var checkBlock:Int = _prev + 1;
		
		while ( checkBlock < s_sharedObject.data.blockName.length ) {
			if ( s_sharedObject.data.blockName[checkBlock] == _name ) {
				m_intSeek = s_sharedObject.data.blockIntSeek[checkBlock];
				m_stringSeek = s_sharedObject.data.blockStringSeek[checkBlock];
				return checkBlock;
			}
			checkBlock++;
		}
		
		return -1;
	}
	
	public function readInt():Int {
		return s_sharedObject.data.ints[m_intSeek++];
	}
	
	public function readString():String {
		return s_sharedObject.data.strings[m_stringSeek++];
	}
	
	// saving---
	public function startWrite() {
		s_sharedObject.data.version = Configuration.saveVersion;
		
		s_sharedObject.data.blockName = new Array<String>();
		s_sharedObject.data.blockIntSeek = new Array<Int>();
		s_sharedObject.data.blockStringSeek = new Array<Int>();
		
		s_sharedObject.data.ints = new Array<Int>();
		s_sharedObject.data.strings = new Array<String>();
	}

	public function startBlock( _name:String ) {
		s_sharedObject.data.blockName.push( _name );
		s_sharedObject.data.blockIntSeek.push( m_intSeek );
		s_sharedObject.data.blockStringSeek.push( m_stringSeek );
	}
	
	public function writeInt( _v:Int ) {
		s_sharedObject.data.ints.push( _v );
		m_intSeek++;
	}
	
	public function writeString( _s:String ) {
		s_sharedObject.data.strings.push( _s );
		m_stringSeek++;
	}
	
	public function completeWrite() {
		s_sharedObject.flush();
	}
	
	// settings: adding here because it's probably the easiest place to change it in the future if something crops up
	public function getSetting(key:String, ?defaultValue:Dynamic = null, ?type:Dynamic = null):Dynamic {
		if ( s_sharedObject == null || !Reflect.hasField(s_sharedObject.data, "settings") || !Reflect.hasField(s_sharedObject.data.settings, key)) {
			return defaultValue;
		} else {
			var v = Reflect.getProperty(s_sharedObject.data.settings, key);
			
			if (v == null || (type != null && !Std.is(v, type))) {
				return defaultValue;
			} else {
				return v;
			}
		}
	}
	
	public function saveSetting(key:String, value:Dynamic):Void {
		if ( s_sharedObject == null) {
			return;
		}
		if (!Reflect.hasField(s_sharedObject.data, "settings")) {
			s_sharedObject.data.settings = { };
		}
		
		Reflect.setField(s_sharedObject.data.settings, key, value);
		
		s_sharedObject.flush(); // yep!  this is bad, but settings save when we switch them
	}
}
