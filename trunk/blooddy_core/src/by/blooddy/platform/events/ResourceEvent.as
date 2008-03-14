////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.events {

	import by.blooddy.platform.utils.ClassUtils;

	import flash.events.Event;

	/**
	 * Евент ресурс манагера.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					resourceevent, resource, event
	 * 
	 * @see						platform.managers.ResourceManager
	 */
	public class ResourceEvent extends Event {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		/**
		 * @eventType			bundleAdded
		 */
		public static const BUNDLE_ADDED:String = "bundleAdded";

		/**
		 * @eventType			bundleRemoved
		 */
		public static const BUNDLE_REMOVED:String = "bundleRemoved";

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 * 
		 * @param	type			The event type; indicates the action that caused the event.
		 * @param	bubbles			Specifies whether the event can bubble up the display list hierarchy.
		 * @param	cancelable		Specifies whether the behavior associated with the event can be prevented.
		 * @param	bundle			ПучОк.
		 */
		public function ResourceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, bundleName:String=null) {
			super(type, bubbles, cancelable);
			this.bundleName = bundleName;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  bundleName
		//----------------------------------

		/**
		 * Имя изменённого "пучка".
		 * 
		 * @keyword					resourceevent.bundlename, bundlename
		 */
		public var bundleName:String;

		//--------------------------------------------------------------------------
		//
		//  Overridden methods: Event
		//
		//--------------------------------------------------------------------------

	    /**
	     * @private
	     */
		public override function clone():Event {
			return new ResourceEvent(this.type, this.bubbles, this.cancelable, this.bundleName);
		}

	    /**
	     * @private
	     */
		public override function toString():String {
			return super.formatToString(ClassUtils.getClassName(this), "type", "bubbles", "cancelable", "bundleName");
		}

	}

}