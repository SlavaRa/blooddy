////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.events {

	import flash.events.Event;
	import flash.events.IEventDispatcher;

	/**
	 * Функция проверяет описано ли событие в метаданными событие в объекте. 
	 * 
	 * 
	 * @param	dispatcher		экземпляр
	 * @param	event			событие
	 * 
	 * @return					true, если событие диспатчится, false, если нет.
	 * 
	 * @author					BlooDHounD
	 */
	public function isIntrinsicEvent(dispatcher:IEventDispatcher, event:Event):Boolean {
		var info:EventDispatcherInfo = EventDispatcherInfo.getInfo( dispatcher );
		if (info) return info.hasEvent(event);
		return false;
	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import flash.events.IEventDispatcher;
import flash.events.Event;

import flash.utils.Dictionary;

import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import by.blooddy.platform.utils.ObjectInfo;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: KeyboardDispatcherEvent
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Вспомогательный класс.
 * 
 * @author					BlooDHounD
 */
internal final class EventDispatcherInfo {

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public static function getInfo(dispatcher:IEventDispatcher):EventDispatcherInfo {
		if ( !dispatcher ) return null;
		else return getClassInfo( ( dispatcher as Object ).constructor as Class );
	}

	//--------------------------------------------------------------------------
	//
	//  Private class constants
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private static const _HASH:Dictionary = new Dictionary();

	/**
	 * @private
	 */
	private static const DISPATCHER_LINK:String = getQualifiedClassName(IEventDispatcher);

	//--------------------------------------------------------------------------
	//
	//  Private class methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private static function getClassInfo(c:Object):EventDispatcherInfo {
		var info:EventDispatcherInfo = _HASH[c] as EventDispatcherInfo;
		if (!info) {
			var info2:ObjectInfo = ObjectInfo.getInfo( c );
			_HASH[c] = info = new EventDispatcherInfo();
			info.$setInfo( info2 );
		}
		return info;
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * Constructor.
	 */
	public function EventDispatcherInfo() {
		super();
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private var _info:ObjectInfo;

	/**
	 * @private
	 */
	private const _events:Object = new Object();

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private var _parent:EventDispatcherInfo;

	/**
	 * @private
	 */
	public function get parent():EventDispatcherInfo {
		if ( !this._parent && this._info.parent && this._info.parent.hasInterface( DISPATCHER_LINK ) ) {
			this._parent = getClassInfo( getDefinitionByName( this._info.parent.name.toString() ) );
		}
		return this._parent;
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public function hasEvent(event:Event):Boolean {
		var c:Class = this._events[event.type.toLowerCase()] as Class;
		if ( c && event is c ) return true;
		else if ( this.parent && this.parent.hasEvent(event) ) return true;
		return false;
	}

	//--------------------------------------------------------------------------
	//
	//  Private methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private function $setInfo(info:ObjectInfo):void {
		this._info = info;
		var list:XMLList, xml:XML, arg:XML, name:String, type:Object;
		list = info.getMetadata("Event", ObjectInfo.META_SELF);
		for each (xml in list) {
			arg = xml.arg.(@key=="name")[0];
			if ( arg && ( name = arg.@value.toXMLString().toLowerCase() ) ) {
				arg = xml.arg.(@key=="type")[0];
				if ( arg && ( type = getDefinitionByName( arg.@value.toXMLString() ) ) ) {
					_events[name] = type;
				}
			}
		}
	}

}