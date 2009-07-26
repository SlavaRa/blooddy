package by.blooddy.core.events {

	import flash.events.Event;

	public class POP3Event extends Event {

		public static const COUNT_CHANGED:String = "countChanged";

		public static const SIZE_CHANGED:String = "sizeChanged";

		public function POP3Event(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}

	}

}