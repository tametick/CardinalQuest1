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
			if ( s_sharedObject.data.version == Configuration.version ) {
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
		s_sharedObject.data.version = Configuration.version;
		
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
}