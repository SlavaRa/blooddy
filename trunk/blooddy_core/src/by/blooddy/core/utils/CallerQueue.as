package by.blooddy.core.utils {

	import flash.events.Event;

	public final class CallerQueue {

		public function CallerQueue() {
			super();
		}

		private const _queue:Array = new Array();

		public function addQueue(handler:Function, ...args):void {
			this.addCallerQueue( new Caller( handler, args ) );
		}

		public function addCallerQueue(caller:Caller):void {
			if ( this._queue.push( caller ) == 1 ) {
				enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.call, false, int.MAX_VALUE );
			}
		}

		private function call(event:Event=null):void {
			( this._queue.shift() as Caller ).call();
			if ( this._queue.length <= 0 ) {
				enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.call ); 
			}
		}

	}

}