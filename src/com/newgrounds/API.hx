package com.newgrounds;

extern class API {
	function new() : Void;
	static var DEBUG_MODE_HOST_BLOCKED(default,never) : String;
	static var DEBUG_MODE_LOGGED_IN(default,never) : String;
	static var DEBUG_MODE_LOGGED_OUT(default,never) : String;
	static var DEBUG_MODE_NEW_VERSION(default,never) : String;
	static var RELEASE_MODE(default,never) : String;
	static var VERSION(default,never) : String;
	static var adFeedURL(default,never) : String;
	static var adsApproved(default,never) : Bool;
	static var apiId(default,never) : String;
	static var connected(default,never) : Bool;
	static var debugMode : String;
	static var hasUserSession(default,never) : Bool;
	static var hostDomain(default,never) : String;
	static var hostURL(default,never) : String;
	static var isNetworkHost(default,never) : Bool;
	static var isNewgrounds(default,never) : Bool;
	static var medals(default,never) : Array<Dynamic>;
	static var publisherId(default,never) : UInt;
	static var saveGroups(default,never) : Array<Dynamic>;
	static var scoreBoards(default,never) : Array<Dynamic>;
	static var sessionId(default,never) : String;
	static var userId(default,never) : UInt;
	static var username(default,never) : String;
	static function addEventListener(p1 : String, p2 : Dynamic, p3 : Int = 0, p4 : Bool = true) : Void;
	static function clearLocalMedals() : Void;
	static function connect(p1 : flash.display.DisplayObject, p2 : String, ?p3 : String, ?p4 : String) : Void;
	static function createSaveFile(p1 : String) : SaveFile;
	static function createSaveQuery(p1 : String) : SaveQuery;
	static function createSaveQueryByDate(p1 : String, p2 : Bool = true) : SaveQuery;
	static function createSaveQueryByName(p1 : String, p2 : String, p3 : Bool = false, p4 : Bool = false) : SaveQuery;
	static function createSaveQueryByRating(p1 : String, p2 : String, p3 : Bool = true) : SaveQuery;
	static function disconnect() : Void;
	static function getMedal(p1 : String) : Medal;
	static function getSaveGroup(p1 : String) : SaveGroup;
	static function getScoreBoard(p1 : String) : ScoreBoard;
	static function loadCustomLink(p1 : String) : Void;
	static function loadLocal(p1 : String) : Dynamic;
	static function loadMySite() : Void;
	static function loadNewgrounds() : Void;
	static function loadOfficialVersion() : Void;
	static function loadSaveFile(p1 : UInt, p2 : Bool = true) : Void;
	static function loadScores(p1 : String, ?p2 : String, p3 : UInt = 1, p4 : UInt = 10, ?p5 : String) : ScoreBoard;
	static function logCustomEvent(p1 : String) : Void;
	static function postScore(p1 : String, p2 : Float, ?p3 : String) : Void;
	static function removeEventListener(p1 : String, p2 : Dynamic) : Void;
	static function saveLocal(p1 : String, p2 : Dynamic) : Bool;
	static function setFont(p1 : flash.text.TextField, p2 : String) : Void;
	static function stopPendingCommands() : Void;
	static function unlockMedal(p1 : String) : Void;
}
