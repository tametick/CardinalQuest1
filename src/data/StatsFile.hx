package data;

import flash.errors.SecurityError;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;

/**
 * ...
 * @author randomnine
 */

enum StatsFileFieldType
{
	FIELD_INT;
	FIELD_STRING;
}

class StatsFileFieldDesc
{
	public var m_type : StatsFileFieldType;
	public var m_name : String;
	
	public function new ( _type:StatsFileFieldType, _name:String ) {
		m_type = _type;
		m_name = _name;
	}
}
 
class StatsFileEntry
{
	var m_fieldDescs : Array<StatsFileFieldDesc>;
	var m_fields : Array<Dynamic>;
	
	public function new( _fieldDescs:Array<StatsFileFieldDesc>, _fields:Array<Dynamic> ) {
		m_fieldDescs = _fieldDescs;
		m_fields = _fields;
	}
	
	private function getFieldByIndex( _i:Int ) : Dynamic {
		return m_fields[_i];
	}
	
	public function getField( _keyField:String ) : Dynamic {
		for ( i in 0 ... m_fieldDescs.length ) {
			if ( m_fieldDescs[i].m_name == _keyField ) {
				return getFieldByIndex(i);
			}
		}
		
		return null;
	}
}

class StatsFile 
{
	var m_filename : String;
	var m_loaded : Bool;
	
	var m_fieldDescs : Array<StatsFileFieldDesc>;
	var m_entries : List<StatsFileEntry>;
	
	public static function loadFromString( _filename:String, embedText:String ) : StatsFile {
		var statsFile:StatsFile = new StatsFile( _filename );
		
		statsFile.buildFromText( embedText );
		Resources.statsFiles.set( _filename, statsFile );
		
		return statsFile;
	}
	
	public static function loadFile( _filename:String ) : StatsFile {
		var statsFile:StatsFile = new StatsFile( _filename );
		
		var loader:URLLoader = new URLLoader();
		loader.addEventListener(Event.COMPLETE, statsFile.onLoaded);
		loader.addEventListener(IOErrorEvent.IO_ERROR, statsFile.onFail);
		var request:URLRequest = new URLRequest(_filename);
		try { 
			loader.load(request);
		} catch (error:SecurityError) { 
			loader.removeEventListener(Event.COMPLETE, statsFile.onLoaded);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, statsFile.onFail);
			return null;
		} 

		return statsFile;
	}
	
	private function new( _filename:String ) {
		m_filename = _filename;
		m_loaded = false;
		
		m_fieldDescs = new Array<StatsFileFieldDesc>();
		m_entries = new List<StatsFileEntry>();
	}
	
	function buildFromText( _text:String ) {
		var lines:Array<String> = _text.split( "\r\n" );

		// Parse file data line by line.
		for ( l in lines ) {
			if ( l.substr(0, 6).toLowerCase() == "field " ) {
				// Defining a new field.
				var words:Array<String> = l.split( " " );
				var type:StatsFileFieldType;
				
				if ( words.length == 3 ) {
					if ( words[1].toLowerCase() == "string" ) {
						type = FIELD_STRING;
					} else if ( words[1].toLowerCase() == "int" ) {
						type = FIELD_INT;
					} else {
						trace( "Syntax error in field definition (unknown type \"" + words[1] + "\"." );
						continue;
					}
					
					m_fieldDescs.push( new StatsFileFieldDesc( type, words[2] ) );
				} else {
					trace( "Syntax error in field definition \"" + l + "\" (more than 3 words)." );
				}
			}
			else if ( l.substr(0, 1) != ";" && l.length > m_fieldDescs.length ) { // Let's define an entry!
				var words:Array<String> = l.split( " " );
				var fields:Array<Dynamic> = new Array<Dynamic>();
				
				var wordIndex:Int = 0;
				
				for ( i in 0 ... m_fieldDescs.length ) {
					var curString:String = "";
					
					while ( curString == "" && wordIndex < words.length ) {
						curString = words[wordIndex];
						++wordIndex;
					}
					
					if ( curString == "" && wordIndex >= words.length ) { // We've read all the words we can find.
						if ( m_fieldDescs[i].m_type == FIELD_INT ) {
							fields.push( 0 ); // Default Int value.
						} else {
							fields.push( "" ); // Default String value.
						}
					} else {
						if ( m_fieldDescs[i].m_type == FIELD_INT ) {
							fields.push( Std.parseInt( curString ) );
						} else {
							// Reading a string.
							while ( curString.charAt(0) == '[' && curString.indexOf( "]", 1 ) == -1 )
							{
								if ( words[wordIndex] != "" ) {
									curString += " " + words[wordIndex];
								}
								++wordIndex;
							}
							
							if ( curString.charAt(0) == '[' ) {
								fields.push( curString.substr( 1, curString.length - 2 ) );
							} else {
								fields.push( curString );
							}
						}
					}
				}
				
				m_entries.push( new StatsFileEntry( m_fieldDescs, fields ) );
			}
		}

		m_loaded = true;
	}
	
	function onLoaded( e:Event ) {
		// Parse the stats file!
		var loader:URLLoader = e.target;
		var fileText:String = e.target.data;
		
		buildFromText( fileText );
		
		// Register.
		Resources.statsFiles.set( m_filename, this );
		
		loader.removeEventListener(Event.COMPLETE, this.onLoaded);
		loader.removeEventListener(IOErrorEvent.IO_ERROR, this.onFail);
	}
	
	function onFail( e:Event) {
		var loader:URLLoader = e.target;
		loader.removeEventListener(Event.COMPLETE, this.onLoaded);
		loader.removeEventListener(IOErrorEvent.IO_ERROR, this.onFail);
	}
	
	public function getEntry( _keyField:String, _key:Dynamic ) : StatsFileEntry {
		for ( e in m_entries ) {
			if ( e.getField( _keyField ) == _key ) {
				return e;
			}
		}
		
		return null;
	}
	
	public function iterator() : Iterator<StatsFileEntry> {
		return m_entries.iterator();
	}
}
