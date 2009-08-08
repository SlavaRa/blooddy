package by.blooddy.core.events.managers {

	import flash.events.Event;
	import by.blooddy.core.utils.ClassUtils;

	public class RemoteModuleEvent extends Event {

		public static const INIT:String = Event.INIT;

		public static const UNLOAD:String = Event.UNLOAD;

		public function RemoteModuleEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, id:String=null) {
			super(type, bubbles, cancelable);
			this.id = id;
		}

		public var id:String = id;

		public override function clone():Event {
			return new RemoteModuleEvent(super.type, super.bubbles, super.cancelable, this.id);
		}

		public override function toString():String {
			return super.formatToString( ClassUtils.getClassName( this ), "type", "bubbles", "cancelable", "id" );
		}

	}

}