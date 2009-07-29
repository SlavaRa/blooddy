////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.events.time {

	import by.blooddy.core.utils.ClassUtils;
	
	import flash.events.Event;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					29.07.2009 22:46:41
	 */
	public class TimeEvent extends Event {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const RELATIVITY_CHANGE:String = 'relativityChange';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function TimeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super( type, bubbles, cancelable );
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public override function clone():Event {
			return new TimeEvent( super.type, super.bubbles, super.cancelable );
		}

		public override function toString():String {
			return super.formatToString( ClassUtils.getClassName( this ), 'type', 'bubbles', 'cancelable' );
		}

	}

}