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
	public class BattleWorldFieldDataEvent extends DataBaseEvent {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const WIDTH_CHANGE:String =		'widthChange';

		public static const HEIGHT_CHANGE:String =		'heightChange';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldFieldDataEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super( type, bubbles, cancelable );
		}

	}

}