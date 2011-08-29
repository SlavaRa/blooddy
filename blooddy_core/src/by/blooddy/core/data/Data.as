////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.data {

	import by.blooddy.core.events.data.DataBaseEvent;
	import by.blooddy.core.utils.ClassUtils;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.EventPhase;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * Добавили в контэйнер.
	 * 
	 * @eventType			by.blooddy.core.events.data.DataBaseEvent.ADDED
	 */
	[Event( name="added", type="by.blooddy.core.events.data.DataBaseEvent" )]

	/**
	 * Удалили из контэйнера.
	 * 
	 * @eventType			by.blooddy.core.events.data.DataBaseEvent.REMOVED
	 */
	[Event( name="removed", type="by.blooddy.core.events.data.DataBaseEvent" )]

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude( kind="namespace", name="$protected_data" )]

	[Exclude( kind="property", name="_parent" )]

	[Exclude( kind="method", name="setParent" )]

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
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		protected namespace $protected_data;

		use namespace $protected_data;

		use namespace $internal;

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
		$protected_data var _parent:DataContainer;

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
		$protected_data function setParent(value:DataContainer):void {
			if ( this._parent === value ) return;
			var old:DataContainer = this._parent;
			this._parent = value;
			if ( old && old != value ) { // мы потеряли СТАРОГО папу
				this.dispatchEventFunction( new DataBaseEvent( DataBaseEvent.REMOVED, true ) );
			}
			value = this._parent;
			this._bubble_parent = value;
			if ( value && value != old ) { // появился НОВЫЙ папа :)
				this.dispatchEventFunction( new DataBaseEvent( DataBaseEvent.ADDED, true ) );
			}
		}

		//----------------------------------
		//  name
		//----------------------------------

		/**
		 * @private
		 */
		private var _name:String = '';

		/**
		 * имя модели
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
			if ( this._name == value ) return;
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
			if ( event.bubbles ) {
				if ( event is DataBaseEvent ) return this.dispatchEventFunction( event as DataBaseEvent );
				else throw new TypeError( 'bubbling поддерживается только у событий наследованных от DataBaseEvent' );
			} else return super.dispatchEvent( event );
		}

		/**
		 * @private
		 */
		private function $dispatchEvent(event:Event):Boolean {
			return super.dispatchEvent( event );
		}

		/**
		 * @private
		 */
		private function dispatchEventFunction(event:DataBaseNativeEvent):Boolean {
			var canceled:Boolean = false;
			if ( super.hasEventListener( event.type ) ) {
				canceled = !super.dispatchEvent( event );
			}
			// надо бублить
			var target:Data = this._bubble_parent;
			var e:DataBaseNativeEvent;
			while ( target ) {
				if ( target.hasEventListener( event.type ) ) {
					e = event.clone() as DataBaseNativeEvent;
					e.$eventPhase = EventPhase.BUBBLING_PHASE;
					e.$target = this;
					e.$canceled = canceled;
					CONTAINER.$event = e;
					target.$dispatchEvent( CONTAINER );
					canceled &&= e.$canceled;
					if ( e.$stopped ) break;
				}
				target = target._bubble_parent;
			}
			return !canceled;
		}

		//----------------------------------
		//  dispatchEvent
		//----------------------------------

		/**
		 * @private
		 */
		public override function willTrigger(type:String):Boolean {
			if ( super.hasEventListener( type ) ) {
				return true;
			}
			// надо бублить
			var target:Data = this._bubble_parent;
			while ( target ) {
				if ( target.hasEventListener( type ) ) {
					return true;
				}
				target = target._bubble_parent;
			}
			return false;
		}

		//----------------------------------
		//  toLocaleString
		//----------------------------------

		public function toLocaleString():String {
			return '[' + ClassUtils.getClassName( this ) + ']';
		}

		//----------------------------------
		//  toString
		//----------------------------------

		/**
		 * @private
		 */
		public override function toString():String {
			return ( this._parent ? this._parent + '.' : '' ) + ( this._name ? this._name : this.toLocaleString() );
		}

		//----------------------------------
		//  formatToString
		//----------------------------------

		/**
		 * @private
		 */
		protected final function formatToString(...args):String {
			var l:uint = args.length;
			var v:*;
			for ( var i:uint = 0; i<l; ++i ) {
				v = this[ args[ i ] ];
				if ( v is String )	v = '"' + v + '"';
				args[ i ] += '=' + v;
			}
			return '[' + ClassUtils.getClassName( this ) + ( args.length  > 0 ? ' ' + args.join( ' ' ) : '' ) + ']';
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
	public function EventContainer() {
		super( '', true );
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	internal var $event:Event;

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
		return this.$event;
	}

}

internal const CONTAINER:EventContainer = new EventContainer();