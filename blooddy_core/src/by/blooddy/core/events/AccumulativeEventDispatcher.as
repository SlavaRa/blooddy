package by.blooddy.core.events {

	import by.blooddy.core.utils.equalsObjects;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class AccumulativeEventDispatcher extends EventDispatcher {

		public function AccumulativeEventDispatcher(target:IEventDispatcher=null) {
			super( target );
		}

		private var _lock:int = 0;

		private const _events:Array = new Array();

		public function get lock():int {
			return this._lock;
		}

		public function set lock(value:int):void {
			if ( value < 0 ) throw new ArgumentError();
			this._lock = value;
			if ( this._lock == 0 ) {
				while ( this._events.length ) {
					this.dispatchEvent( this._events.pop() as Event );
				}
			}
		}

		public function hasAccumulativeEvent(event:Event):Boolean {
			var l:uint = this._events.length;
			for ( var i:uint = 0; i<l; i++ ) {
				if ( equalsObjects( event, this._events[ i ] ) ) return true;
			}
			return false;
		}

		public function accumulateEvent(event:Event):void {
			if ( this._lock > 0 ) {
				if ( !this.hasAccumulativeEvent( event ) ) {
					this._events.push( event );
				}
			} else {
				this.dispatchEvent( event );
			}
		}

	}

}