////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.utils {

	import flash.utils.Proxy;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getDefinitionByName;

	//--------------------------------------
	//  Events
	//--------------------------------------

	use namespace AS3;

	/**
	 * @copy		flash.events.EventDispatcher#deactivate
	 */
	[Event(name="activate", type="flash.events.Event")]

	/**
	 * @copy		flash.events.EventDispatcher#activate
	 */
	[Event(name="deactivate", type="flash.events.Event")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					proxyeventdispatcher, proxy, eventdispatcher
	 */
	public dynamic class ProxyEventDispatcher extends Proxy implements IEventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructior.
		 */
		public function ProxyEventDispatcher() {
			super();
			this.constructor = getDefinitionByName( getQualifiedClassName( this ) );
			this._dispatcher = new EventDispatcher( this );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _dispatcher:EventDispatcher;

		/**
		 * @private
		 */
		public var constructor:Object;

		//--------------------------------------------------------------------------
		//
		//  Implements methods: IEventDispatcher
		//
		//--------------------------------------------------------------------------

		/**
		 * @copy		flash.events.EventDispatcher#addEventListener()
		 */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			this._dispatcher.addEventListener( type, listener, useCapture, priority, useWeakReference );
		}

		/**
		 * @copy		flash.events.EventDispatcher#removeEventListener()
		 */
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
			this._dispatcher.removeEventListener( type, listener, useCapture );
		}

		/**
		 * @copy		flash.events.EventDispatcher#dispatchEvent()
		 */
		public function dispatchEvent(event:Event):Boolean {
			return this._dispatcher.dispatchEvent( event );
		}

		/**
		 * @copy		flash.events.EventDispatcher#hasEventListener()
		 */
		public function hasEventListener(type:String):Boolean {
			return this._dispatcher.hasEventListener( type );
		}

		/**
		 * @copy		flash.events.EventDispatcher#willTrigger()
		 */
		public function willTrigger(type:String):Boolean {
			return this._dispatcher.willTrigger( type );
		}

	}

}