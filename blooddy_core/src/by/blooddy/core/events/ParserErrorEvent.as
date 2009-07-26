////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.events {

	import by.blooddy.core.utils.ClassUtils;

	import flash.events.Event;
	import flash.events.ErrorEvent;

	/**
	 * Евент ошибки парсера.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					parsererrorevent, parsererror, parser, error, event
	 */
	public class ParserErrorEvent extends ErrorEvent {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		/**
		 * @eventType			parserError
		 */
		public static const PARSER_ERROR:String = "parserError";

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function ParserErrorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, text:String="") {
			super(type, bubbles, cancelable, text);
		}

		//--------------------------------------------------------------------------
		//
		//  Overridden methods: Event
		//
		//--------------------------------------------------------------------------

	    /**
	     * @private
	     */
		public override function clone():Event {
			return new ParserErrorEvent(this.type, this.bubbles, this.cancelable, this.text);
		}

	    /**
	     * @private
	     */
		public override function toString():String {
			return super.formatToString(ClassUtils.getClassName(this), "type", "bubbles", "cancelable", "text");
		}

	}

}