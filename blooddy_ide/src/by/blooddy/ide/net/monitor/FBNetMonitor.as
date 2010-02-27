////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.ide.net.monitor {

	import by.blooddy.core.net.ILoadable;
	import by.blooddy.core.net.Socket;
	import by.blooddy.core.net.monitor.INetMonitor;
	import by.blooddy.core.utils.Caller;
	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.core.utils.net.Location;
	import by.blooddy.core.utils.net.URLUtils;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	
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

		private static const _MSG_EVENT:uint =		1;
		private static const _MSG_RESULT:uint =		2;
		private static const _MSG_FAULT:uint =		3;
		private static const _MSG_INVOCATION:uint =	4;
		private static const _MSG_SUSPEND:uint =	5;
		private static const _MSG_RESUME:uint =		6;

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
			
			loc = new Location( URLUtils.createAbsoluteURL( ( this._appRoot || '' ), url ) );
			var arr:Array = loc.protocol.match( _R_HTTP );
			if ( !arr ) return url;

			var hostname:String = loc.hostname;
			var httpsName:String = ( arr[ 1 ] ? 'Y' : 'N' );

			loc.host = this._host;
			loc.port = this._httpPort;
			
			return loc.toString() + '?hostport=' + hostname + '&https=' + httpsName + '&id=' + ( correlationID || '-1' );
		}
		
		public function adjustURLRequest(correlationID:String, request:URLRequest):void {
			if ( this._state < _STATE_CONNECTING ) return;
			var url:String = this.adjustURL( request.url, correlationID );
			if ( url == request.url ) return;
			request.url = url;
		}

		public function monitorInvocation(correlationID:String, request:URLRequest, loader:ILoadable, context:*=null):void {
			if ( this._state < _STATE_CONNECTING ) return;

			if ( !context ) context = new SourceContext();

			if ( this._state == _STATE_CONNECTING ) {

				this.addToCache( this.monitorInvocation, correlationID, request, loader, context );

			} else {

				this._socket.writeByte( _MSG_INVOCATION );
				this._socket.writeUTF( ClassUtils.getClassName( loader ) );
				this._socket.writeUTF( context.file );
				this._socket.writeInt( context.line );
				this._socket.writeUTF( correlationID );
				this._socket.writeObject( request.data );
				this._socket.writeUTF( String( request ) );
				this._socket.writeUTF( request.method );
				this._socket.writeUTF( request.url );
				this._socket.writeUTF( 'test2.mxml' );
				this._socket.flush();

			}
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
			trace( this + ' constructed!' );
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
			trace( this + ' destructed!' );
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

/**
 * @private
 */
internal final class SourceContext {

	/**
	 * @private
	 */
	private static const _LINE:RegExp = /^\s*at\s+([^(\/]+)(?:\/([^(]+))?\(\)(?:\[(.*?):(\d+)\])?$/gm;

	/**
	 * @private
	 */
	private static const _EXCLUDE:RegExp = /^by\.blooddy\.(?:core|ide)/;

	public function SourceContext() {
		super();

		var stack:String = ( new Error() ).getStackTrace();

		_LINE.lastIndex = 10; // пропускаем самих себя =)

		var row:Array;
		while ( row = _LINE.exec( stack ) ) {
			if ( !_EXCLUDE.test( row[ 1 ] ) ) {
				this.file = row[ 3 ];
				this.line = parseInt( row[ 4 ], 10 );
				break;
			}
		}

	}

	public var file:String;

	public var line:uint;

}