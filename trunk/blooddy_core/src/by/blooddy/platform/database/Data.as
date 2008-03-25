////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 BlooDHounD.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.database {

	import by.blooddy.platform.events.DataBaseEvent;
	import flash.events.Event;

	import flash.events.EventPhase;

	import flash.events.EventDispatcher;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * Добавили в контэйнер.
	 * 
	 * @eventType			by.blooddy.platform.events.DataBaseEvent.ADDED
	 */
	[Event(name="added", type="by.blooddy.platform.events.DataBaseEvent")]

	/**
	 * Удалили из контэйнера.
	 * 
	 * @eventType			by.blooddy.platform.events.DataBaseEvent.REMOVED
	 */
	[Event(name="removed", type="by.blooddy.platform.events.DataBaseEvent")]

	/**
	 * Транслируется, когда объект добавляется в базу.
	 * 
	 * @eventType			by.blooddy.platform.events.DataBaseEvent.ADDED_TO_BASE
	 * 
	 * @see					by.blooddy.platform.database.DataBase
	 */
	[Event(name="addedToBase", type="by.blooddy.platform.events.DataBaseEvent")]

	/**
	 * Транслируется, когда объект даляется из базу.
	 * 
	 * @eventType			by.blooddy.platform.events.DataBaseEvent.REMOVED_FROM_BASE
	 * 
	 * @see					by.blooddy.platform.database.DataBase
	 */
	[Event(name="removedFromBase", type="by.blooddy.platform.events.DataBaseEvent")]

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude(name="$parent", kind="property")]
	[Exclude(name="$base", kind="property")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					data
	 */
	public class Data extends EventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function Data() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  parent
		//----------------------------------

		/**
		 * @private
		 */
		private var _parent:DataContainer;

		/**
		 * @private
		 */
		private var _bubble_parent:DataContainer;

		/**
		 * Родитель элемента.
		 * 
		 * @keyword					data.parent, parent
		 */
		public function get parent():DataContainer {
			return this._parent;
		}

		/**
		 * @private
		 */
		internal function get $parent():DataContainer {
			return this._parent;
		}

		/**
		 * @private
		 */
		internal function set $parent(value:DataContainer):void {
			if (this._parent === value) return;
			var old:DataContainer = this._parent;
			this._parent = value;
			if (old && old!=value) { // мы потеряли СТАРОГО папу
				this.$dispatchEvent( new DataBaseEvent(DataBaseEvent.REMOVED, true) );
			}
			this._bubble_parent = value;
			if (value && value!=old) { // появился НОВЫЙ папа :)
				this.$dispatchEvent( new DataBaseEvent(DataBaseEvent.ADDED, true) );
			}
		}

		//----------------------------------
		//  base
		//----------------------------------

		/**
		 * @private
		 */
		private var _base:DataBase;

		/**
		 * Родитель элемента.
		 * 
		 * @keyword					data.base, base
		 */
		public function get base():DataBase {
			return this._base;
		}

		/**
		 * @private
		 */
		internal function get $base():DataBase {
			return this._base;
		}

		/**
		 * @private
		 */
		internal function set $base(value:DataBase):void {
			if (this._base === value) return;
			var old:DataContainer = this._base;
			this._base = value;
			if (old && old!=value) { // мы потеряли СТАРУЮ базу
				super.dispatchEvent( new DataBaseEvent(DataBaseEvent.REMOVED_FROM_BASE) );
			}
			if (value && value!=old) { // появилась НОВАЯ база :)
				super.dispatchEvent( new DataBaseEvent(DataBaseEvent.ADDED_TO_BASE) );
			}
		}

		//----------------------------------
		//  name
		//----------------------------------

		/**
		 * @private
		 */
		private var _name:String = "";

		/**
		 * ID-элементы.
		 * 
		 * @keyword					data.name, name
		 */
		public function get name():String {
			return this._name;
		}

		/**
		 * @private
		 */
		public function set name(value:String):void {
			if (this._name == value) return;
			this._name = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods: EventDispatcher
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  dispatchEvent
		//----------------------------------

		/**
		 * @private
		 */
		public override function dispatchEvent(event:Event):Boolean {
			if (event.bubbles) {
				if (event is DataBaseNativeEvent) return this.$dispatchEvent(event as DataBaseNativeEvent);
				else throw new ArgumentError();
			} else return super.dispatchEvent(event);
		}

		/**
		 * @private
		 */
		private function $dispatchEvent(event:DataBaseNativeEvent, eventPhase:uint=EventPhase.AT_TARGET):Boolean {
			// если бублинг фаза, то надо склонировать и определить всякую фигню
			if (eventPhase == EventPhase.BUBBLING_PHASE) {
				var target:Object = event.target;
				event = event.clone() as DataBaseNativeEvent;
				event.$eventPhase = eventPhase;
				event.$target = target;
			} else if (eventPhase == EventPhase.AT_TARGET) {
				event.$target = this;
			}
			var container:EventContainer = new EventContainer( event );
			var result:Boolean = super.dispatchEvent( container );
			if (!event.$stopped && result) {
				// надо бублить
				if (event.bubbles && this._bubble_parent) {
					result = this._bubble_parent.$dispatchEvent(event, EventPhase.BUBBLING_PHASE);
				}
			}
			return result;
		}

		//----------------------------------
		//  toString
		//----------------------------------

		/**
		 * @private
		 */
		public override function toString():String {
			return ( this._parent ? this._parent+"." : "" ) + ( this._name ? this._name : super.toString() );
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import flash.events.Event;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: EventContainer
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Вспомогательный класс.
 * 
 * Является контэйнером, для евента.
 * Хук, для того, что бы передать нормальный таргет средствами стандартного EventDispatcher'а.
 */
internal final class EventContainer extends Event {

	//--------------------------------------------------------------------------
	//
	//  Private class constants
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private static const TARGET:Object = new Object();

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * Constructor.
	 */
	public function EventContainer(event:Event) {
		super(event.type, event.bubbles, event.cancelable);
		this._event = event;
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private var _event:Event;

	//--------------------------------------------------------------------------
	//
	//  Overridden properties: Event
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * Возвращает левый таргет, для того что бы обмануть EventDispatcher.
	 */
	public override function get target():Object {
		return TARGET;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: Event
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * Возвращаем наш евент.
	 */
	public override function clone():Event {
		return this._event;
	}

}