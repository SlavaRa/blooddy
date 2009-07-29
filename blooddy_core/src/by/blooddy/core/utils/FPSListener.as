////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import by.blooddy.core.utils.time.getTimer;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class FPSListener extends EventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const listener:FPSListener = new FPSListener();

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static var _inited:Boolean = false;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Constructior
		 */
		public function FPSListener() {
			super();
			if ( _inited ) throw new ArgumentError();
			enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.handler_enterFrame, false, int.MIN_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _lastUpdate:uint;

		/**
		 * @private
		 */
		private const _TIMES:Vector.<uint> = new Vector.<uint>();

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  samplingTime
		//----------------------------------

		/**
		 * @private
		 */
		private var _samplingTime:uint = 60 * 1E3;

		public function get samplingTime():uint {
			return this._samplingTime;
		}

		/**
		 * @private
		 */
		public function set samplingTime(value:uint):void {
			if ( this._samplingTime == value ) return;
			this._samplingTime = value;
		}

		//----------------------------------
		//  fps
		//----------------------------------

		/**
		 * @private
		 */
		private var _fps:Number = 0;

		public function get fps():Number {
			var time:uint = getTimer();
			if ( this._lastUpdate + 1E3 <= time ) {
				this.updateFPS();
				this._lastUpdate = time;
			}
			return this._fps;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function updateFPS():void {
			var time:Number = getTimer() - this._samplingTime;
			var l:uint = this._TIMES.length;
			var i:uint = 0;
			while ( i< l && this._TIMES[ i ] < time ) i++;
			if ( i > 0 ) {
				this._TIMES.splice( 0, i );
				l = this._TIMES.length;
			}
			if ( l > 0 ) {
				this._fps = 1E3 * l / ( this._TIMES[ l - 1 ] - this._TIMES[ 0 ] );
			} else {
				this._fps = 0;
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Обновлялка состояния
		 */
		private function handler_enterFrame(event:Event):void {
			// запомним время
			this._TIMES.push( getTimer() );
		}

	}

}