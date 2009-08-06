////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.events.database.world {

	import by.blooddy.core.events.database.DataBaseEvent;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					04.08.2009 22:42:55
	 */
	public class BattleWorldDataEvent extends DataBaseEvent {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const WIDTH_CHANGE:String =		'widthChange';

		public static const HEIGHT_CHANGE:String =		'heightChange';

		public static const ADDED_TO_WORLD:String =		'addedToWorld'

		public static const REMOVED_FROM_WORLD:String =	'removedFromWorld';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldDataEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super( type, bubbles, cancelable );
		}

	}

}