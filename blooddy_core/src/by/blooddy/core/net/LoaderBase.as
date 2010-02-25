////////////////////////////////////////////////////////////////////////////////
//
//  (C) 20010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {
	
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
	import by.blooddy.core.utils.StringUtils;
	
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

		protected namespace lb_protected;

		use namespace lb_protected;
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		lb_protected static const HTTP_RESPONSE_STATUS:String = ( 'HTTP_RESPONSE_STATUS' in HTTPStatusEvent ? HTTPStatusEvent['HTTP_RESPONSE_STATUS'] : null );
		
		/**
		 * @private
		 */
		lb_protected static const _DOMAIN:String = ( new flash.net.LocalConnection() ).domain;
		
		/**
		 * @private
		 */
		lb_protected static const _URL:RegExp = ( _DOMAIN == 'localhost' ? null : new RegExp( '^((?!\w+://)|https?://(www\.)?' + _DOMAIN.replace( /\./g, '\\.' ) + ')', 'i' ) );
		
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
			this.$load( request );
			if ( NetworkMonitor.isMonitoring() ) {
				this._id = StringUtils.random();
				NetworkMonitor.adjustURLRequest( request, 'хуй знает', this._id );
			}
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
		lb_protected function isIdle():Boolean {
			return this._state == _STATE_IDLE;
		}
		
		/**
		 * @private
		 * очисщает данные
		 */
		lb_protected function $load(request:URLRequest):void {
			throw new IllegalOperationError();
		}
		
		/**
		 * @private
		 */
		lb_protected function $loadBytes(bytes:ByteArray):void {
			throw new IllegalOperationError();
		}
		
		/**
		 * @private
		 * очисщает данные
		 */
		lb_protected function $unload():Boolean {
			throw new IllegalOperationError();
		}
		
		/**
		 * @private
		 * обвновление прогресса
		 */
		lb_protected function updateProgress(bytesLoaded:uint, bytesTotal:uint):void {
			this._frameReady = false;
			if ( this._bytesLoaded < bytesLoaded ) {
				this._bytesLoaded = bytesLoaded;
			}
			this._bytesTotal = bytesTotal;
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
		lb_protected function handler_progress(event:ProgressEvent):void {
			if ( !this._frameReady ) return;
			this.updateProgress( event.bytesLoaded, event.bytesTotal );
		}
		
		/**
		 * @private
		 */
		lb_protected function handler_complete(event:Event):void {
			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			this._state = ( event is ErrorEvent ? _STATE_ERROR : _STATE_COMPLETE );
			if ( NetworkMonitor.isMonitoring() ) {
				NetworkMonitor.monitorResult( '1231231231', 'asdasdasdasdas' );
			}
			super.dispatchEvent( event );
		}
		
	}
	
}