package by.blooddy.gui.events {

	import by.blooddy.platform.utils.ClassUtils;
	import flash.events.Event;

	public class UIControlEvent extends Event {

		public static const RESIZE:String = Event.RESIZE;

		public static const MOVE:String = "move";

		public static const CENTER_CHANGE:String = "centerChange";

		public function UIControlEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods: Event
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function formatToString(className:String, ...arguments):String {
			if (!className) className = ClassUtils.getClassName(this);
			(arguments as Array).unshift( className );
			return super.formatToString.apply(this, arguments);
		}

	}

}