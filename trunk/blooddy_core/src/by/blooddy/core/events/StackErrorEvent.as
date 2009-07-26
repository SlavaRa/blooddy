////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.events {

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import by.blooddy.core.utils.ClassUtils;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class StackErrorEvent extends ErrorEvent {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const ERROR:String = ErrorEvent.ERROR;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
 		 * Constructor
		 */
		public function StackErrorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, text:String="", stack:String="") {
			super(type, bubbles, cancelable, text);
			this.stack = stack;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var stack:String = "";

		//--------------------------------------------------------------------------
		//
		//  Overriden methods: Event
		//
		//--------------------------------------------------------------------------

		public override function clone():Event {
			return new StackErrorEvent( super.type, super.bubbles, super.cancelable, super.text, this.stack );
		}

		public override function toString():String {
			return super.formatToString( ClassUtils.getClassName( this ), "type", "bubbles", "cancelable", "text", "stack" );
		}

	}

}