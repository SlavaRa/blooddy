////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 BlooDHounD.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.events {

	import flash.events.Event;

	import by.blooddy.platform.database.DataBaseNativeEvent;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					databaseevent, database, data, event
	 */
	public class DataBaseEvent extends DataBaseNativeEvent {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @eventType			added
		 * 
		 * @see					by.blooddy.platform.database.Data
		 */
		public static const ADDED:String = "added";

		/**
		 * @eventType			added
		 * 
		 * @see					by.blooddy.platform.database.Data
		 */
		public static const REMOVED:String = "removed";

		/**
		 * @eventType			addedToBase
		 * 
		 * @see					by.blooddy.platform.database.Data
		 * @see					by.blooddy.platform.database.DataBase
		 */
		public static const ADDED_TO_BASE:String = "addedToBase";

		/**
		 * @eventType			removedFromBase
		 * 
		 * @see					by.blooddy.platform.database.Data
		 * @see					by.blooddy.platform.database.DataBase
		 */
		public static const REMOVED_FROM_BASE:String = "removedFromBase";

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 * 
		 * @param	type		The type of the event, accessible as Event.type.
		 * @param	bubbles		Determines whether the Event object participates in
		 * 						the bubbling stage of the event flow.
		 * @param	cancelable	Determines whether the Event object can be canceled.
		 */
		public function DataBaseEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods: Event
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function clone():Event {
			return new DataBaseEvent(super.type, super.bubbles, super.cancelable);
		}

		/**
		 * @private
		 */
		public override function toString():String {
			return super.formatToString(null, "type", "bubbles", "cancelable");
		}

	}

}