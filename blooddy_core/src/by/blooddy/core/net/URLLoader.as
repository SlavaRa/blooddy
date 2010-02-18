////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
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
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;

	//--------------------------------------
	//  Implements events: ILoadable
	//--------------------------------------

	/**
	 * @copy					by.blooddy.core.net.ILoadable#complete
	 */
	[Event( name="complete", type="flash.events.Event" )]

	/**
	 * @copy					by.blooddy.core.net.ILoadable#ioError
	 */
	[Event( name="ioError", type="flash.events.IOErrorEvent" )]

	/**
	 * @copy					by.blooddy.core.net.ILoadable#open
	 */
	[Event( name="open", type="flash.events.Event" )]

	/**
	 * @copy					by.blooddy.core.net.ILoadable#progress
	 */
	[Event( name="progress", type="flash.events.ProgressEvent" )]

	//--------------------------------------
	//  Implements events: ILoader
	//--------------------------------------

	/**
	 * @copy					by.blooddy.core.net.ILoader#httpStatus
	 */
	[Event( name="httpStatus", type="flash.events.HTTPStatusEvent" )]

	/**
	 * @copy					by.blooddy.core.net.ILoader#securityError
	 */
	[Event( name="securityError", type="flash.events.SecurityErrorEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					urlloader
	 */
	public class URLLoader extends EventDispatcher implements ILoader {

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
		 * Constructor
		 * 
		 * @param	request			Если надо, то сразу передадим и начнётся загрузка.
		 */
		public function URLLoader(request:URLRequest=null) {
			super();
			if ( request ) this.load( request );
		}

		//--------------------------------------------------------------------------
		//
		//  Includes
		//
		//--------------------------------------------------------------------------

		include "../../../../includes/override_EventDispatcher.as"

		//--------------------------------------------------------------------------
		//
		//  Variblies
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _stream:flash.net.URLStream;
		
		/**
		 * @private
		 * состояние загрзщика
		 */
		private var _state:uint = _STATE_IDLE;

		/**
		 * @private
		 */
		private var _frameReady:Boolean = false;
		
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
		private var _url:String = null;
		
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
		 * сколько байт загружено
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
		 * сколько байт всего
		 */
		public function get bytesTotal():uint {
			return this._bytesTotal;
		}
		
		//----------------------------------
		//  loaded
		//----------------------------------
		
		/**
		 * загрузился ли уже файл?
		 */
		public function get loaded():Boolean {
			return this._state >= _STATE_COMPLETE;
		}
		
		//----------------------------------
		//  content
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _content:*;
		
		/**
		 * @inheritDoc
		 */
		public function get content():* {
			return this._content;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  dataFormat
		//----------------------------------

		/**
		 * @private
		 */
		private var _dataFormat:String
		
		/**
		 * @copy			flash.net.URLLoader#dataFormat
		 */
		public function get dataFormat():String {
			return this._dataFormat;
		}

		/**
		 * @private
		 */
		public function set dataFormat(value:String):void {
			if ( this._dataFormat == value ) return;
			if ( this._state != _STATE_IDLE ) throw new IllegalOperationError();
			this._dataFormat = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods: ILoader
		//
		//--------------------------------------------------------------------------

		/**
		 * @copy					by.blooddy.core.net.ILoader#load
		 */
		public function load(request:URLRequest):void {
			if ( this._state != _STATE_IDLE ) throw new ArgumentError();
			//else if ( this._state > _STATE_PROGRESS ) this.clear();
			this._state = _STATE_PROGRESS;
			this._stream = this.create_stream();
			this._stream.load( request );
			enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
		}

		/**
		 * выгружает загруженный контент
		 */
		public function unload():void {
			if ( this._state <= _STATE_PROGRESS ) throw new ArgumentError();
			this.clear();
		}
		
		/**
		 * останавливает загрузку, и выгружает данные
		 */
		public function close():void {
			if ( this._state != _STATE_PROGRESS ) throw new ArgumentError();
			this.clear();
		}
		
		/**
		 * @private
		 */
		public override function toString():String {
			return '[' + ClassUtils.getClassName( this ) + ' url="' + ( this.url || "" ) + '"]';
		}
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * создаёт URLStream для загрузки
		 */
		private function create_stream():flash.net.URLStream {
			var result:flash.net.URLStream = new flash.net.URLStream();
			result.addEventListener( Event.OPEN,						super.dispatchEvent );
			result.addEventListener( HTTPStatusEvent.HTTP_STATUS,		super.dispatchEvent );
			result.addEventListener( ProgressEvent.PROGRESS,			this.handler_progress );
			result.addEventListener( Event.COMPLETE,					this.handler_complete );
			result.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_error );
			result.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error );
			return result;
		}
		
		/**
		 * @private
		 * очисщает данные
		 */
		private function clear():void {
			var unload:Boolean = Boolean( this._content || this._stream );
			this.clear_stream();
			this._bytesLoaded = 0;
			this._bytesTotal = 0;
			if ( this._content ) {
				if ( this._content is ByteArray ) {
					( this._content as ByteArray ).clear();
				}
				this._content = undefined;
			}
			this._state = _STATE_IDLE;
			if ( unload && super.hasEventListener( Event.UNLOAD ) ) {
				super.dispatchEvent( new Event( Event.UNLOAD ) );
			}
		}
		
		/**
		 * @private
		 * очищает stream
		 */
		private function clear_stream():void {
			if ( this._stream ) {
				if ( this._stream.connected ) {
					this._stream.close();
				}
				this._stream.removeEventListener( Event.OPEN,							super.dispatchEvent );
				this._stream.removeEventListener( HTTPStatusEvent.HTTP_STATUS,			super.dispatchEvent );
				this._stream.removeEventListener( ProgressEvent.PROGRESS,				this.handler_progress );
				this._stream.removeEventListener( Event.COMPLETE,						this.handler_complete );
				this._stream.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_error );
				this._stream.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error );
				this._stream = null;
			}
		}
		
		/**
		 * @private
		 * обвновление прогресса
		 */
		private function updateProgress(bytesLoaded:uint, bytesTotal:uint):void {
			this._bytesLoaded = bytesLoaded;
			this._bytesTotal = bytesTotal;
			super.dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, this._bytesLoaded, this._bytesTotal ) );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * слушает прогресс, и обвноляет его, если _frameReady установлен в true.
		 */
		private function handler_progress(event:ProgressEvent):void {
			if ( !this._frameReady ) return;
			this._frameReady = false;
			this.updateProgress( event.bytesLoaded, event.bytesTotal );
		}
		
		/**
		 * @private
		 * устанавливает _frameReady в true. что бы избежать слишком частые обвноления со стороны загрузщиков.
		 */
		private function handler_enterFrame(event:Event):void {
			this._frameReady = true;
		}
		
		/**
		 * @private
		 * слушает ошибки
		 */
		private function handler_error(event:ErrorEvent):void {
			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			this._state = _STATE_ERROR;
			super.dispatchEvent( event );
		}
		
		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {

			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			this.updateProgress( this._bytesLoaded, this._bytesTotal );

			var input:ByteArray = new ByteArray();
			this._stream.readBytes( input, input.length );
			this.clear_stream();
			input.position = 0;

			switch ( this._dataFormat ) {
				case URLLoaderDataFormat.TEXT:
				case URLLoaderDataFormat.VARIABLES:
					try {
						var s:String = ( input.length > 0
							?	input.readUTFBytes( input.length )
							:	''
						);
						this._content = ( this._dataFormat == URLLoaderDataFormat.VARIABLES
							?	new URLVariables( s )
							:	s
						);
					} catch ( e:Error ) {
						// TODO
					}
					break;
				default:
					this._content = input;
					break;
			}

			if ( super.hasEventListener( Event.INIT ) ) {
				super.dispatchEvent( new Event( Event.INIT ) );
			}
			this._state = _STATE_COMPLETE;
			this.updateProgress( bytesTotal, bytesTotal );
			super.dispatchEvent( event );
		}

	}

}