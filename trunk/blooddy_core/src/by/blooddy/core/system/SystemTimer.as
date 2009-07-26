package by.blooddy.core.system {

	import by.blooddy.core.events.SystemTimerEvent;
	import by.blooddy.core.utils.getTimer;
	
	import flash.events.EventDispatcher;

	[Event(name="absoluteSync", type="by.blooddy.core.events.SystemTimerEvent")]
	[Event(name="relativeSync", type="by.blooddy.core.events.SystemTimerEvent")]

	public class SystemTimer extends EventDispatcher {

		public static const global:SystemTimer = new SystemTimer();

//		private static const START_TIME:Number = ( new Date() ).getTime();

//		private static function getTimer():Number {
//			return ( new Date() ).getTime() - START_TIME;
//		}

		public function SystemTimer() {
			super();
		}

		private var _relativeZero:Number = getTimer();

		public function getRelativeTime():Number {
			return this.getAbsoluteTime() - this._relativeZero;
		}

		public function setRelativeTimeZero(value:Number):void {
			if ( this._relativeZero == value || isNaN( value ) ) return;
			var old:Number = this._relativeZero;
			this._relativeZero = value;
			super.dispatchEvent( new SystemTimerEvent( SystemTimerEvent.RELATIVE_SYNC, false, false, old - this._relativeZero ) );
		}
/*
		public function setRelativeTime(value:Number):void {
			if ( isNaN( value ) ) return;
			var old:Number = this._relativeDelta;
			this._relativeDelta = value - getTimer();
			if ( old == this._relativeDelta ) return;
			super.dispatchEvent( new SystemTimerEvent( SystemTimerEvent.RELATIVE_SYNC, false, false, this._relativeDelta - old ) );
		}

		public function setRelativeTimeDelta(value:Number):void {
			if ( old === value || isNaN( value ) ) return;
			var old:Number = value - this._relativeDelta;
			this._relativeDelta = value;
			super.dispatchEvent( new SystemTimerEvent( SystemTimerEvent.RELATIVE_SYNC, false, false, old ) );
		}
*/
		private var _absoluteOffset:Number = 0;

		public function getAbsoluteTime():Number {
			return ( new Date() ).getTime() + this._absoluteOffset;
		}

		public function setAbsoluteTime(value:Number):void {
			if ( isNaN( value ) ) return;
			var old:Number = this._absoluteOffset;
			this._absoluteOffset = value - ( new Date() ).getTime();
			if ( old == this._absoluteOffset ) return;
			var delta:Number = this._absoluteOffset - old;
			super.dispatchEvent( new SystemTimerEvent( SystemTimerEvent.ABSOLUTE_SYNC, false, false, delta ) );
			super.dispatchEvent( new SystemTimerEvent( SystemTimerEvent.RELATIVE_SYNC, false, false, delta ) );
		}

		public function setAbsoluteTimeOfsset(value:Number):void {
			if ( this._absoluteOffset == value || isNaN( value ) ) return;
			var delta:Number = value - this._absoluteOffset;
			this._absoluteOffset = value;
			super.dispatchEvent( new SystemTimerEvent( SystemTimerEvent.ABSOLUTE_SYNC, false, false, delta ) );
			super.dispatchEvent( new SystemTimerEvent( SystemTimerEvent.RELATIVE_SYNC, false, false, delta ) );
		}

	}

}