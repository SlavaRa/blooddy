////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.time {

	import by.blooddy.core.events.time.TimeEvent;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					29.07.2009 21:24:53
	 */
	public final class RelativeTime extends Time {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function RelativeTime(speed:Number=1) {
			super();
			this.speed = speed;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  currentTime
		//----------------------------------

		/**
		 * @private
		 */
		private var _currentTime:Number;

		public override function get currentTime():Number {
			return this._currentTime || ( super.currentTime * this._speed );
		}

		/**
		 * @private
		 */
		public override function set currentTime(value:Number):void {
			super.currentTime = value / this._speed;
			if ( this._currentTime ) {
				this._currentTime  = super.currentTime;
			}
		}

		//----------------------------------
		//  speed
		//----------------------------------

		/**
		 * @private
		 */
		private var _speed:Number;

		public function get speed():Number {
			return this._speed;
		}

		/**
		 * @private
		 */
		public function set speed(value:Number):void {
			if ( this._speed == value ) return;
			var old_value:Number = this._speed;
			this._speed = value;
			if ( value ) {
				if ( this._currentTime ) this._currentTime = NaN;
				super.currentTime = super.currentTime * old_value / value;
			} else {
				this._currentTime = this.currentTime;
			}

		}

	}

}