////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.logging {

	import by.blooddy.core.events.logging.LogEvent;
	import by.blooddy.core.utils.time.getTimer;
	
	import flash.events.EventDispatcher;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 */
	[Event(name="addedLog", type="by.blooddy.core.events.logging.LogEvent")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					log, logger
	 */
	public class Logger extends EventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 * 
		 * @param	maxLength
		 * @param	maxTime
		 */
		public function Logger(maxLength:uint=100, maxTime:uint=5*60*1E3) {
			super();
			this._maxLength = maxLength;
			this._maxTime = maxTime; 
		}

		//--------------------------------------------------------------------------
		//
		//  Includes
		//
		//--------------------------------------------------------------------------

		include "../../../../includes/override_EventDispatcher.as"

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _list:Vector.<Log> = new Vector.<Log>();
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  length
		//----------------------------------

		public function get length():uint {
			return this._list.length;
		}

		//----------------------------------
		//  maxLength
		//----------------------------------

		/**
		 * @private
		 */
		private var _maxLength:uint;

		public function get maxLength():uint {
			return this._maxLength;
		}

		/**
		 * @private
		 */
		public function set maxLength(value:uint):void {
			if ( this._maxLength == value ) return;
			this._maxLength = value;
			this.updateList();
		}

		//----------------------------------
		//  maxTime
		//----------------------------------

		/**
		 * @private
		 */
		private var _maxTime:uint;

		public function get maxTime():uint {
			return this._maxTime;
		}

		/**
		 * @private
		 */
		public function set maxTime(value:uint):void {
			if ( this._maxTime == value ) return;
			this._maxTime = value;
			this.updateList();
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function addLog(log:Log):void {
			this._list.push( log );
			this.updateList();
			super.dispatchEvent( new LogEvent( LogEvent.ADDED_LOG, false, false, log ) );
		}

		public function getList():Vector.<Log> {
			return this._list.slice();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function updateList():void {
			var time:uint = getTimer();
			const l:uint = this._list.length;
			for ( var i:uint = 0; i < l; i++ ) {
				if ( time - this._list[i].time < this._maxTime ) {
					break;
				}
			}
			if ( l - i > this._maxLength ) {
				i = l - this._maxLength;
			}
			if ( i > 0 ) {
				this._list.splice( 0, i );
			}
		}

	}

}