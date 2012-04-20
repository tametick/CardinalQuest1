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
	private var m_sharedObject:SharedObject;

	private var m_intSeek:Int;
	private var m_stringSeek:Int;
	
	public function new() 
	{
		try
		{	  
			m_sharedObject = SharedObject.getLocal( "cardinalQuest" );
			m_intSeek = 0;
			m_stringSeek = 0;
		}
		catch( msg:Dynamic )
		{
			if ( Configuration.debug ) {
				trace( "Could not access local shared object: " + Std.string(msg));
			}
		}
	}
	
	public function hasSave() : Bool {
		if ( m_sharedObject != null && Reflect.hasField( m_sharedObject.data, "version" )  ) {
			if ( m_sharedObject.data.version == Configuration.version ) {
				return true;
			}
		}
		
		return false;
	}
	
	public function clearSave() {
		startWrite();
		m_sharedObject.data.version = 0;
		completeWrite();
	}
	
	// loading---
	public function startLoad() {
		m_intSeek = 0;
		m_stringSeek = 0;
	}
	
	public function seekToBlock( _name:String, ?_prev:Int = -1 ) : Int {
		var checkBlock:Int = _prev + 1;
		
		while ( checkBlock < m_sharedObject.data.blockName.length ) {
			if ( m_sharedObject.data.blockName[checkBlock] == _name ) {
				m_intSeek = m_sharedObject.data.blockIntSeek[checkBlock];
				m_stringSeek = m_sharedObject.data.blockStringSeek[checkBlock];
				return checkBlock;
			}
			checkBlock++;
		}
		
		return -1;
	}
	
	public function readInt():Int {
		return m_sharedObject.data.ints[m_intSeek++];
	}
	
	public function readString():String {
		return m_sharedObject.data.strings[m_stringSeek++];
	}
	
	// saving---
	public function startWrite() {
		m_sharedObject.data.version = Configuration.version;
		
		m_sharedObject.data.blockName = new Array<Int>();
		m_sharedObject.data.blockIntSeek = new Array<Int>();
		m_sharedObject.data.blockStringSeek = new Array<Int>();
		
		m_sharedObject.data.ints = new Array<Int>();
		m_sharedObject.data.strings = new Array<String>();
	}

	public function startBlock( _name:String ) {
		m_sharedObject.data.blockName.push( _name );
		m_sharedObject.data.blockIntSeek.push( m_intSeek );
		m_sharedObject.data.blockStringSeek.push( m_stringSeek );
	}
	
	public function writeInt( _v:Int ) {
		m_sharedObject.data.ints.push( _v );
		m_intSeek++;
	}
	
	public function writeString( _s:String ) {
		m_sharedObject.data.strings.push( _s );
		m_stringSeek++;
	}
	
	public function completeWrite() {
		m_sharedObject.flush();
	}
}