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
	public class SerializeErrorEvent extends StackErrorEvent {

		public static const SERIALIZE_ERROR:String = "serializeError";

		public function SerializeErrorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, text:String="", stack:String="", data:*=null) {
			super(type, bubbles, cancelable, text, stack);
		}

		public var data:*;

		public override function clone():Event {
			return new SerializeErrorEvent( super.type, super.bubbles, super.cancelable, super.text, this.stack, this.data );
		}

		public override function toString():String {
			return super.formatToString( ClassUtils.getClassName( this ), "type", "bubbles", "cancelable", "text", "stack", "data" );
		}

	}

}