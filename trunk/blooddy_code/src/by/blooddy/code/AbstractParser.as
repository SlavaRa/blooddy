////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code {

	import by.blooddy.core.net.loading.ILoadable;
	import by.blooddy.core.utils.enterFrameBroadcaster;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	
	//--------------------------------------
	//  Implements events: ILoadable
	//--------------------------------------

	/**
	 * @inheritDoc
	 */
	[Event( name="progress", type="flash.events.ProgressEvent" )]

	/**
	 * @inheritDoc
	 */
	[Event( name="complete", type="flash.events.Event" )]

	/**
	 * @inheritDoc
	 */
	[Event( name="ioError", type="flash.events.IOErrorEvent" )]
	
	/**
	 * @inheritDoc
	 */
	[Event( name="securityError", type="flash.events.SecurityErrorEvent" )]

	//--------------------------------------
	//  Events
	//--------------------------------------

	[Event( name="open", type="flash.events.Event" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					28.04.2010 17:15:33
	 */
	public class AbstractParser extends EventDispatcher implements ILoadable {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * статус загрузки. ожидание
		 */
		private static const _STATE_IDLE:uint =		0;
		
		/**
		 * @private
		 * статус загрузки. прогресс
		 */
		private static const _STATE_PROGRESS:uint =	_STATE_IDLE		+ 1;
		
		/**
		 * @private
		 * статус загрузки. всё зашибись
		 */
		private static const _STATE_COMPLETE:uint =	_STATE_PROGRESS	+ 1;
		
		/**
		 * @private
		 * статус загрузки. ошибка
		 */
		private static const _STATE_ERROR:uint =	_STATE_COMPLETE	+ 1;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function AbstractParser() {
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _state:uint;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _progress:Number;
		
		/**
		 * @inheritDoc
		 */
		public function get progress():Number {
			return this._progress;
		}

		/**
		 * @inheritDoc
		 */
		public function get loaded():Boolean {
			return this._state >= _STATE_COMPLETE;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get bytesLoaded():uint {
			return 0;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get bytesTotal():uint {
			return 0;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------
		
		protected final function $parse_prepare():void {
			if ( this._state != _STATE_IDLE ) throw new ArgumentError();
			enterFrameBroadcaster.addEventListener( Event.FRAME_CONSTRUCTED, this.handler_frameConstructed );
			this._state = _STATE_PROGRESS;
		}

		protected virtual function $parse_action():Boolean {
			throw new IllegalOperationError();
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_frameConstructed(event:Event):void {
			enterFrameBroadcaster.removeEventListener( Event.FRAME_CONSTRUCTED, this.handler_frameConstructed );
			if ( super.hasEventListener( Event.OPEN ) ) {
				super.dispatchEvent( new Event( Event.OPEN ) );
			}
			enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
		}
		
		/**
		 * @private
		 */
		private function handler_enterFrame(event:Event):void {
			try {
				if ( this.$parse_action() ) {
					this._state = _STATE_COMPLETE;
				}
				if ( this._state >= _STATE_COMPLETE ) {
					this._progress = 1;
				} else {
					this._progress = this.bytesLoaded / this.bytesTotal;
				}
				if ( super.hasEventListener( ProgressEvent.PROGRESS ) ) {
					super.dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, this.bytesLoaded, this.bytesTotal ) );
				}
				if ( this.loaded ) { // это важно. если переопределён и тут херня, то не диспатчим
					super.dispatchEvent( new Event( Event.COMPLETE ) );
				}
			} catch ( e:SecurityError ) {
				this._state = _STATE_ERROR;
				super.dispatchEvent( new SecurityErrorEvent( SecurityErrorEvent.SECURITY_ERROR, false, false, e.toString() ) );
			} catch ( e:Error ) {
				this._state = _STATE_ERROR;
				super.dispatchEvent( new IOErrorEvent( IOErrorEvent.IO_ERROR, false, false, e.toString() ) );
			}
			if ( this._state >= _STATE_COMPLETE ) {
				enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			}
		}

	}

}