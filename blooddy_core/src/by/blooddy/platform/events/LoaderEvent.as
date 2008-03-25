////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.events {

	import by.blooddy.platform.utils.ClassUtils;

	import by.blooddy.platform.net.ILoadable;

	import flash.events.Event;

	/**
	 * Евент лоадера.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					logevent, log, event
	 */
	public class LoaderEvent extends Event {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		/**
		 * @eventType			addedLog
		 */
		public static const LOADER_INIT:String = "loaderInit";

		/**
		 * @eventType			addedLog
		 */
		public static const LOADER_ENABLED:String = "loaderEnabled";

		/**
		 * @eventType			addedLog
		 */
		public static const LOADER_DISABLED:String = "loaderDisabled";

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function LoaderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, loader:ILoadable=null) {
			super(type, bubbles, cancelable);
			this.loader = loader;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var loader:ILoadable;

		//--------------------------------------------------------------------------
		//
		//  Overridden methods: Event
		//
		//--------------------------------------------------------------------------

	    /**
	     * @private
	     */
		public override function clone():Event {
			return new LoaderEvent(this.type, this.bubbles, this.cancelable, this.loader);
		}

	    /**
	     * @private
	     */
		public override function toString():String {
			return super.formatToString(ClassUtils.getClassName(this), "type", "bubbles", "cancelable", "loader");
		}

	}

}