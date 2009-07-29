////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.events.database.character {

	import by.blooddy.core.events.database.DataBaseEvent;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class CharacterDataEvent extends DataBaseEvent {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function CharacterDataEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super( type, bubbles, cancelable );
		}

	}

}