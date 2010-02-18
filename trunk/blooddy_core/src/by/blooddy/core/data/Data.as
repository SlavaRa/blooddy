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

	/**
	 * Транслируется, когда объект добавляется в базу.
	 * 
	 * @eventType			by.blooddy.core.events.data.DataBaseEvent.ADDED_TO_BASE
	 * 
	 * @see					by.blooddy.core.data.DataBase
	 */
	[Event( name="addedToBase", type="by.blooddy.core.events.data.DataBaseEvent" )]

	/**
	 * Транслируется, когда объект удаляется из базы.
	 * 
	 * @eventType			by.blooddy.core.events.data.DataBaseEvent.REMOVED_FROM_BASE
	 * 
	 * @see					by.blooddy.core.data.DataBase
	 */
	[Event( name="removedFromBase", type="by.blooddy.core.events.data.DataBaseEvent" )]

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
		internal var $parent:DataContainer;

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
			return this.$parent;
		}

		/**
		 * @private
		 */
		internal function set$parent(value:DataContainer):void {
			if ( this.$parent === value ) return;
			var old:DataContainer = this.$parent;
			this.$parent = value;
			if ( old && old != value ) { // мы потеряли СТАРОГО папу
				if ( super.hasEventListener( DataBaseEvent.REMOVED_FROM_BASE ) ) {
					super.dispatchEvent( new DataBaseEvent( DataBaseEvent.REMOVED_FROM_BASE ) );
				}
				this.dispatchEventFunction( new DataBaseEvent( DataBaseEvent.REMOVED, true ) );
			}
			value = this.$parent;
			this._bubble_parent = value;
			if ( value && value != old ) { // появился НОВЫЙ папа :)
				if ( super.hasEventListener( DataBaseEvent.ADDED_TO_BASE ) ) {
					super.dispatchEvent( new DataBaseEvent( DataBaseEvent.ADDED_TO_BASE ) );
				}
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
				else throw new ArgumentError( 'bubbling поддерживается только у событий наследованных от DataBaseEvent' );
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
					target.$dispatchEvent( new EventContainer( e ) );
					canceled = e.$canceled;
					if ( event.$stopped ) break;
				}
				target = target._bubble_parent;
			}
			return !canceled;
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
			return ( this.$parent ? this.$parent + '.' : '' ) + ( this._name ? this._name : this.toLocaleString() );
		}

		//----------------------------------
		//  formatToString
		//----------------------------------

		/**
		 * @private
		 */
		protected final function formatToString(...arguments):String {
			var l:uint = arguments.length;
			var v:*;
			for ( var i:uint = 0; i<l; i++ ) {
				v = this[ arguments[ i ] ];
				if ( v is String )	v = '"' + v + '"';
				arguments[ i ] += '=' + v; 
			}
			return '[' + ClassUtils.getClassName( this ) + ( arguments.length  > 0 ? ' ' + arguments.join( ' ' ) : '' ) + ']';
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
		super( event.type, event.bubbles, event.cancelable );
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