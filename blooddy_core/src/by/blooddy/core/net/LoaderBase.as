////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {
	
	import by.blooddy.core.net.monitor.NetMonitor;
	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.core.utils.enterFrameBroadcaster;
	
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.ProgressEvent;
	import flash.net.LocalConnection;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	//--------------------------------------
	//  Implements events: ILoadable
	//--------------------------------------
	
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
	
	/**
	 * @inheritDoc
	 */
	[Event( name="open", type="flash.events.Event" )]
	
	/**
	 * @inheritDoc
	 */
	[Event( name="progress", type="flash.events.ProgressEvent" )]
	
	//--------------------------------------
	//  Implements events: ILoader
	//--------------------------------------
	
	/**
	 * @inheritDoc
	 */
	[Event( name="httpStatus", type="flash.events.HTTPStatusEvent" )]
	
	/**
	 * @inheritDoc
	 */
	[Event( name="httpResponseStatus", type="flash.events.HTTPStatusEvent" )]
	
	/**
	 * @inheritDoc
	 */
	[Event( name="init", type="flash.events.Event" )]
	
	/**
	 * @inheritDoc
	 */
	[Event( name="unload", type="flash.events.Event" )]

	[ExcludeClass]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * @created					24.02.2010 21:47:24
	 */
	public class LoaderBase extends EventDispatcher implements ILoader {
		
		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		protected namespace $protected_load;

		use namespace $protected_load;
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		$protected_load static const HTTP_RESPONSE_STATUS:String = ( 'HTTP_RESPONSE_STATUS' in HTTPStatusEvent ? HTTPStatusEvent['HTTP_RESPONSE_STATUS'] : null );
		
		/**
		 * @private
		 */
		$protected_load static const _DOMAIN:String = ( new flash.net.LocalConnection() ).domain;
		
		/**
		 * @private
		 */
		$protected_load static const _URL:RegExp = ( _DOMAIN == 'localhost' ? null : new RegExp( '^(?:(?!\\w+://)|https?://(?:www\\.)?' + _DOMAIN.replace( /\./g, '\\.' ) + ')', 'i' ) );
		
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
		 * Constructor
		 * 
		 * @param	request			Если надо, то сразу передадим и начнётся загрузка.
		 */
		public function LoaderBase(request:URLRequest=null) {
			super();
			if ( request ) this.load( request );
		}

		//--------------------------------------------------------------------------
		//
		//  Variblies
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * состояние загрзщика
		 */
		private var _id:String;
		
		/**
		 * @private
		 * состояние загрзщика
		 */
		private var _state:uint = _STATE_IDLE;
		
		/**
		 * @private
		 */
		private var _frameReady:Boolean = false;
		
		/**
		 * @private
		 */
		private var _input:ByteArray;
		
		//--------------------------------------------------------------------------
		//
		//  Implements properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  url
		//----------------------------------

		/**
		 * @private
		 */
		private var _url:String;
		
		/**
		 * @inheritDoc
		 */
		public function get url():String {
			return this._url;
		}
		
		//----------------------------------
		//  bytesLoaded
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _bytesLoaded:uint = 0;
		
		/**
		 * @inheritDoc
		 */
		public function get bytesLoaded():uint {
			return this._bytesLoaded;
		}
		
		//----------------------------------
		//  bytesTotal
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _bytesTotal:uint = 0;
		
		/**
		 * @inheritDoc
		 */
		public function get bytesTotal():uint {
			return this._bytesTotal;
		}
		
		//----------------------------------
		//  progress
		//----------------------------------

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
		
		//----------------------------------
		//  loaded
		//----------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function get loaded():Boolean {
			return this._state >= _STATE_COMPLETE;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Implements methods: ILoader
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function load(request:URLRequest):void {
			if ( this._state != _STATE_IDLE ) throw new ArgumentError();
			//else if ( this._state > _STATE_PROGRESS ) this.clear();
			if ( NetMonitor.isActive ) {
//				if ( this._id ) {
					this._id = 'asdasdasd';
					NetMonitor.monitorInvocation( this._id, request, this );
					NetMonitor.adjustURLRequest( this._id, request );
//				}
			}
			this.$load( request );
			this._url = request.url;
			this._state = _STATE_PROGRESS;
			enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
		}

		/**
		 * @inheritDoc
		 */
		public function loadBytes(bytes:ByteArray):void {
			if ( this._state != _STATE_IDLE ) throw new ArgumentError();
			//else if ( this._state > _STATE_PROGRESS ) this.clear();
			this._input = new ByteArray();
			this._input.writeBytes( bytes );
			this._input.position = 0;
			enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.handler_frameContructed );
		}
		
		/**
		 * @inheritDoc
		 */
		public function close():void {
			if ( this._state != _STATE_PROGRESS ) throw new ArgumentError();
			this.clear();
		}
		
		/**
		 * @inheritDoc
		 */
		public function unload():void {
			if ( this._state <= _STATE_PROGRESS ) throw new ArgumentError();
			this.clear();
		}
		
		/**
		 * @private
		 */
		public override function toString():String {
			return '[' + ClassUtils.getClassName( this ) + ' url="' + ( this.url || '' ) + '"]';
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * очисщает данные
		 */
		$protected_load function isIdle():Boolean {
			return this._state == _STATE_IDLE;
		}
		
		/**
		 * @private
		 * очисщает данные
		 */
		$protected_load function $load(request:URLRequest):void {
			throw new IllegalOperationError();
		}
		
		/**
		 * @private
		 */
		$protected_load function $loadBytes(bytes:ByteArray):void {
			throw new IllegalOperationError();
		}
		
		/**
		 * @private
		 * очисщает данные
		 */
		$protected_load function $unload():Boolean {
			throw new IllegalOperationError();
		}
		
		/**
		 * @private
		 * обвновление прогресса
		 */
		$protected_load function updateProgress(bytesLoaded:uint, bytesTotal:uint):void {
			this._frameReady = false;
			if ( this._bytesLoaded < bytesLoaded ) {
				this._bytesLoaded = bytesLoaded;
			}
			this._bytesTotal = bytesTotal;
			if ( bytesTotal > 0 ) {
				this._progress = this._bytesLoaded / this._bytesTotal;
			} else {
				this._progress = ( this._state >= _STATE_COMPLETE ? 1 : 0 );
			}
			super.dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, this._bytesLoaded, this._bytesTotal ) );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * очисщает данные
		 */
		private function clear():void {
			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_frameContructed );
			if ( this._input ) {
				this._input.clear();
				this._input = null;
			}
			this._url = null;
			this._bytesLoaded = 0;
			this._bytesTotal = 0;
			this._state = _STATE_IDLE;
			if ( this.$unload() && super.hasEventListener( Event.UNLOAD ) ) {
				super.dispatchEvent( new Event( Event.UNLOAD ) );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * устанавливает _frameReady в true. что бы избежать слишком частые обвноления со стороны загрузщиков.
		 */
		private function handler_enterFrame(event:Event):void {
			this._frameReady = true;
		}
		
		/**
		 * @private
		 */
		private function handler_frameContructed(event:Event):void {
			enterFrameBroadcaster.removeEventListener( Event.FRAME_CONSTRUCTED, this.handler_frameContructed );
			if ( super.hasEventListener( Event.OPEN ) ) {
				super.dispatchEvent( new Event( Event.OPEN ) );
			}
			this.updateProgress( 0, this._input.length );
			this.$loadBytes( this._input );
			this._input = null;
		}
		
		/**
		 * @private
		 * слушает прогресс, и обвноляет его, если _frameReady установлен в true.
		 */
		$protected_load function handler_progress(event:ProgressEvent):void {
			if ( !this._frameReady ) return;
			this.updateProgress( event.bytesLoaded, event.bytesTotal );
		}
		
		/**
		 * @private
		 */
		$protected_load function handler_complete(event:Event):void {
			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			this._state = ( event is ErrorEvent ? _STATE_ERROR : _STATE_COMPLETE );
			if ( NetMonitor.isActive ) {
				//NetMonitor.monitorResult( '1231231231', 'asdasdasdasdas' );
			}
			super.dispatchEvent( event );
		}
		
	}
	
}