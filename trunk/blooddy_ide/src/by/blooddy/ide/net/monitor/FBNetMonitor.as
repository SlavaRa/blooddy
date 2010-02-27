////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.monitor {

	import by.blooddy.core.net.Socket;
	import by.blooddy.core.utils.Caller;
	import by.blooddy.core.utils.net.Location;
	import by.blooddy.core.utils.net.URLUtils;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					25.02.2010 9:40:35
	 */
	public final class FBNetMonitor implements INetMonitor {

		//--------------------------------------------------------------------------
		//
		//  Class constant
		//
		//--------------------------------------------------------------------------
		
		public static const DEFAULT_HOST:String =		'localhost';
		
		public static const DEFAULT_SOCKET_PORT:int =	27813;
		
		public static const DEFAULT_HTTP_PORT:int =		37813;

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _STATE_IDLE:uint =			0;

		/**
		 * @private
		 */
		private static const _STATE_PAUSE:uint =		1 + _STATE_IDLE;

		/**
		 * @private
		 */
		private static const _STATE_CONNECTING:uint =	1 + _STATE_PAUSE;

		/**
		 * @private
		 */
		private static const _STATE_COMPLETE:uint =		1 + _STATE_CONNECTING;
		
		/**
		 * @private
		 */
		private static const _R_HTTP:RegExp =	/^https?$/;

		/**
		 * @private
		 */
		private static const _HEADER_ID:String =		'x-blooddy-netMonitor-correlationID';
		
		/**
		 * @private
		 */
		private static const _HEADER_SERVICE:String =	'x-blooddy-netMonitor-serviceName';
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function FBNetMonitor(appRoot:String, host:String=null, socketPort:int=0, httpPort:int=0) {
			super();

			this._appRoot = appRoot;
			this._host = host || DEFAULT_HOST;
			this._socketPort = socketPort || DEFAULT_SOCKET_PORT;
			this._httpPort = httpPort || DEFAULT_HTTP_PORT;
			
			this._socket = new Socket();
			this._socket.addEventListener( Event.CONNECT,						this.handler_connect );
			this._socket.addEventListener( Event.CLOSE,							this.handler_close );
			this._socket.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_close );
			this._socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_close );
			this._socket.addEventListener( ProgressEvent.SOCKET_DATA,			this.handler_socketData );
			this._socket.connect( this._host, this._socketPort );

		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _appRoot:String;
		
		/**
		 * @private
		 */
		private var _socket:Socket;

		/**
		 * @private
		 */
		private var _host:String;
		
		/**
		 * @private
		 */
		private var _socketPort:int;

		/**
		 * @private
		 */
		private var _httpPort:int;

		/**
		 * @private
		 */
		private var _state:uint = _STATE_CONNECTING;

		/**
		 * @private
		 */
		private var _cache:Vector.<Caller>;
		
		//--------------------------------------------------------------------------
		//
		//  Implements properties
		//
		//--------------------------------------------------------------------------

		public function get isActive():Boolean {
			return this._state >= _STATE_CONNECTING;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		public function adjustURL(url:String, correlationID:String=null):String {
			if ( this._state < _STATE_CONNECTING ) return url;

			var loc:Location;
			loc = new Location( url );
			if ( loc.host == this._host || loc.port == this._httpPort ) return url; // мы и так уже под дозой!
			
			loc = new Location( URLUtils.getAbsoluteURL( ( this._appRoot || '' ), url ) );
			var arr:Array = loc.protocol.match( _R_HTTP );
			if ( !arr ) return url;

			var hostname:String = loc.hostname;
			var httpsName:String = ( arr[ 1 ] ? 'Y' : 'N' );

			loc.host = this._host;
			loc.port = this._httpPort;
			
			return loc.toString() + '?hostport=' + hostname + '&https=' + httpsName + '&id=' + ( correlationID || '-1' );
		}
		
		public function adjustURLRequest(request:URLRequest, correlationID:String=null):void {
			if ( this._state < _STATE_CONNECTING ) return;
			var url:String = this.adjustURL( request.url, correlationID );
			if ( url == request.url ) return;
			request.url = url;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function addToCache(func:Function, ...args):void {
			if ( !this._cache ) this._cache = new Vector.<Caller>();
			this._cache.push( new Caller( func, args ) );
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_connect(event:Event):void {
			this._state = _STATE_COMPLETE;
			if ( this._cache ) {
				while ( this._cache.length > 0 ) {
					this._cache.shift().call();
				}
				this._cache = null;
			}
		}

		/**
		 * @private
		 */
		private function handler_close(event:ErrorEvent):void {
			this._state = _STATE_IDLE;
			this._cache = null;
			this._socket.removeEventListener( Event.CONNECT,						this.handler_connect );
			this._socket.removeEventListener( Event.CLOSE,							this.handler_close );
			this._socket.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_close );
			this._socket.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_close );
			this._socket.removeEventListener( ProgressEvent.SOCKET_DATA,			this.handler_socketData );
			this._socket = null;
		}
		
		/**
		 * @private
		 */
		private function handler_socketData(event:ProgressEvent):void {
			trace( event );
		}
		
	}
	
}