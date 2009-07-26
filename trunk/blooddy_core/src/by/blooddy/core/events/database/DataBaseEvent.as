////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.events.database {

	import by.blooddy.core.database.DataBaseNativeEvent;
	
	import flash.events.Event;

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
		 * @see					by.blooddy.core.database.Data
		 */
		public static const ADDED:String = 'added';

		/**
		 * @eventType			added
		 * 
		 * @see					by.blooddy.core.database.Data
		 */
		public static const REMOVED:String = 'removed';

		/**
		 * @eventType			addedToBase
		 * 
		 * @see					by.blooddy.core.database.Data
		 * @see					by.blooddy.core.database.DataBase
		 */
		public static const ADDED_TO_BASE:String = 'addedToBase';

		/**
		 * @eventType			removedFromBase
		 * 
		 * @see					by.blooddy.core.database.Data
		 * @see					by.blooddy.core.database.DataBase
		 */
		public static const REMOVED_FROM_BASE:String = 'removedFromBase';

		/**
		 * @eventType			change
		 * 
		 * @see					by.blooddy.core.database.Data
		 * @see					by.blooddy.core.database.DataBase
		 */
		public static const CHANGE:String = Event.CHANGE;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 * 
		 * @param	type		The type of the event, accessible as Event.type.
		 * @param	bubbles		Determines whether the Event object participates in
		 * 						the bubbling stage of the event flow.
		 * @param	cancelable	Determines whether the Event object can be canceled.
		 */
		public function DataBaseEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super( type, bubbles, cancelable );
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
			var c:Class = ( this as Object ).constructor as Class;
			return new c( super.type, super.bubbles, super.cancelable );
		}

		/**
		 * @private
		 */
		public override function toString():String {
			return super.formatToString( null, 'type', 'bubbles', 'cancelable' );
		}

	}

}