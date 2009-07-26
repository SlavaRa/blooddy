package by.blooddy.core.utils {

	import flash.errors.IllegalOperationError;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude(kind="event",	name="timerComplete")]

	public class AutoTimer extends Timer {

		public function AutoTimer(delay:Number) {
			super( delay );
		}

		public override function set delay(value:Number):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		public override function set repeatCount(value:int):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="метод запрещён. включается автоматически.", replacement="addEventListener")]
		public override function start():void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="метод запрещён. выключается автоматически.", replacement="removeEventListener")]
		public override function stop():void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="метод не использщуется")]
		public override function reset():void {
			throw new IllegalOperationError();
		}

		public override function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			super.addEventListener( type, listener, useCapture, priority, useWeakReference );
			if ( type == TimerEvent.TIMER ) {
				if ( !super.running ) {
					super.start();
				}
			}
		}

		public override function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
			super.removeEventListener( type, listener, useCapture );
			if ( type == TimerEvent.TIMER ) {
				if ( super.running && !super.hasEventListener( type ) ) {
					super.stop();
				}
			}
		}

	}

}