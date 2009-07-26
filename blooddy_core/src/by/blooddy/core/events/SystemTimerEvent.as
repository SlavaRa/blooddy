package by.blooddy.core.events {

	import flash.events.TimerEvent;
	import flash.events.Event;
	import by.blooddy.core.utils.ClassUtils;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class SystemTimerEvent extends TimerEvent {

		//--------------------------------------------------------------------------
		//
		//  Constants
		//
		//--------------------------------------------------------------------------

		/**
		 * @eventType			relativeSync
		 */
		public static const RELATIVE_SYNC:String = "relativeSync";

		/**
		 * @eventType			timeSync
		 */
		public static const ABSOLUTE_SYNC:String = "absoluteSync";

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function SystemTimerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, delta:Number=0) {
			super(type, bubbles, cancelable);
			this.delta = delta;
		}

		public var delta:Number;

		//--------------------------------------------------------------------------
		//
		//  Overriden methods: Event
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function clone():Event {
			return new SystemTimerEvent(super.type, super.bubbles, super.cancelable, this.delta);
		}

		/**
		 * @private
		 */
		public override function toString():String {
			return super.formatToString( ClassUtils.getClassName( this ), "type", "bubbles", "cancelable", "delta" );
		}

	}

}